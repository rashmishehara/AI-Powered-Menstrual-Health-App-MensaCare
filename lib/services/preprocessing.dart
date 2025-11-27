// Simple preprocessing helpers used before feeding features to the model.

double normalizeIntensity(int value) {
  // intensity expected 0..5 -> normalize to 0.0..1.0
  final v = value.clamp(0, 5);
  return v / 5.0;
}

int encodeToggle(bool? value) {
  return (value ?? false) ? 1 : 0;
}

double normalizeSleepHours(String? hoursText) {
  if (hoursText == null || hoursText.trim().isEmpty) return 0.0;
  try {
    final d = double.parse(hoursText);
    // assume realistic range 0..24, clamp and scale to 0..1
    final c = d.clamp(0.0, 24.0);
    return c / 24.0;
  } catch (_) {
    return 0.0;
  }
}
