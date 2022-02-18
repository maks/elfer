// needed to access extension for "[]" operator on Array, eg for stepdata note prop
import 'dart:ffi' as ffi;

import '../elecmidi_generated.dart';

class E2Step {
  final StepType _stepData;

  ///  0,1~128=Off,Note No 0~127
  List<int> get notes => [
        _stepData.note[0],
        _stepData.note[1],
        _stepData.note[2],
        _stepData.note[3],
      ];

  bool get stepOn => _stepData.onOff == 1;

  bool get trigger => _stepData.triggerOnOff == 1;

  int get velocity => _stepData.velocity;

  int get gateTime => _stepData.gateTime;

  void setNote(index, value) {
    RangeError.checkValueInInterval(index, 0, 3);
    _stepData.note[index] = value;
  }

  E2Step(this._stepData);
}
