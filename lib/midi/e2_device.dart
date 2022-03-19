import 'dart:async';
import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:bonsai/bonsai.dart';
import 'package:collection/collection.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:ninja_hex/ninja_hex.dart';

import '../tracker/e2_data/e2_pattern.dart';
import '../tracker/e2_data/elecmidi_generated.dart';
import 'e2_data.dart';
import 'e2_midi.dart' as e2;
import 'e2_midi.dart';

const _delayHACK = 500; //ms

class E2Device {
  final MidiCommand _midi;
  MidiDevice? _device;
  int? _globalChannel;
  int? _e2ProductId;

  int _currentPatternIndex = 0;
  int _pendingBankSelect = 0;

  StreamSubscription<MidiPacket>? _rxSubscription;
  final _inputStreamController = StreamController<E2InputEvent>();

  final _currentPatternStreamController = StreamController<E2Pattern>();

  final _messagesStreamController = StreamController<String>();

  late Stream<E2InputEvent> e2Events = _inputStreamController.stream.asBroadcastStream();

  late Stream<E2Pattern> currentPatternStream = _currentPatternStreamController.stream.asBroadcastStream();

  late Stream<String> messages = _messagesStreamController.stream.asBroadcastStream();

  final List<int> _pendingBuffer = [];

  E2Device(this._midi);

  Future<void> connectDevice() async {
    _pendingBuffer.clear();
    final devices = await _midi.devices;
    final device = devices?.firstWhereOrNull((dev) => dev.name.contains('electribe2'));
    if (device != null) {
      await _midi.connectToDevice(device);

      _rxSubscription ??= _midi.onMidiDataReceived?.listen(_handleMidiInput);
      _device = device;
      log('connected device:${_device?.name}');
      _messagesStreamController.add('E2 Connected');

      // not sure why need small delay before being able to send search device mesg,
      // maybe time it takes for Alsa midi connection to setup?
      await Future<void>.delayed(const Duration(milliseconds: _delayHACK));
      log('Searching for E2 Device...');
      _messagesStreamController.add('Searching for E2 Device...');
      send(e2.searchDeviceMessage);
    } else {
      log('no E2 device to connect to');
      _messagesStreamController.add('no E2 device to connect to: ');
    }
  }

  void disconnect() {
    if (_device != null) {
      _midi.disconnectDevice(_device!);
      log('disconnected device:${_device?.name}');
      _messagesStreamController.add('E2 Disconnected');
    } else {
      log('no device to disconnect');
      _messagesStreamController.add('no device to disconnect');
    }
  }

  Future<void> getPattern() async {
    if (_globalChannel != null && _e2ProductId != null) {
      log('sending Get Pattern: $_currentPatternIndex');
      send(e2.getPatternMessage(_currentPatternIndex, _globalChannel!, _e2ProductId!));
      _messagesStreamController.add('Received pattern ${_currentPatternIndex + 1}');
    } else {
      Log.e('cannot get Pattern not initialised');
      _messagesStreamController.add('cannot get Pattern: not initialised');
    }
  }

  // raw midi message send to E2
  void send(Uint8List midiMesg) {
    log('send mesg: ${hexView(0, midiMesg)}');
    _midi.sendData(midiMesg);
  }

  void close() {
    _rxSubscription?.cancel();
  }

