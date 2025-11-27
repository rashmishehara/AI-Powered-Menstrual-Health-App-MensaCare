import 'dart:math';

import 'database_service.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;

class InferenceService {
  InferenceService._();
  static final InferenceService instance = InferenceService._();

  // Feature order per model spec (1 x 24 float32):
  // 0: sleep_hours (avg)
  // 1: weight_loss (one-hot, majority in window)
  // 2: weight_gain (one-hot)
  // 3: weight_normal (one-hot)
  // 4: smoking_alcohol (present if any day true)
  // 5: birth_control_use
  // 6: hair_loss
  // 7: acne
  // 8: fatigue
  // 9: bloating
  // 10: nausea
  // 11: dizziness
  // 12: hot_flashes
  // 13: headache (avg 1-5)
  // 14: lower_back_pain (avg 1-5)
  // 15: pain_during_sex (avg 1-5)
  // 16: flow (avg 1-5)
  // 17: pelvic_pain (avg 1-5)
  // 18: irritability (present if any day true)
  // 19: forgetfulness (present)
  // 20: depression (present)
  // 21: tension (present)
  // 22: social_withdrawal (present)
  // 23: stress (avg 1-5)
  static const List<String> _toggleCols = [
    'smoking_alcohol',
    'birth_control_use',
    'hair_loss',
    'acne',
    'fatigue',
    'bloating',
    'nausea',
    'dizziness',
    'hot_flashes',
    'irritability',
    'forgetfulness',
    'depression',
    'tension',
    'social_withdrawal',
  ];

  static const List<String> _ratingCols = [
    'headache',
    'lower_back_pain',
    'pain_during_sex',
    'flow',
    'pelvic_pain',
    'stress',
  ];

  Future<Map<String, dynamic>> _getLastNDays({
    required int userId,
    int days = 15,
  }) async {
    final rows = await DatabaseService.instance.getSymptomsLogs(userId: userId, limit: days);
    final ordered = rows.reversed.take(days).toList(); // oldest -> newest
    return {'rows': ordered};
  }

