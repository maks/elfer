// needed to access extension for "[]" operator on Array, eg for stepdata note prop
import 'dart:ffi' as ffi;

import '../elecmidi_generated.dart';

class E2Step {
  // final int note1;
  // final int note2;
  // final int note3;
  // final int note4;
  // final bool stepOn;
  // final int velocity;
  // final bool trigger;
  // final int gateTime;
  final StepType _stepData;

  ///  0,1~128=Off,Note No 0~127
  List<int> get notes => [
        _stepData.note[0],
        _stepData.note[1],
        _stepData.note[2],
        _stepData.note[3],
      ];

  bool get stepOn => _stepData.onOff == 1;

  E2Step(this._stepData);
}
