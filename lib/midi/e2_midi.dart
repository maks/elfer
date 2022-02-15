import 'dart:convert';
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

/// throws RangeError if string is too long for paddedSize
List<int> nullTerminatedStringPadded(int paddedSize, String text) {
  final List<int> textBuffer = ascii.encode(text);
  if (textBuffer.length > (paddedSize - 1)) {
    throw RangeError('text too long for padded size');
  }
  final padding = paddedSize - 1 - textBuffer.length;
  return [...textBuffer, 0, ...List.filled(padding, 0)];
}

/// returns the tempo encoded as 2 bytes as expected by the E2:
/// 200~3000 = 20.0 ~ 300.0
List<int> e2EncodedTempo(double tempo) {
  final result = [0, 0];
  return result;
}
