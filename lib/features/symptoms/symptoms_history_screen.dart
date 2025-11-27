import 'package:flutter/material.dart';
import 'dart:math';
import '../../services/database_service.dart';
import '../../services/inference_service.dart';
import '../predictions/predictions_screen.dart';

class SymptomsHistoryScreen extends StatefulWidget {
  final int userId;
  final DateTime? currentCycleStart;
  const SymptomsHistoryScreen({super.key, required this.userId, this.currentCycleStart});

  @override
  State<SymptomsHistoryScreen> createState() => _SymptomsHistoryScreenState();
}

class _SymptomsHistoryScreenState extends State<SymptomsHistoryScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _rows = const [];
  String? _error;
  List<String>? _wantedOverride;

  static const List<String> yesNoKeys = [
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

  static const List<String> ratingKeys = [
    'headache',
    'lower_back_pain',
    'pain_during_sex',
    'flow',
    'pelvic_pain',
    'stress',
  ];

  @override
  void initState() {
    super.initState();
    _load().then((_) => _maybeRunModel());
  }

  Future<void> _seedPeriods() async {
    try {
      await DatabaseService.instance.init();
      final db = DatabaseService.instance.db;
      DateTime today = DateTime.now();

      // Fetch user's last_menstrual_day if available
      DateTime? lmd;
      try {
        final rows = await db.query('users', where: 'id = ?', whereArgs: [widget.userId], limit: 1);
        if (rows.isNotEmpty) {
          final s = rows.first['last_menstrual_day'] as String?;
          if (s != null && s.isNotEmpty) {
            lmd = DateTime.tryParse(s);
          }
        }
      } catch (_) {
        // ignore
      }
      // Priority: use current cycle start provided by Calendar -> History navigation
      DateTime? currentStart = widget.currentCycleStart;
      // If not provided, try LMD-based 28-day cycles
      lmd ??= DateTime(today.year, today.month, 1); // fallback to 1st of this month if missing

      if (currentStart == null) {
        // Find the most recent cycle start <= today based on 28-day interval from LMD
        final deltaDays = today.difference(lmd!).inDays;
        final cycles = (deltaDays >= 0) ? (deltaDays ~/ 28) : 0;
        currentStart = lmd!.add(Duration(days: cycles * 28));
      }
      final prev1Start = currentStart.subtract(const Duration(days: 28));
      final prev2Start = currentStart.subtract(const Duration(days: 56));

      // Helper randomizers
      final rng = Random();
      int rInt(int min, int max) => min + rng.nextInt(max - min + 1);
      bool rBool([int p = 50]) => rng.nextInt(100) < p;
      String rWeight() {
        final x = rng.nextInt(3);
        if (x == 0) return 'Weight Loss';
        if (x == 1) return 'Weight Gain';
        return 'Normal';
      }

      Future<void> insertBlock(DateTime start) async {
        for (int d = 0; d < 5; d++) {
          final day = DateTime(start.year, start.month, start.day).add(Duration(days: d));
          final iso = day.toIso8601String().substring(0, 10);
          final toggles = <String, bool>{
            'Smoking / Alcohol': rBool(15),
            'Birth control use': rBool(30),
            'Hair Loss': rBool(25),
            'Acne': rBool(40),
            'Fatigue': rBool(60),
            'Bloating': rBool(55),
            'Nausea': rBool(35),
            'Dizziness': rBool(25),
            'Hot flashes': rBool(15),
            'Irritability': rBool(55),
            'Forgetfulness': rBool(30),
            'Depression': rBool(20),
            'Tension': rBool(45),
            'Social withdrawal': rBool(25),
          };
          final intensity = <String, int>{
            'Headache': rInt(1, 5),
            'Lower back pain': rInt(1, 5),
            'Pain during sex': rInt(1, 5),
            // Emphasize flow during period window
            'Flow': rInt(3, 5),
            'Pelvic pain': rInt(2, 5),
            'Stress': rInt(1, 5),
          };
          await DatabaseService.instance.insertSymptomsLog(
            userId: widget.userId,
            logDateIso: iso,
            sleepHours: rInt(5, 9).toString(),
            weightChange: rWeight(),
            toggles: toggles,
            intensity: intensity,
          );
        }
      }

      // Insert exactly 15 logs (5 days x 3 cycles)
      await insertBlock(currentStart);
      await insertBlock(prev1Start);
      await insertBlock(prev2Start);

      if (!mounted) return;
      try {
        await DatabaseService.instance.setAppFlag(key: 'seed_exact28', value: true);
        final v = await DatabaseService.instance.getAppFlagBool(key: 'seed_exact28');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Seeded 15 days across 3 cycles. seed_exact28=${v == true}')));
      } catch (_) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seeded 15 days across 3 cycles')));
      }
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Seed periods failed: $e')));
    }
  }

  Future<void> _seedRandom15() async {
    try {
      await DatabaseService.instance.init();
      final now = DateTime.now();
      final rng = Random();
      for (int i = 0; i < 15; i++) {
        final d = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
        final iso = d.toIso8601String().substring(0, 10);
        int rInt(int min, int max) => min + rng.nextInt(max - min + 1); // inclusive
        bool rBool([int p = 50]) => rng.nextInt(100) < p; // probability in percent
        String rWeight() {
          final x = rng.nextInt(3);
          if (x == 0) return 'Weight Loss';
          if (x == 1) return 'Weight Gain';
          return 'Normal';
        }

        final toggles = <String, bool>{
          'Smoking / Alcohol': rBool(20),
          'Birth control use': rBool(30),
          'Hair Loss': rBool(30),
          'Acne': rBool(40),
          'Fatigue': rBool(50),
          'Bloating': rBool(40),
          'Nausea': rBool(25),
          'Dizziness': rBool(25),
          'Hot flashes': rBool(20),
          'Irritability': rBool(45),
          'Forgetfulness': rBool(30),
          'Depression': rBool(20),
          'Tension': rBool(35),
          'Social withdrawal': rBool(20),
        };
        final intensity = <String, int>{
          'Headache': rInt(1, 5),
          'Lower back pain': rInt(1, 5),
          'Pain during sex': rInt(1, 5),
          'Flow': rInt(1, 5),
          'Pelvic pain': rInt(1, 5),
          'Stress': rInt(1, 5),
        };

        await DatabaseService.instance.insertSymptomsLog(
          userId: widget.userId,
          logDateIso: iso,
          sleepHours: rInt(4, 9).toString(),
          weightChange: rWeight(),
          toggles: toggles,
          intensity: intensity,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Randomized last 15 days')));
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Randomize failed: $e')));
    }
  }

  Future<void> _seedPeriodsVariable() async {
    try {
      await DatabaseService.instance.init();
      final db = DatabaseService.instance.db;
      DateTime today = DateTime.now();

      DateTime? lmd;
      try {
        final rows = await db.query('users', where: 'id = ?', whereArgs: [widget.userId], limit: 1);
        if (rows.isNotEmpty) {
          final s = rows.first['last_menstrual_day'] as String?;
          if (s != null && s.isNotEmpty) {
            lmd = DateTime.tryParse(s);
          }
        }
      } catch (_) {}

      DateTime? currentStart = widget.currentCycleStart;
      lmd ??= DateTime(today.year, today.month, 1);
      if (currentStart == null) {
        final deltaDays = today.difference(lmd!).inDays;
        final cycles = (deltaDays >= 0) ? (deltaDays ~/ 28) : 0;
        currentStart = lmd!.add(Duration(days: cycles * 28));
      }

      final rng = Random();
      int varGap() {
        const options = [25, 26, 27, 29, 30];
        return options[rng.nextInt(options.length)];
      }
      final gap1 = varGap();
      final gap2 = varGap();
      final prev1Start = currentStart.subtract(Duration(days: gap1));
      final prev2Start = prev1Start.subtract(Duration(days: gap2));

      int rInt(int min, int max) => min + rng.nextInt(max - min + 1);
      bool rBool([int p = 50]) => rng.nextInt(100) < p;
      String rWeight() {
        final x = rng.nextInt(3);
        if (x == 0) return 'Weight Loss';
        if (x == 1) return 'Weight Gain';
        return 'Normal';
      }

      Future<void> insertBlock(DateTime start) async {
        for (int d = 0; d < 5; d++) {
          final day = DateTime(start.year, start.month, start.day).add(Duration(days: d));
          final iso = day.toIso8601String().substring(0, 10);
          final toggles = <String, bool>{
            'Smoking / Alcohol': rBool(15),
            'Birth control use': rBool(30),
            'Hair Loss': rBool(25),
            'Acne': rBool(40),
            'Fatigue': rBool(60),
            'Bloating': rBool(55),
            'Nausea': rBool(35),
            'Dizziness': rBool(25),
            'Hot flashes': rBool(15),
            'Irritability': rBool(55),
            'Forgetfulness': rBool(30),
            'Depression': rBool(20),
            'Tension': rBool(45),
            'Social withdrawal': rBool(25),
          };
          final intensity = <String, int>{
            'Headache': rInt(1, 5),
            'Lower back pain': rInt(1, 5),
            'Pain during sex': rInt(1, 5),
            'Flow': rInt(3, 5),
            'Pelvic pain': rInt(2, 5),
            'Stress': rInt(1, 5),
          };
          await DatabaseService.instance.insertSymptomsLog(
            userId: widget.userId,
            logDateIso: iso,
            sleepHours: rInt(5, 9).toString(),
            weightChange: rWeight(),
            toggles: toggles,
            intensity: intensity,
          );
        }
      }

      final seeded = <String>[];
      for (final start in [currentStart, prev1Start, prev2Start]) {
        for (int d = 0; d < 5; d++) {
          final day = DateTime(start.year, start.month, start.day).add(Duration(days: d));
          seeded.add(day.toIso8601String().substring(0, 10));
        }
      }

      await insertBlock(currentStart);
      await insertBlock(prev1Start);
      await insertBlock(prev2Start);

      if (!mounted) return;
      setState(() {
        _wantedOverride = seeded;
      });
      try {
        await DatabaseService.instance.setAppFlag(key: 'seed_exact28', value: false);
        final v = await DatabaseService.instance.getAppFlagBool(key: 'seed_exact28');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Seeded 15 days across 3 cycles (var gaps: $gap1, $gap2). seed_exact28=${v == true}')));
      } catch (_) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Seeded 15 days across 3 cycles (var gaps: $gap1, $gap2)')));
      }
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Seed periods (var) failed: $e')));
    }
  }

  Future<void> _runModel() async {
    try {
      // Determine current cycle start: prefer navigation-provided start; fallback to LMD-based 28d steps
      final db = DatabaseService.instance.db;
      DateTime today = DateTime.now();
      DateTime? lmd;
      try {
        final u = await db.query('users', where: 'id = ?', whereArgs: [widget.userId], limit: 1);
        if (u.isNotEmpty) {
          final s = u.first['last_menstrual_day'] as String?;
          if (s != null && s.isNotEmpty) lmd = DateTime.tryParse(s);
        }
      } catch (_) {}
      DateTime? currentStart = widget.currentCycleStart;
      lmd ??= DateTime(today.year, today.month, 1);
      if (currentStart == null) {
        final deltaDays = today.difference(lmd!).inDays;
        final cycles = (deltaDays >= 0) ? (deltaDays ~/ 28) : 0;
        currentStart = lmd!.add(Duration(days: cycles * 28));
      }

      // Ensure we keep only one combined prediction: clear previous ones for this user
      await DatabaseService.instance.deletePredictionsForUser(userId: widget.userId);

      await InferenceService.instance.runAndSaveForPeriods(
        userId: widget.userId,
        currentCycleStart: currentStart,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Model run saved to predictions')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Run failed: $e')));
    }
  }

  Future<void> _maybeRunModel() async {
    try {
      final db = DatabaseService.instance.db;
      final now = DateTime.now();
      // Cover last 15 days window (end inclusive today)
      final fifteenDaysAgo = now.subtract(const Duration(days: 14));
      final cutoff = fifteenDaysAgo.toIso8601String().substring(0, 10);
      final recent = await db.query(
        'model_predictions',
        where: 'user_id = ? AND window_end >= ?',
        whereArgs: [widget.userId, cutoff],
        orderBy: 'created_at DESC',
        limit: 1,
      );
      if (recent.isNotEmpty) return;

      final logs = await DatabaseService.instance.getSymptomsLogs(userId: widget.userId, limit: 15);
      if (logs.length < 15) return;

      if (!mounted) return;
      final run = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Run Health Analysis?'),
          content: const Text('You have 15+ days of symptom data. Run the prediction model now?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Not now')),
            ElevatedButton(onPressed: () => Navigator.pop(c, true), child: const Text('Run')),
          ],
        ),
      );
      if (run == true) {
        await _runModel();
      }
    } catch (_) {
      // ignore failures
    }
  }

  Future<void> _cleanupOct1517() async {
    try {
      await DatabaseService.instance.init();
      final year = DateTime.now().year;
      final dates = [
        DateTime(year, 10, 15).toIso8601String().substring(0, 10),
        DateTime(year, 10, 16).toIso8601String().substring(0, 10),
        DateTime(year, 10, 17).toIso8601String().substring(0, 10),
      ];
      final removed = await DatabaseService.instance.deleteSymptomsLogsByDates(
        userId: widget.userId,
        datesIso: dates,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Removed $removed entries (Oct 15–17)')));
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cleanup failed: $e')));
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await DatabaseService.instance.init();
      final db = DatabaseService.instance.db;
      DateTime today = DateTime.now();
      DateTime? lmd;
      try {
        final u = await db.query('users', where: 'id = ?', whereArgs: [widget.userId], limit: 1);
        if (u.isNotEmpty) {
          final s = u.first['last_menstrual_day'] as String?;
          if (s != null && s.isNotEmpty) lmd = DateTime.tryParse(s);
        }
      } catch (_) {}
      List<String> wanted;
      if (_wantedOverride != null && _wantedOverride!.isNotEmpty) {
        wanted = List<String>.from(_wantedOverride!);
      } else {
        DateTime? currentStart = widget.currentCycleStart;
        lmd ??= DateTime(today.year, today.month, 1);
        if (currentStart == null) {
          final deltaDays = today.difference(lmd!).inDays;
          final cycles = (deltaDays >= 0) ? (deltaDays ~/ 28) : 0;
          currentStart = lmd!.add(Duration(days: cycles * 28));
        }
        final prev1Start = currentStart.subtract(const Duration(days: 28));
        final prev2Start = currentStart.subtract(const Duration(days: 56));
        wanted = <String>[];
        for (int d = 0; d < 5; d++) {
          final a = DateTime(currentStart.year, currentStart.month, currentStart.day + d);
          final b = DateTime(prev1Start.year, prev1Start.month, prev1Start.day + d);
          final c = DateTime(prev2Start.year, prev2Start.month, prev2Start.day + d);
          wanted.add(a.toIso8601String().substring(0, 10));
          wanted.add(b.toIso8601String().substring(0, 10));
          wanted.add(c.toIso8601String().substring(0, 10));
        }
      }
      final rows = await DatabaseService.instance.getSymptomsLogs(userId: widget.userId, limit: 400);
      final filtered = rows.where((r) => wanted.contains((r['log_date'] as String?) ?? '')).toList();
      filtered.sort((a, b) => ((b['log_date'] as String?) ?? '').compareTo((a['log_date'] as String?) ?? ''));
      final sortedAll = List<Map<String, dynamic>>.from(rows)
        ..sort((a, b) => ((b['log_date'] as String?) ?? '').compareTo((a['log_date'] as String?) ?? ''));
      final display = filtered.isNotEmpty ? filtered : (sortedAll.length > 15 ? sortedAll.sublist(0, 15) : sortedAll);
      setState(() {
        _rows = display;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Symptoms History'),
        actions: [
          IconButton(
            tooltip: 'View Predictions',
            icon: const Icon(Icons.insights),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PredictionsScreen(userId: widget.userId),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Seed Periods (15d)',
            icon: const Icon(Icons.calendar_month),
            onPressed: _seedPeriods,
          ),
          IconButton(
            tooltip: 'Seed Periods Var (15d)',
            icon: const Icon(Icons.calendar_today_outlined),
            onPressed: _seedPeriodsVariable,
          ),
          IconButton(
            tooltip: 'Run Model',
            icon: const Icon(Icons.auto_graph),
            onPressed: _runModel,
          ),
          IconButton(
            tooltip: 'Seed 15',
            icon: const Icon(Icons.playlist_add),
            onPressed: _seedSamples,
          ),
          IconButton(
            tooltip: 'Remove Oct 15–17',
            icon: const Icon(Icons.cleaning_services_outlined),
            onPressed: _cleanupOct1517,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('Error: $_error'),
                      )
                    ],
                  )
                : _rows.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 120),
                          Center(child: Text('No logs yet.')),
                        ],
                      )
                    : ListView.separated(
                        itemCount: _rows.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (ctx, i) {
                          final r = _rows[i];
                          final date = r['log_date'] as String? ?? '';
                          return ListTile(
                            title: Text(date),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => _showDetails(context, r),
                          );
                        },
                      ),
      ),
    );
  }

  Future<void> _seedSamples() async {
    try {
      await DatabaseService.instance.init();
      final now = DateTime.now();
      final year = now.year;
      final dates = [
        DateTime(year, 10, 10),
        DateTime(year, 10, 11),
        DateTime(year, 10, 12),
        DateTime(year, 10, 13),
        DateTime(year, 10, 14),
      ];
      for (int i = 0; i < dates.length; i++) {
        final d = dates[i];
        final iso = d.toIso8601String().substring(0, 10);
        await DatabaseService.instance.insertSymptomsLog(
          userId: widget.userId,
          logDateIso: iso,
          sleepHours: (6 + (i % 3)).toString(),
          weightChange: i % 3 == 0 ? 'Normal' : (i % 2 == 0 ? 'Weight Gain' : 'Weight Loss'),
          toggles: const {
            'Smoking / Alcohol': false,
            'Birth control use': true,
            'Hair Loss': false,
            'Acne': true,
            'Fatigue': true,
            'Bloating': false,
            'Nausea': false,
            'Dizziness': false,
            'Hot flashes': false,
            'Irritability': true,
            'Forgetfulness': false,
            'Depression': false,
            'Tension': false,
            'Social withdrawal': false,
          },
          intensity: {
            'Headache': (i % 5) + 1,
            'Lower back pain': ((i + 2) % 5) + 1,
            'Pain during sex': ((i + 3) % 5) + 1,
            'Flow': ((i + 1) % 5) + 1,
            'Pelvic pain': ((i + 4) % 5) + 1,
            'Stress': ((i + 1) % 5) + 1,
          },
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seeded Oct 10–14 logs')));
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Seed failed: $e')));
    }
  }

  void _showDetails(BuildContext context, Map<String, dynamic> r) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (ctx, scroll) {
            return ListView(
              controller: scroll,
              padding: const EdgeInsets.all(16),
              children: [
                Text('Date: ${r['log_date'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                _section('Lifestyle', [
                  'Sleep hours: ${r['sleep_hours'] ?? ''}',
                  'Weight changes: ${r['weight_change'] ?? ''}',
                ]),
                const SizedBox(height: 12),
                _section('Yes / No', yesNoKeys.map((k) => '${k.replaceAll('_', ' ')}: ${((r[k] as int?) ?? 0) == 1 ? 'Yes' : 'No'}').toList()),
                const SizedBox(height: 12),
                _section('Ratings (1-5)', ratingKeys.map((k) => '${k.replaceAll('_', ' ')}: ${(r[k] as int?) ?? 0}').toList()),
              ],
            );
          },
        );
      },
    );
  }

  Widget _section(String title, List<String> lines) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        ...lines.map((t) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Text(t),
            )),
      ],
    );
  }
}
