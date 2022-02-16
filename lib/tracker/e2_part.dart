// needed to access extension for "[]" operator on Array, eg for partdata step prop
import 'dart:ffi' as ffi;

import '../elecmidi_generated.dart';
import 'e2_step.dart';

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
