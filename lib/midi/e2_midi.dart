import 'dart:typed_data';

const searchDeviceID = 0x11;

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

Uint8List get searchDevice {
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
