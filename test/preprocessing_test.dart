import 'package:flutter_test/flutter_test.dart';
import 'package:mensacare/services/preprocessing.dart';

void main() {
  group('Preprocessing helpers', () {
    test('normalizeIntensity clamps and scales correctly', () {
      expect(normalizeIntensity(0), 0.0);    // min bound
      expect(normalizeIntensity(5), 1.0);    // max bound
      expect(normalizeIntensity(3), 3/5);    // mid-range
      expect(normalizeIntensity(-2), 0.0);   // clamp negative
      expect(normalizeIntensity(10), 1.0);   // clamp overflow
    });

    test('encodeToggle returns 1 for true and 0 for false/null', () {
      expect(encodeToggle(true), 1);
      expect(encodeToggle(false), 0);
      expect(encodeToggle(null), 0);
    });

    test('normalizeSleepHours parses and scales correctly', () {
      expect(normalizeSleepHours('8'), closeTo(8/24, 1e-9));   // normal value
      expect(normalizeSleepHours('0'), 0.0);    // minimum
      expect(normalizeSleepHours('24'), 1.0);   // maximum
      expect(normalizeSleepHours('30'), 1.0);   // clamp overflow
      expect(normalizeSleepHours('abc'), 0.0);  // invalid → default
      expect(normalizeSleepHours(null), 0.0);   // null → default
    });
  });
}