  Future<void> runAndSaveForPeriods({
    required int userId,
    required DateTime currentCycleStart,
    int daysPerCycle = 5,
    int cycles = 3,
    int cycleGapDays = 28,
    String modelName = 'mensus_multilabel_weighted.tflite',
  }) async {
    // Build the exact 15 dates: currentCycleStart..+4, and two prior cycles 28 and 56 days back
    final dates = <DateTime>[];
    for (int c = 0; c < cycles; c++) {
      final start = currentCycleStart.subtract(Duration(days: c * cycleGapDays));
      for (int d = 0; d < daysPerCycle; d++) {
        dates.add(DateTime(start.year, start.month, start.day + d));
      }
    }
    // Oldest to newest for aggregation
    dates.sort();

    // Collect rows for those dates
    final selectedRows = <Map<String, dynamic>>[];
    for (final day in dates) {
      final iso = day.toIso8601String().substring(0, 10);
      final r = await DatabaseService.instance.getSymptomsLogByDate(userId: userId, logDateIso: iso);
      if (r != null) selectedRows.add(r);
    }

    if (selectedRows.isEmpty) {
      throw Exception('No logs found for selected period dates');
    }

    // Reuse aggregation pipeline by temporarily mocking _getLastNDays result
    // Aggregate to 1x24 vector
    double avg(List<double> xs) => xs.isEmpty ? 0.0 : xs.reduce((a,b)=>a+b)/xs.length;
    double propTrue(List<int> xs) => xs.isEmpty ? 0.0 : xs.where((e)=>e==1).length / xs.length;

    final sleep = <double>[];
    int wLoss = 0, wGain = 0, wNormal = 0;
    final tmap = {for (final k in _toggleCols) k: <int>[]};
    final rmap = {for (final k in _ratingCols) k: <double>[]};

    for (final r in selectedRows) {
      final sh = double.tryParse((r['sleep_hours'] as String?) ?? '') ?? 0.0;
      sleep.add(sh);
      final wc = (r['weight_change'] as String?) ?? '';
      if (wc == 'Weight Loss') wLoss++; else if (wc == 'Weight Gain') wGain++; else wNormal++;
      for (final k in _toggleCols) { tmap[k]!.add(((r[k] as int?) ?? 0)); }
      for (final k in _ratingCols) { rmap[k]!.add(((r[k] as int?) ?? 0).toDouble()); }
    }

    final vec = <double>[];
    vec.add(avg(sleep) / 12.0);
    final maxW = max(wLoss, max(wGain, wNormal));
    vec.add(wLoss == maxW ? 1.0 : 0.0);
    vec.add(wGain == maxW ? 1.0 : 0.0);
    vec.add(wNormal == maxW ? 1.0 : 0.0);
    for (final k in _toggleCols) { vec.add(propTrue(tmap[k]!)); }
    for (final k in ['headache','lower_back_pain','pain_during_sex','flow','pelvic_pain']) {
      vec.add(avg(rmap[k]!) / 5.0);
    }
    final v = <double>[];
    v.add(vec[0]);
    v.addAll(vec.sublist(1,4));
    final preToggleKeys = [
      'smoking_alcohol','birth_control_use','hair_loss','acne','fatigue','bloating','nausea','dizziness','hot_flashes'
    ];
    for (final k in preToggleKeys) { v.add(propTrue(tmap[k]!)); }
    for (final k in ['headache','lower_back_pain','pain_during_sex','flow','pelvic_pain']) { v.add(avg(rmap[k]!) / 5.0); }
    for (final k in ['irritability','forgetfulness','depression','tension','social_withdrawal']) { v.add(propTrue(tmap[k]!)); }
    v.add(avg(rmap['stress']!) / 5.0);

    // Run TFLite
    const labels = [
      'PMS_PMDD','PCOS','Menorrhagia','Amenorrhea','Endometriosis','Thyroid_Disorders','Perimenopause','Anemia','Hormonal_Imbalance'
    ];
    final interpreter = await tfl.Interpreter.fromAsset('assets/models/' + modelName);
    final input = [v.map((e) => e.toDouble()).toList()];
    final output = List.generate(1, (_) => List<double>.filled(9, 0.0));
    interpreter.run(input, output);
    final raw = List<double>.from(output[0]);
    bool needsSigmoid = raw.any((x) => x < 0.0 || x > 1.0);
    final preds = raw
        .map((x) => needsSigmoid ? (1.0 / (1.0 + exp(-x))) : x)
        .map((x) => x.clamp(0.0, 1.0))
        .toList();

    final out = {
      'engine': 'tflite',
      'input_vector_len': v.length,
      'input_vector': input[0],
      'raw_outputs': raw,
      'preds': List.generate(labels.length, (i) => {'label': labels[i], 'score': preds[i]}),
    };

    final windowStartIso = dates.first.toIso8601String().substring(0, 10);
    final windowEndIso = dates.last.toIso8601String().substring(0, 10);
    await DatabaseService.instance.saveModelPrediction(
      userId: userId,
      modelName: modelName,
      windowStartIso: windowStartIso,
      windowEndIso: windowEndIso,
      output: out,
    );
  }

