import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:bonsai/bonsai.dart';
import 'package:ninja_hex/ninja_hex.dart';
import '../editor/pattern.dart';
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
                _decodeMidiData(packet.data.sublist(headerOffSet, packet.data.length - 1));
            log('decode check..');
            _checkData(decoded);
            final pattern = _patternFromData(decoded);
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

// This converts "7 bit" 8 byte "sets" of midi data as sent/recieved
// from an E2 to "normal" 8bits per byte format
// E2's format is that every 8th byte (b7 in the Korg docs) contains
// the high-bit of each of the following 7 bytes (which are only 7bit)
// This is a Dart port of equivalent function from:
// https://github.com/rafamj/elecmidi/blob/main/elecmidi.c
Uint8List _decodeMidiData(Uint8List midiData) {
  List<int> outputBuffer = List.filled(midiData.length, 0);
  int byte7 = 0;
  int o = 0;
  for (var i = 0; i < midiData.length; i++) {
    if (i % 8 == 0) {
      // the high-bit byte
      byte7 = midiData[i];
    } else {
      outputBuffer[o] = midiData[i];
      if ((byte7 & 0x01) == 1) {
        outputBuffer[o] += 128;
      }
      byte7 = byte7 >> 1;
      o++;
    }
  }
  return Uint8List.fromList(outputBuffer);
}

// returns 0 on success, -1 for invalid header, -2 invalid footer
void _checkData(Uint8List patternData) {
  if (patternData.length != 18725) {
    throw Exception('Invalid pattern data size:${patternData.length}');
  }
  // check header
  if (patternData[0] != 0x50) {
    throw Exception('invalid header: [${patternData.sublist(0, 4)}]');
  }
  //check footer
  if (patternData[footer] != 0x50) {
    throw Exception('invalid footer: [${patternData.sublist(footer, footer + 4)}]');
  }
}

const stepTypeSize = (4 * 1) + (2 * 4);
const partTypeSize = (5 * 1) + 5 + 38 + (stepTypeSize * 64);

const header = 0;
const size = header + 4;
const fill1 = size + 4;
const fill2 = fill1 + 4;
const name = fill2 + 4;
const tempo1 = name + 18;
const tempo2 = tempo1 + 1;
const swing = tempo2 + 1;
const length = swing + 1;
const beat = length + 1;
const key = beat + 1;
const scale = key + 1;
const chordset = scale + 1;
const playlevel = chordset + 1;
const fill3 = playlevel + 1;
const touchScale = fill3 + 1;
const masterFX = touchScale + 16;
const alternate1314 = masterFX + 8;
const alternate1516 = alternate1314 + 1;
const fill4 = alternate1516 + 1;
const fill5 = fill4 + 8;
const motionSequence = fill5 + 178;
const fill6 = motionSequence + 1584;
const part = fill6 + 208;
const fill7 = part + (partTypeSize * 16);
const footer = fill7 + 252;
const fill8 = footer + 4;

// parse midi data into Pattern object
E2Pattern _patternFromData(List<int> patternData) {
  return E2Pattern(
    beat: 0,
    chordset: 0,
    key: 0,
    length: 0,
    name: utf8.decode(patternData.sublist(name, name + 18)),
    parts: [],
    playLevel: 0,
    scale: 0,
    swing: 0,
    tempo: ((patternData[tempo1] + (256 * patternData[tempo2])) / 10),
  );
}
