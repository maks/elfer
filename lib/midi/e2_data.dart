/// The functions in this library are a Dart port of equivalent functions from:
/// https://github.com/rafamj/elecmidi/blob/main/elecmidi.c
/// and elecmidi.h
/// by "@rafamj" on Github, licensed under GPLv3
library e2_data;

import 'dart:convert';
import 'dart:typed_data';

import '../editor/pattern.dart';

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

// returns 0 on success, -1 for invalid header, -2 invalid footer
void checkData(Uint8List patternData) {
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
E2Pattern patternFromData(List<int> patternData) {
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
