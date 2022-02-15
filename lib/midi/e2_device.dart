import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';

import 'package:bonsai/bonsai.dart';
import 'package:ninja_hex/ninja_hex.dart';
import 'e2_data.dart';
import 'e2_midi.dart' as e2;
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:collection/collection.dart';

import 'e2_midi.dart';

class E2Device {
  final MidiCommand _midi;
  MidiDevice? _device;
  int? _globalChannel;
  int? _e2ProductId;
  StreamSubscription<MidiPacket>? _rxSubscription;
  final _inputStreamController = StreamController<E2InputEvent>();

  late Stream e2Events = _inputStreamController.stream.asBroadcastStream();

  E2Device(this._midi);

  Future<void> connectDevice() async {
    final devices = await _midi.devices;
    final device = devices?.firstWhereOrNull((dev) => dev.name.startsWith('electribe2'));
    if (device != null) {
      await _midi.connectToDevice(device);

      _rxSubscription ??= _midi.onMidiDataReceived?.listen(_handleMidiInput);

      _device = device;
      log('connected device:${_device?.name}');

      await Future.delayed(const Duration(seconds: 1));
      log('Search for E2 Device...');
      send(e2.searchDeviceMessage);
    } else {
      Log.e('no E2 device to connect to');
    }
  }

  void disconnect() {
    if (_device != null) {
      _midi.disconnectDevice(_device!);
      log('disconnected device:${_device?.name}');
    } else {
      log('no device to disconnect');
    }
  }

  Future<void> getPattern(int patternNumber) async {
    if (_globalChannel != null && _e2ProductId != null) {
      send(getPatternMessage(patternNumber, _globalChannel!, _e2ProductId!));
    } else {
      Log.e('cannot get Pattern not initialised');
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
      if (packet.data[0] != 0xF8) {
        // don't debug log Midi clock mesgs
        if (packet.data.length > 80) {
          log('received BIG packet [${packet.data.length}] first 40bytes:'
              ' ${hexView(0, packet.data.sublist(0, 39))}');

          const headerOffSet = 9;
          if (isPatternReply(packet.data, _e2ProductId!)) {
            final decoded =
                decodeMidiData(packet.data.sublist(headerOffSet, packet.data.length - 1));
            log('decode check..');
            checkData(decoded);
            final pattern = patternFromData(decoded);
            log('pattern name: ${pattern.name}');
            log('pattern tempo: ${pattern.tempo}');
          } else {
            log('not a pattern data message');
          }
        } else {
          log('received packet: ${hexView(0, packet.data)}');
        }
      }

      // process the incoming midi message
      if (isSysex(packet.data)) {
        if (isSearchDevicereply(packet.data)) {
          _globalChannel = packet.data[4];
          _e2ProductId = packet.data[6];
          log('got global channel:$_globalChannel e2Id:$_e2ProductId');
        }
      } else {
        _inputStreamController.add(E2InputEvent(packet.data));
      }
    }
  }
}

class E2InputEvent {
  final Uint8List data;

  E2InputEvent(this.data);
}
