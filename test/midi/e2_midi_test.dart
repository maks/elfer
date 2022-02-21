import 'package:collection/collection.dart';
import 'package:elfer/midi/e2_midi.dart';
import 'package:flutter_test/flutter_test.dart';

const eq = ListEquality<int>();

void main() {
  test('string is padded correctly', () {
    String okString = "a test";
    const paddedSize = 8;
    final result = nullTerminatedStringPadded(paddedSize, okString);
    expect(result.length, paddedSize);
    expect(eq.equals(result.sublist(6), [0, 0]), true);
  });

  test('string is not padded when exact size including null terminator', () {
    String okString = "a test";
    const paddedSize = 7;
    final result = nullTerminatedStringPadded(paddedSize, okString);
    expect(result.length, paddedSize);
    expect(eq.equals(result.sublist(6), [0]), true);
  });

  test('throws when padded size too small for string including null terminator', () {
    String okString = "a test";
    const paddedSize = 6;
    expect(() => nullTerminatedStringPadded(paddedSize, okString), throwsRangeError);
  });
}
