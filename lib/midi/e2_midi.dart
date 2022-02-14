import 'dart:typed_data';
import 'package:collection/collection.dart';

const searchDeviceID = 0x11;

const eq = ListEquality();

Uint8List requestPattern(int globalChannel) {
  final sysexHeader = [
    0xF0,
    0x42,
    (0x30 + globalChannel),
    0x00,
    0x01,
    0x24,
  ];
  const sysexFooter = [
    0xF7, // End of Exclusive
  ];

  final requestMesg = []; //TODO

  final midiData = <int>[...sysexHeader, ...requestMesg, ...sysexFooter];
  return Uint8List.fromList(midiData);
}

Uint8List get searchDeviceMessage {
  const sysexHeader = [
    0xF0,
    0x42,
  ];
  const sysexFooter = [
    0xF7, // End of Exclusive
  ];
  const mesg = [0x50, 0x00, searchDeviceID];
  final midiData = <int>[...sysexHeader, ...mesg, ...sysexFooter];
  return Uint8List.fromList(midiData);
}

Uint8List getPatternMessage(int patternNumber, int globalChannel, int e2Id) {
  final sysexHeader = _sysexHeader(globalChannel, e2Id);
  const sysexFooter = [
    0xF7, // End of Exclusive
  ];
  final mesg = [0x1C, ...intToMidi(patternNumber)];
  final midiData = <int>[...sysexHeader, ...mesg, ...sysexFooter];
  return Uint8List.fromList(midiData);
}

bool isSearchDevicereply(Uint8List data) => eq.equals(data.sublist(0, 3), [0xF0, 0x42, 0x50]);

bool isSysex(Uint8List data) => data.isNotEmpty && data[0] == 0xF0;

bool isPatternReply(Uint8List data, int e2Id) =>
    eq.equals(data.sublist(0, 7), [0xF0, 0x42, 0x30, 0x0, 0x01, e2Id, 0x4C]);

List<int> _sysexHeader(int globalChannel, int e2Id) => [
      0xF0,
      0x42,
      0x30 + globalChannel,
      0x00,
      0x01,
      e2Id,
    ];

List<int> intToMidi(int n) => [n % 128, n ~/ 128];