  // Stubbed model runner: Computes simple aggregates as a placeholder.
  // Replace with real TFLite inference once tflite_flutter is added and model is bundled.
  Future<Map<String, dynamic>> runModelOnWindow({
    required int userId,
    int days = 15,
    String modelName = 'mensus_multilabel_weighted.tflite',
  }) async {
    final data = await _getLastNDays(userId: userId, days: days);
    final rows = (data['rows'] as List).cast<Map<String, dynamic>>();
    if (rows.isEmpty) {
      return {
        'engine': 'stub',
        'reason': 'no data',
        'predictions': <String, dynamic>{},
      };
    }
    // Aggregate to 1x24 vector
    double avg(List<double> xs) => xs.isEmpty ? 0.0 : xs.reduce((a,b)=>a+b)/xs.length;
    double propTrue(List<int> xs) => xs.isEmpty ? 0.0 : xs.where((e)=>e==1).length / xs.length;

    final sleep = <double>[];
    int wLoss = 0, wGain = 0, wNormal = 0;
    final tmap = {for (final k in _toggleCols) k: <int>[]};
    final rmap = {for (final k in _ratingCols) k: <double>[]};

    for (final r in rows) {
      final sh = double.tryParse((r['sleep_hours'] as String?) ?? '') ?? 0.0;
      sleep.add(sh);
      final wc = (r['weight_change'] as String?) ?? '';
      if (wc == 'Weight Loss') wLoss++; else if (wc == 'Weight Gain') wGain++; else wNormal++;
      for (final k in _toggleCols) { tmap[k]!.add(((r[k] as int?) ?? 0)); }
      for (final k in _ratingCols) { rmap[k]!.add(((r[k] as int?) ?? 0).toDouble()); }
    }

    // Compose vector in exact order
    final vec = <double>[];
    vec.add(avg(sleep) / 12.0); // 0 sleep_hours normalized 0..1 (assuming max 12)
    // one-hot by majority
    final maxW = max(wLoss, max(wGain, wNormal));
    vec.add(wLoss == maxW ? 1.0 : 0.0); // 1 weight_loss
    vec.add(wGain == maxW ? 1.0 : 0.0); // 2 weight_gain
    vec.add(wNormal == maxW ? 1.0 : 0.0); // 3 weight_normal
    // toggles
    for (final k in _toggleCols) { vec.add(propTrue(tmap[k]!)); }
    // ratings avg (1..5)
    for (final k in ['headache','lower_back_pain','pain_during_sex','flow','pelvic_pain']) {
      vec.add(avg(rmap[k]!) / 5.0); // normalize 0..1
    }
    // position 18..22 are five toggles at end of _toggleCols? We already added all 14 toggles earlier.
    // The spec positions after pain ratings are: irritability, forgetfulness, depression, tension, social_withdrawal, then stress.
    // We've already included all toggles in order, which placed those before pain ratings; adjust: rebuild in exact order:
    // Rebuild respecting spec strictly
    final v = <double>[];
    v.add(vec[0]); // sleep
    v.addAll(vec.sublist(1,4)); // weight one-hot
    // toggles up to hot_flashes
    final preToggleKeys = [
      'smoking_alcohol','birth_control_use','hair_loss','acne','fatigue','bloating','nausea','dizziness','hot_flashes'
    ];
    for (final k in preToggleKeys) { v.add(propTrue(tmap[k]!)); }
    // 5 pain/flow ratings
    for (final k in ['headache','lower_back_pain','pain_during_sex','flow','pelvic_pain']) { v.add(avg(rmap[k]!) / 5.0); }
    // remaining toggles
    for (final k in ['irritability','forgetfulness','depression','tension','social_withdrawal']) { v.add(propTrue(tmap[k]!)); }
    // stress rating last
    v.add(avg(rmap['stress']!) / 5.0);

    // Try real TFLite model run first
    const labels = [
      'PMS_PMDD','PCOS','Menorrhagia','Amenorrhea','Endometriosis','Thyroid_Disorders','Perimenopause','Anemia','Hormonal_Imbalance'
    ];
    final interpreter = await tfl.Interpreter.fromAsset('assets/models/' + modelName);
    final input = [v.map((e) => e.toDouble()).toList()]; // [1,24]
    final output = List.generate(1, (_) => List<double>.filled(9, 0.0)); // [1,9]
    interpreter.run(input, output);
    final raw = List<double>.from(output[0]);
    // If model outputs logits, convert to probabilities via sigmoid.
    bool needsSigmoid = raw.any((x) => x < 0.0 || x > 1.0);
    final preds = raw
        .map((x) => needsSigmoid ? (1.0 / (1.0 + exp(-x))) : x)
        .map((x) => x.clamp(0.0, 1.0))
        .toList();
    return {
      'engine': 'tflite',
      'input_vector_len': v.length,
      'input_vector': input[0],
      'raw_outputs': raw,
      'preds': List.generate(labels.length, (i) => {'label': labels[i], 'score': preds[i]}),
    };
  }

  Future<void> runAndSave({
    required int userId,
    int days = 15,
    String modelName = 'mensus_multilabel_weighted.tflite',
  }) async {
    final windowEnd = DateTime.now();
    final windowStart = windowEnd.subtract(Duration(days: days - 1));
    final out = await runModelOnWindow(userId: userId, days: days, modelName: modelName);
    await DatabaseService.instance.saveModelPrediction(
      userId: userId,
      modelName: modelName,
      windowStartIso: windowStart.toIso8601String().substring(0, 10),
      windowEndIso: windowEnd.toIso8601String().substring(0, 10),
      output: out,
    );
  }
}
