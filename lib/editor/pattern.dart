import 'dart:ffi';

import '../elecmidi_generated.dart';
import '../midi/e2_device.dart';

class E2Pattern {
  final Pointer<PatternType> _patternData;

  E2Pattern(this._patternData);

  String get name => _patternData.ref.name.getDartString(18);

  List<E2Part> get parts {
    final result = <E2Part>[];
    for (var i = 0; i < 16; i++) {
      result.add(E2Part(_patternData.ref.part1[i], '$i'));
    }

    return result;
  }
}

class E2Part {
  // final String name;
  // final int lastStep;
  // final int voiceAssign;
  // final int oscType;
  // final List<E2Step> steps;

  final PartType _partData;
  final String _name;

  String get name => _name;
  int get lastStep => _partData.lastStep;
  List<E2Step> get steps {
    final List<E2Step> result = [];
    for (var i = 0; i < 16; i++) {
      result.add(E2Step(_partData.step[i]));
    }
    return result;
  }

  E2Part(
    this._partData,
    this._name,
  );
}

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
