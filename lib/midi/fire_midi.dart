import 'web_midi.dart';

void fireAllOff(int r, int g, int b) {
  const sysexHeader = [
    0xF0,
    0x47,
    0x7F,
    0x43,
    0x65,
    0x02,
    0x00, // mesg length - low byte
  ];
  const sysexFooter = [
    0xF7, // End of Exclusive
  ];
  final allLeds = <int>[];
  for (int idx = 0; idx < 64; idx++) {
    final ledData = [
      idx,
      r,
      g,
      b,
    ];
    allLeds.addAll(ledData);
  }
  final midiData = <int>[...sysexHeader, ...allLeds, ...sysexFooter];
  send(midiData);
}
