import 'dart:ffi';

import '../elecmidi_generated.dart';
import '../midi/e2_data.dart';
import '../midi/e2_device.dart';
import 'e2_part.dart';

class E2Pattern {
  final Pointer<PatternType> _patternData;
  final int indexNumber;

  E2Pattern(this._patternData, this.indexNumber);

  String get name => _patternData.ref.name.getDartString(18);

  double get tempo => (_patternData.ref.tempo1 + (256 * _patternData.ref.tempo2)) / 10;

  int get swing => _patternData.ref.swing;

  String get scale => factoryScales[_patternData.ref.scale];

  List<E2Part> get parts {
    final result = <E2Part>[];
    for (var i = 0; i < 16; i++) {
      result.add(E2Part(_patternData.ref.part1[i], '$i'));
    }

    return result;
  }
}
