/// The functions in this library are a Dart port of equivalent functions from:
/// https://github.com/rafamj/elecmidi/blob/main/elecmidi.c
/// and elecmidi.h
/// by "@rafamj" on Github, licensed under GPLv3
library e2_data;

import 'dart:ffi';
import 'dart:typed_data';

import '../elecmidi_generated.dart';

const decodedSize = 16384;
const encodedSize = 18725;

/// This converts "7 bit" 8 byte "sets" of midi data as sent/recieved
/// from an E2 to "normal" 8bits per byte format
/// E2's format is that every 8th byte (b7 in the Korg docs) contains
/// the high-bit of each of the following 7 bytes (which are only 7bit)
Uint8List decodeMidiData(Uint8List midiData) {
  List<int> outputBuffer = List.filled(decodedSize, 0);
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
  List<int> outputBuffer = List.filled(encodedSize, 0);
  int byte7 = 0;
  int o = 1; //start at one to skip initial byte holding the first 7 "highbits"
  for (var i = 0; i < data.length; i++) {
    outputBuffer[o] = data[i] & 0x7F;

    if ((data[i] & 0x80) > 0) {
      byte7 = byte7 | 0x80;
    }
    byte7 = byte7 >> 1;

    if ((i % 7) == 6) {
      outputBuffer[o - 7] = byte7;
      byte7 = 0;
      o++; //skip the byte that fill hold following
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

// TODO: these are factory, add new array for Hacktribe ones
const factoryScales = [
  "Chromatic",
  "Ionian",
  "Dorian",
  "Phrygian",
  "Lydian",
  "Mixolidian",
  "Aeolian",
  "Locrian",
  "Harm minor",
  "Melo minor",
  "Major Blues",
  "minor Blues",
  "Diminished",
  "Com.Dim",
  "Major Penta",
  "minor Penta",
  "Raga 1",
  "Raga 2",
  "Raga 3",
  "Arabic",
  "Spanish",
  "Gypsy",
  "Egyptian",
  "Hawaiian",
  "Pelog",
  "Japanese",
  "Ryuku",
  "Chinese",
  "Bass Line",
  "Whole Tone",
  "minor 3rd",
  "Major 3rd",
  "4th Interval",
  "5th Interval",
  "Octave"
];
