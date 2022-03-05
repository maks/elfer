import 'dart:ffi';

import '../../midi/e2_data.dart';
import '../../midi/e2_device.dart';
import 'e2_part.dart';
import 'elecmidi_generated.dart';

class E2Pattern {
  final Pointer<PatternType> _patternData;
  final int _dataLength;
  final int indexNumber;

  E2Pattern(this._patternData, this._dataLength, this.indexNumber);

  String get name => _patternData.ref.name.getDartString(18);

  set name(String val) => _patternData.ref.name.setDartString(val, 18);

  double get tempo => (_patternData.ref.tempo1 + (256 * _patternData.ref.tempo2)) / 10;

  set tempo(double val) => _patternData.ref.tempo1 = val.toInt();

  int get swing => _patternData.ref.swing;

  String get scale => factoryScales[_patternData.ref.scale];

  List<int> get data => Pointer<Int8>.fromAddress(_patternData.address).asTypedList(_dataLength);

  List<E2Part> get parts {
    final result = <E2Part>[];
    for (var i = 0; i < E2Part.stepsPerPage; i++) {
      result.add(E2Part(_patternData.ref.part1[i], '$i'));
    }
    return result;
  }
}
