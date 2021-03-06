// AUTO GENERATED FILE, DO NOT EDIT.
//
// Generated by `package:ffigen`.
import 'dart:ffi' as ffi;

class StepType extends ffi.Struct {
  @ffi.Uint8()
  external int onOff;

  @ffi.Uint8()
  external int gateTime;

  @ffi.Uint8()
  external int velocity;

  @ffi.Uint8()
  external int triggerOnOff;

  @ffi.Array.multi([4])
  external ffi.Array<ffi.Uint8> note;

  @ffi.Array.multi([4])
  external ffi.Array<ffi.Uint8> reserved;
}

class PartType extends ffi.Struct {
  @ffi.Uint8()
  external int lastStep;

  @ffi.Uint8()
  external int mute;

  @ffi.Uint8()
  external int voiceAssign;

  @ffi.Array.multi([5])
  external ffi.Array<ffi.Uint8> fill0;

  @ffi.Uint8()
  external int oscTypel;

  @ffi.Uint8()
  external int oscTypeh;

  @ffi.Array.multi([38])
  external ffi.Array<ffi.Uint8> fill1;

  @ffi.Array.multi([64])
  external ffi.Array<StepType> step;
}

class PatternType extends ffi.Struct {
  @ffi.Array.multi([4])
  external ffi.Array<ffi.Uint8> header;

  @ffi.Array.multi([4])
  external ffi.Array<ffi.Uint8> size;

  @ffi.Array.multi([4])
  external ffi.Array<ffi.Uint8> fill1;

  @ffi.Array.multi([4])
  external ffi.Array<ffi.Uint8> fill2;

  @ffi.Array.multi([18])
  external ffi.Array<ffi.Uint8> name;

  @ffi.Uint8()
  external int tempo1;

  @ffi.Uint8()
  external int tempo2;

  @ffi.Uint8()
  external int swing;

  @ffi.Uint8()
  external int length;

  @ffi.Uint8()
  external int beat;

  @ffi.Uint8()
  external int key;

  @ffi.Uint8()
  external int scale;

  @ffi.Uint8()
  external int chordset;

  @ffi.Uint8()
  external int playlevel;

  @ffi.Uint8()
  external int fill3;

  @ffi.Array.multi([16])
  external ffi.Array<ffi.Uint8> touchScale;

  @ffi.Array.multi([8])
  external ffi.Array<ffi.Uint8> masterFX;

  @ffi.Uint8()
  external int alternate1314;

  @ffi.Uint8()
  external int alternate1516;

  @ffi.Array.multi([8])
  external ffi.Array<ffi.Uint8> fill4;

  @ffi.Array.multi([178])
  external ffi.Array<ffi.Uint8> fill5;

  @ffi.Array.multi([1584])
  external ffi.Array<ffi.Uint8> motionSequence;

  @ffi.Array.multi([208])
  external ffi.Array<ffi.Uint8> fill6;

  @ffi.Array.multi([16])
  external ffi.Array<PartType> part1;

  @ffi.Array.multi([252])
  external ffi.Array<ffi.Uint8> fill7;

  @ffi.Array.multi([4])
  external ffi.Array<ffi.Uint8> footer;

  @ffi.Array.multi([1024])
  external ffi.Array<ffi.Uint8> fill8;
}