  void _handleMidiInput(MidiPacket packet) {
    if (packet.data.length == 1 && packet.data[0] == 0xF8) {
      // skip clock mesgs
    } else {
      // don't debug log Midi clock mesgs
      if (packet.data[0] != 0xF8) {
        if (packet.data.length > 3) {
          log('received BIG packet [${packet.data.length}] ');
          log('DATA: ${hexView(0, packet.data.sublist(0, math.min(20, packet.data.length)))}');

          if (e2.isSysex(packet.data)) {
            // process the incoming midi message
            if (e2.isSearchDevicereply(packet.data)) {
              _globalChannel = packet.data[4];
              _e2ProductId = packet.data[6];
              log('got Search Device reply, Global channel:$_globalChannel e2Id:$_e2ProductId');

              // now can request initial current pattern data
              getPattern();
              return;
            }
          }

          if (packet.data.length < patternMessageSize) {
            // log('partial response: ${packet.data.length} pendingBuffer:${_pendingBuffer.length}');
            _pendingBuffer.addAll(packet.data);
          }

          const headerOffSet = 9;
          log('pending: ${_pendingBuffer.length}');
          final encodedData =
              _pendingBuffer.length == patternMessageSize ? Uint8List.fromList(_pendingBuffer) : packet.data;
          if (_pendingBuffer.length == patternMessageSize) {
            _pendingBuffer.clear();
          }
          if (e2.isPatternReply(encodedData, _e2ProductId!)) {
            final decoded = decodeMidiData(encodedData.sublist(headerOffSet, encodedData.length - 1));

            if (decoded.length != 16384) {
              throw Exception('Invalid pattern data size:${decoded.length}');
            }

            final ffi.Pointer<PatternType> patternData = patternPointerFromData(decoded);
            final patName = patternData.ref.name;
            log('name: ${patName.getDartString(18)}');

            log('decode check...');
            checkData(patternData);
            log("decode ✔️");
            _currentPatternStreamController.add(E2Pattern(
              patternData,
              decoded.length,
              _currentPatternIndex,
            ));
          } else {
            log('not a pattern data message');
          }
        } else {
          log('received Std Midi packet: ${hexView(0, packet.data)}');
          if (e2.isBankSelect(packet.data) && packet.data[1] == 0x20) {
            // the 3rd byte of the bankselect tells us if the following Prog Change mesg
            // is for 001-127 or 128-250 pattern range
            _pendingBankSelect = packet.data[2];
          } else if (e2.isProgramChange(packet.data)) {
            _currentPatternIndex = (_pendingBankSelect * 128) + packet.data[1];
            log('select pattern:$_currentPatternIndex');
            getPattern();
          } else {
            _inputStreamController.add(E2InputEvent(packet.data));
          }
        }
      }
    }
  }

  Future<void> sendPatternData(List<int> data, int patternNumber) async {
    final encodedPatternData = encodeMidiData(Uint8List.fromList(data));
    final midiMesg = e2.sendCurrentPatternMessage(
      _globalChannel!,
      _e2ProductId!,
      encodedPatternData,
    );

    // Need to ensure that large sysex data is not sent too fast
    // see: https://www.spinics.net/lists/alsa-devel/msg54414.html
    // and: https://github.com/InvisibleWrench/FlutterMidiCommand/issues/36
    int chunkSize = 256;
    int chunks = (midiMesg.lengthInBytes % chunkSize == 0)
        ? midiMesg.lengthInBytes ~/ chunkSize
        : midiMesg.lengthInBytes ~/ chunkSize + 1;

    for (int chunkCount = 1, start = 0, end = chunkSize; chunkCount <= chunks; chunkCount++) {
      if (chunkCount == chunks) {
        _midi.sendData(midiMesg.sublist(start));
      } else {
        _midi.sendData(midiMesg.sublist(start, end));
      }
      start = chunkCount * chunkSize;
      end = start + chunkSize;
      sleep(const Duration(milliseconds: 10));
    }
    // log('sent Pattern:');
  }

  void loadPattern(E2Pattern p) {
    _currentPatternStreamController.add(p);
  }
}

class E2InputEvent {
  final Uint8List data;

  E2InputEvent(this.data);
}

/// thank you @Sunbreak!
/// https://github.com/timsneath/win32/issues/142#issuecomment-829846260
extension CharArray on ffi.Array<ffi.Uint8> {
  String getDartString(int maxLength) {
    var list = <int>[];
    for (var i = 0; i < maxLength; i++) {
      if (this[i] != 0) list.add(this[i]);
    }
    return utf8.decode(list);
  }

  void setDartString(String s, int maxLength) {
    var list = utf8.encode(s);
    for (var i = 0; i < maxLength; i++) {
      this[i] = i < list.length ? list[i] : 0;
    }
  }
}
