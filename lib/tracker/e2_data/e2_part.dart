// needed to access extension for "[]" operator on Array, eg for partdata step prop
import 'dart:ffi' as ffi;

import 'e2_step.dart';
import 'elecmidi_generated.dart';

class E2Part {
  static const maxSteps = 64;

  final PartType _partData;
  final String _name;

  String get name => _name;

  int get lastStep => _partData.lastStep;

  int get oscillator {
    return (_partData.oscTypeh * 256) + (_partData.oscTypel) + 1; //osc are start at 1 on E2 display
  }

  List<E2Step> get steps {
    final List<E2Step> result = [];
    for (var i = 0; i < maxSteps; i++) {
      result.add(E2Step(_partData.step[i]));
    }
    return result;
  }

  E2Part(
    this._partData,
    this._name,
  );
}
