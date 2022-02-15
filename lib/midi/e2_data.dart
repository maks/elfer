/// The functions in this library are a Dart port of equivalent functions from:
/// https://github.com/rafamj/elecmidi/blob/main/elecmidi.c
/// and elecmidi.h
/// by "@rafamj" on Github, licensed under GPLv3
library e2_data;

import 'dart:ffi';
import 'dart:typed_data';

import '../elecmidi_generated.dart';

/// This converts "7 bit" 8 byte "sets" of midi data as sent/recieved
/// from an E2 to "normal" 8bits per byte format
/// E2's format is that every 8th byte (b7 in the Korg docs) contains
/// the high-bit of each of the following 7 bytes (which are only 7bit)
Uint8List decodeMidiData(Uint8List midiData) {
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

Uint8List encodeMidiData(Uint8List data) {
  List<int> outputBuffer = List.filled(data.length, 0);
  int byte7 = 0;
  int o = 0;
  for (var i = 0; i < data.length; i++) {
    outputBuffer[o] = data[i] & 0x7F;
    if ((data[i] & 0x80) > 0) {
      byte7 = byte7 | 0x80;
      byte7 = byte7 >> 1;
    }
    if ((i % 7) == 6) {
      outputBuffer[o - 7] = byte7;
      byte7 = 0;
      o++;
    }
    o++;
  }
  return Uint8List.fromList(outputBuffer);
}

// returns 0 on success, -1 for invalid header, -2 invalid footer
void checkData(Pointer<PatternType> patternData) {
  // check header
  if (patternData.ref.header[0] != 0x50) {
    throw Exception('invalid header: [${patternData.ref.header[0]}]');
  }
  //check footer
  if (patternData.ref.footer[0] != 0x50) {
    throw Exception('invalid footer: [${patternData.ref.footer[0]}]');
  }
}
