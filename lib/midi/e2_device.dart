import 'dart:async';
import 'dart:typed_data';

import 'package:bonsai/bonsai.dart';
import 'package:ninja_hex/ninja_hex.dart';
import 'e2_midi.dart' as e2;
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:collection/collection.dart';

class E2Device {
  final MidiCommand _midi;
  MidiDevice? _device;
  int? _globalChannel;
  StreamSubscription<MidiPacket>? _rxSubscription;
  final _inputStreamController = StreamController<E2InputEvent>();

  late Stream e2Events = _inputStreamController.stream.asBroadcastStream();

  E2Device(this._midi);

  Future<void> connectDevice() async {
    final devices = await _midi.devices;
    final device = devices?.firstWhereOrNull((dev) => dev.name.startsWith('electribe2'));
    if (device != null) {
      await _midi.connectToDevice(device);

      _rxSubscription ??= _midi.onMidiDataReceived?.listen((packet) {
        if (packet.data.length == 1 && packet.data[0] == 0xF8) {
          // skip clock mesgs
        } else {
          if (packet.data[0] != 0xF8) {
            // don't debug log Midi clock mesgs
            log('received packet: ${hexView(0, packet.data)}');
          }

          // process the incoming midi message
          if (_isSysex(packet.data)) {
            if (_isSearchDevicereply(packet.data)) {
              _globalChannel = packet.data[4];
              log('got global channel:$_globalChannel');
            }
          } else {
            _inputStreamController.add(E2InputEvent.fromMidi(packet.data));
          }
        }
      });

      _device = device;
      log('connected device:${_device?.name}');

      await Future.delayed(const Duration(seconds: 1));
      log('Search Device...');
      send(e2.searchDevice);
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

  // raw midi message send to E2
  void send(Uint8List midiMesg) {
    _midi.sendData(midiMesg);
  }

  void close() {
    _rxSubscription?.cancel();
  }

  bool _isSearchDevicereply(Uint8List data) =>
      const ListEquality().equals(data.sublist(0, 3), [0xF0, 0x42, 0x50]);

  bool _isSysex(Uint8List data) => data.isNotEmpty && data[0] == 0xF0;
}

class E2InputEvent {
  static fromMidi(Uint8List data) {
    throw UnimplementedError();
  }
}
