import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../services/database_service.dart';
import '../calendar/calendar_screen.dart';
import '../settings/settings_screen.dart';
import '../symptoms/add_symptoms_screen.dart';

class AbnormalitiesScreen extends StatefulWidget {
  final int? userId;
  final bool withNav;
  const AbnormalitiesScreen({super.key, this.userId, this.withNav = true});

  @override
  State<AbnormalitiesScreen> createState() => _AbnormalitiesScreenState();
}

class _AbnormalitiesScreenState extends State<AbnormalitiesScreen> {
  Map<String, dynamic>? _latestPred;
  String? _topLabel;
  double? _topScore;
  List<Map<String, dynamic>> _topHundred = [];
  List<Map<String, dynamic>> _likely = [];
  bool _loading = true;
  String? _error;
  int _mode = 0; // 0=Results, 1=No Results, 2=All Good
  bool? _seedExact28;
  bool _flagRefreshing = false;
  bool? _hasAnyData; // first-time users have no data yet

  @override
  void initState() {
    super.initState();
    _loadLatest();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadLatest();
  }

  Future<void> _downloadPdf() async {
    if (_latestPred == null) return;
    final raw = _latestPred!['output_json'] as String? ?? '{}';
    Map<String, dynamic> output;
    try {
      final parsed = jsonDecode(raw);
      output = parsed is Map<String, dynamic> ? parsed : <String, dynamic>{};
    } catch (_) { output = <String, dynamic>{}; }

    List<dynamic> predsDyn = [];
    if (output['preds'] is List) predsDyn = output['preds'] as List;
    else if (output['predictions'] is List) predsDyn = output['predictions'] as List;
    final preds = predsDyn
        .whereType<Map>()
        .map((m) => m.map((k, v) => MapEntry(k.toString(), v)))
        .toList();
    preds.sort((a, b) {
      final as = (a['score'] is num) ? (a['score'] as num).toDouble() : double.tryParse('${a['score']}') ?? 0.0;
      final bs = (b['score'] is num) ? (b['score'] as num).toDouble() : double.tryParse('${b['score']}') ?? 0.0;
      return bs.compareTo(as);
    });

    final doc = pw.Document();
    final title = 'Abnormalities Report';
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (ctx) => [
          pw.Text(title, style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Text('Generated: ${DateTime.now()}'),
          pw.SizedBox(height: 12),
          if (_topHundred.isNotEmpty) ...[
            pw.Text('High Confidence Findings (100%)', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 6),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: _topHundred.map((p) => pw.Bullet(text: 'Possible ${p['label']} (100%)')).toList(),
            ),
            pw.SizedBox(height: 12),
          ] else if (_topLabel != null && _topLabel!.isNotEmpty) ...[
            pw.Text('Top Finding', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 6),
            pw.Text('Possible ${_topLabel!} (${((_topScore ?? 0.0) * 100).toStringAsFixed(1)}%)'),
            pw.SizedBox(height: 12),
          ],
          pw.Text('Details', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Table.fromTextArray(
            headers: const ['Condition', 'Score'],
            data: preds.map((p) {
              final label = (p['label'] ?? '').toString();
              final s = (p['score'] is num) ? (p['score'] as num).toDouble() : double.tryParse('${p['score']}') ?? 0.0;
              return [label, '${(s * 100).toStringAsFixed(1)}%'];
            }).toList(),
          ),
          pw.SizedBox(height: 16),
          pw.Text('*This report is not a medical diagnosis. Consult a qualified medical professional for advice.', style: pw.TextStyle(color: PdfColors.red, fontSize: 10)),
        ],
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/abnormalities_report_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await doc.save());

    try {
      await Share.shareXFiles([XFile(file.path)], text: 'Abnormalities Report');
    } catch (_) {
      // ignore share errors
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Report saved to ${file.path}')),
    );
  }

  Future<void> _loadLatest() async {
    if (widget.userId == null) {
      setState(() {
        _error = 'Please login to view predictions.';
        _loading = false;
      });
      return;
    }
    try {
      await DatabaseService.instance.init();
      bool showAllGood = false;
      try {
        final v = await DatabaseService.instance.getAppFlagBool(key: 'seed_exact28');
        showAllGood = (v == true);
      } catch (_) {}
      if (mounted) {
        setState(() {
          _seedExact28 = showAllGood;
          _mode = showAllGood ? 2 : 0;
        });
      }
      final db = DatabaseService.instance.db;
      // Determine if this is a first-time user with no data/logs/predictions
      final hasSym = await db.query('symptoms_logs', where: 'user_id = ?', whereArgs: [widget.userId], limit: 1);
      final hasPred0 = await db.query('model_predictions', where: 'user_id = ?', whereArgs: [widget.userId], limit: 1);
      final hasAny = hasSym.isNotEmpty || hasPred0.isNotEmpty;
      if (mounted) {
        setState(() { _hasAnyData = hasAny; });
      }
      if (!hasAny) {
        setState(() {
          _latestPred = null;
          _loading = false;
        });
        return;
      }
      final rows = await db.query(
        'model_predictions',
        where: 'user_id = ?',
        whereArgs: [widget.userId],
        orderBy: 'created_at DESC',
        limit: 10,
      );
      if (rows.isEmpty) {
        setState(() {
          _latestPred = null;
          _loading = false;
        });
        return;
      }
      // We'll iterate recent rows to find the latest one that contains usable predictions
      Map<String, dynamic>? chosen;
      Map<String, dynamic> output = <String, dynamic>{};
      List<dynamic> predsDyn = [];
      for (final r in rows) {
        final candidate = Map<String, dynamic>.from(r);
        final raw0 = candidate['output_json'] as String? ?? '{}';
        Map<String, dynamic> out0;
        try {
          final parsed = jsonDecode(raw0);
          out0 = parsed is Map<String, dynamic> ? parsed : <String, dynamic>{};
        } catch (_) { out0 = <String, dynamic>{}; }
        List<dynamic> pd0 = [];
        if (out0['preds'] is List) pd0 = out0['preds'] as List;
        else if (out0['predictions'] is List) pd0 = out0['predictions'] as List;
        if (pd0.isNotEmpty) {
          chosen = candidate;
          output = out0;
          predsDyn = pd0;
          break;
        }
      }
      // If none had preds, fall back to the latest row
      chosen ??= Map<String, dynamic>.from(rows.first);
      if (predsDyn.isEmpty) {
        final rawFallback = chosen!['output_json'] as String? ?? '{}';
        try {
          final parsed = jsonDecode(rawFallback);
          output = parsed is Map<String, dynamic> ? parsed : <String, dynamic>{};
        } catch (_) { output = <String, dynamic>{}; }
        if (output['preds'] is List) predsDyn = output['preds'] as List;
        else if (output['predictions'] is List) predsDyn = output['predictions'] as List;
      }
      final pred = chosen!;
      final raw = pred['output_json'] as String? ?? '{}';
      try {
        final parsed = jsonDecode(raw);
        output = parsed is Map<String, dynamic> ? parsed : <String, dynamic>{};
      } catch (_) {
        output = <String, dynamic>{};
      }
      // Tolerant parse: accept Map of any key type; coerce keys to String; parse numbers from num or String
      final List<Map<String, dynamic>> preds = [];
      for (final item in predsDyn) {
        if (item is Map) {
          final m = item.map((k, v) => MapEntry(k.toString(), v));
          final label = (m['label'] ?? '').toString();
          double parseNum(dynamic v) {
            if (v is num) return v.toDouble();
            final s = ('$v').trim().replaceAll('%', '');
            final p = double.tryParse(s);
            if (p == null) return 0.0;
            // Normalize if value appears as percentage 0..100
            if (p > 1.0 && p <= 100.0) return p / 100.0;
            return p;
          }
          final score = parseNum(m['score']);
          // optional weighted variants
          final vw = m.containsKey('vweighted') ? parseNum(m['vweighted']) : null;
          final svw = m.containsKey('score_vweighted') ? parseNum(m['score_vweighted']) : null;
          preds.add({
            'label': label,
            'score': score,
            if (vw != null) 'vweighted': vw,
            if (svw != null) 'score_vweighted': svw,
          });
        }
      }

      // Canonical score: prefer vweighted > score_vweighted > score
      double _canonScore(Map<String, dynamic> m) {
        final keys = ['vweighted', 'score_vweighted', 'score'];
        for (final k in keys) {
          final v = m[k];
          if (v is num) return v.toDouble();
          final s = ('$v').trim().replaceAll('%','');
          final p = double.tryParse(s);
          if (p != null) {
            if (p > 1.0 && p <= 100.0) return p / 100.0;
            return p;
          }
        }
        return 0.0;
      }

      preds.sort((a, b) {
        final ascore = _canonScore(a);
        final bscore = _canonScore(b);
        return bscore.compareTo(ascore);
      });

      // Always use the highest scored prediction for the header
      String? label;
      double? score;
      if (preds.isNotEmpty) {
        label = (preds.first['label'] ?? '').toString();
        score = _canonScore(preds.first); // Use canonical score
      }

      final hundred = preds.where((p) {
        final s = _canonScore(p);
        return (s >= 0.9995); // treat as 100%
      }).map((p) => {
            'label': (p['label'] ?? '').toString(),
            'score': _canonScore(p),
          }).toList();

      final likely = preds.where((p) {
        final s = _canonScore(p);
        return s >= 0.75;
      }).map((p) => {
            'label': (p['label'] ?? '').toString(),
            'score': _canonScore(p),
          }).toList();

      setState(() {
        _latestPred = pred;
        _topLabel = label;
        _topScore = score;
        _topHundred = hundred;
        _likely = likely;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgPink = const Color(0xFFF8D6D6);
    final maroon = const Color(0xFF9B4D4B);

    // Post-frame: refresh the flag to reflect the most recent seeding action
    if (!_flagRefreshing) {
      _flagRefreshing = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          await DatabaseService.instance.init();
          final v = await DatabaseService.instance.getAppFlagBool(key: 'seed_exact28');
          bool any = false;
          if (widget.userId != null) {
            final db = DatabaseService.instance.db;
            final sym = await db.query('symptoms_logs', where: 'user_id = ?', whereArgs: [widget.userId], limit: 1);
            final pred = await db.query('model_predictions', where: 'user_id = ?', whereArgs: [widget.userId], limit: 1);
            any = sym.isNotEmpty || pred.isNotEmpty;
          }
          if (mounted) {
            setState(() {
              _seedExact28 = (v == true);
              _mode = _seedExact28 == true ? 2 : 0;
              _hasAnyData = any;
            });
          }
        } catch (_) {}
        if (mounted) {
          setState(() { _flagRefreshing = false; });
        } else {
          _flagRefreshing = false;
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Abnormalities'),
        actions: const [],
      ),
      body: (_seedExact28 == null || _hasAnyData == null)
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : (_hasAnyData == false)
                  ? SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: _NoResultsCard(
                        onLog: () {
                          if (widget.userId == null) return;
                          final now = DateTime.now();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => AddSymptomsScreen(date: now, userId: widget.userId!),
                            ),
                          );
                        },
                      ),
                    )
                  : (_seedExact28 == true)
                  ? SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text('seed_exact28=${_seedExact28 == true}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                          ),
                          _AllGoodSection(),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text('seed_exact28=${_seedExact28 == true}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                          ),
                          if (_topHundred.isNotEmpty) ...[
                            ..._topHundred.map((p) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _HeaderCard(
                                    bg: bgPink,
                                    maroon: maroon,
                                    title: 'Possible ${p['label']} Detected',
                                    confidenceText: '(100% Confidence)',
                                  ),
                                )),
                          ] else ...[
                            _HeaderCard(
                              bg: bgPink,
                              maroon: maroon,
                              title: (_topLabel == null || _topLabel!.isEmpty)
                                  ? 'No Abnormalities Detected'
                                  : 'Possible ${_topLabel!} Detected',
                              confidenceText: (_topScore == null)
                                  ? null
                                  : '(${((_topScore!.clamp(0.0, 1.0)) * 100).round()}% Confidence)',
                            ),
                          ],
                          const SizedBox(height: 16),
                          if (_likely.isNotEmpty) ...[
                            Text('Likely conditions (≥ 0.75):', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            ..._likely.map((p) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  child: Row(
                                    children: [
                                      Expanded(child: Text(p['label'] as String)),
                                      Text('${(((p['score'] as double).clamp(0.0, 1.0)) * 100).toStringAsFixed(1)}%'),
                                    ],
                                  ),
                                )),
                            const SizedBox(height: 16),
                          ] else ...[
                            Text('No likely conditions ≥ 0.75', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
                            const SizedBox(height: 16),
                          ],
                          Text(
                            'Our AI has reviewed your cycle history and symptoms over the last few months. Based on your data, the probabilities below summarize potential irregularities for this period. These insights are derived from your tracked patterns and model analysis.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),
                          Text("Here's what we've noticed:", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          const _Bullet('Irregular periods: Cycle lengths vary or months may be skipped.'),
                          const _Bullet('Unpredictable ovulation patterns may be present.'),
                          const _Bullet('Unusual bleeding or spotting has been logged.'),
                          const _Bullet('Recurring symptoms such as weight changes, acne, or fatigue.'),
                          const _Bullet('Mood or energy changes correlated with your cycle.'),
                          const SizedBox(height: 16),
                          const SizedBox(height: 24),
                          Text('Next Steps', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          _ActionRow(bg: bgPink, maroon: maroon, onDownload: _downloadPdf),
                          const SizedBox(height: 12),
                          Text(
                            "*This report is not a medical diagnosis. Our AI provides insights based on your tracked symptoms and patterns. For proper diagnosis and treatment, always consult a qualified medical professional.",
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.red[800]),
                          ),
                        ],
                      ),
                    ),
      bottomNavigationBar: widget.withNav ? BottomNavigationBar(
        backgroundColor: const Color(0xFFF8D6D6),
        elevation: 0,
        selectedItemColor: const Color(0xFF9B4D4B),
        unselectedItemColor: Colors.black54,
        currentIndex: 2,
        onTap: (i) async {
          if (i == 0) {
            Navigator.of(context).pop();
            return;
          }
          if (i == 1) {
            DateTime start = DateTime.now();
            if (widget.userId != null) {
              try {
                final u = await DatabaseService.instance.getUserById(widget.userId!);
                if (u != null) {
                  final lmdStr = u['last_menstrual_day'] as String?;
                  if (lmdStr != null && lmdStr.isNotEmpty) {
                    try { start = DateTime.parse(lmdStr); } catch (_) {}
                  }
                }
              } catch (_) {}
            }
            if (!mounted) return;
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CalendarScreen(startDate: start, userId: widget.userId),
              ),
            );
            return;
          }
          if (i == 3) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => SettingsScreen(userId: widget.userId)),
            );
            return;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: ''),
          BottomNavigationBarItem(icon: ImageIcon(AssetImage('assets/images/egg.png')), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: ''),
        ],
      ) : null,
    );
  }
}

class _ModeToggle extends StatelessWidget {
  final int mode; // 0=Results,1=No Results,2=All Good
  final ValueChanged<int> onChanged;
  const _ModeToggle({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final labels = const ['Results', 'No results', 'All good'];
    return Center(
      child: ToggleButtons(
        borderRadius: BorderRadius.circular(12),
        isSelected: [0,1,2].map((i) => i == mode).toList(),
        onPressed: (i) => onChanged(i),
        children: labels.map((t) => Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), child: Text(t))).toList(),
      ),
    );
  }
}

class _NoResultsCard extends StatelessWidget {
  final VoidCallback onLog;
  const _NoResultsCard({required this.onLog});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFFFFEAEA), borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/images/cherry-blossom.png', height: 64, fit: BoxFit.contain),
            const SizedBox(height: 8),
            const Text('No result yet!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            const Text(
              'Log your daily symptoms and cycle details to help us analyze your data and check for any abnormalities. The more consistent you are, the smarter your health insights become!',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onLog,
              child: const Text('Log Symptoms'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AllGoodSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(child: Image.asset('assets/images/check.png', height: 48, fit: BoxFit.contain)),
        const SizedBox(height: 8),
        const Center(child: Text("You're All Good", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18))),
        const SizedBox(height: 12),
        const Text(
          'Based on your cycle data and symptoms, everything looks healthy and within normal ranges. Great job taking care of yourself!',
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Color(0xFFFFF2F2), borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('What we checked:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 6),
              _Bullet('Your cycle length is consistent.'),
              _Bullet('No signs of skipped ovulation or unusual spotting.'),
              _Bullet('Symptoms are mild or within expected ranges.'),
              _Bullet('No irregularities or health concerns detected by our AI.'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Color(0xFFFFF2F2), borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('What You Can Do Next:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 6),
              _Bullet('Keep logging daily to stay aware of changes.'),
              _Bullet('View tips to stay healthy and reduce stress.'),
              _Bullet('Download report if you need to share with your doctor.'),
              _Bullet('Learn more about what’s normal in the menstrual cycle.'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Keep going! Your health journey is important. Stay consistent and kind to yourself — understanding your body is powerful.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final Color bg;
  final Color maroon;
  final String title;
  final String? confidenceText;
  const _HeaderCard({required this.bg, required this.maroon, required this.title, this.confidenceText});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_circle_rounded, color: maroon, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                if (confidenceText != null) ...[
                  const SizedBox(height: 4),
                  Text(confidenceText!, style: TextStyle(color: maroon, fontWeight: FontWeight.w600)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet(this.text);
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('•  '),
        Expanded(child: Text(text)),
      ],
    );
  }
}

class _ScoresList extends StatelessWidget {
  final String outputJson;
  const _ScoresList({required this.outputJson});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> output;
    try {
      final parsed = jsonDecode(outputJson);
      output = parsed is Map<String, dynamic> ? parsed : <String, dynamic>{};
    } catch (_) {
      output = <String, dynamic>{};
    }
    List<dynamic> predsDyn = [];
    if (output['preds'] is List) predsDyn = output['preds'] as List;
    else if (output['predictions'] is List) predsDyn = output['predictions'] as List;

    final preds = predsDyn
        .whereType<Map>()
        .map((m) => m.map((k, v) => MapEntry(k.toString(), v)))
        .toList();

    preds.sort((a, b) {
      final ascore = (a['score'] is num) ? (a['score'] as num).toDouble() : double.tryParse('${a['score']}') ?? 0.0;
      final bscore = (b['score'] is num) ? (b['score'] as num).toDouble() : double.tryParse('${b['score']}') ?? 0.0;
      return bscore.compareTo(ascore);
    });

    return Column(
      children: preds.map((p) {
        final label = (p['label'] ?? '').toString();
        final s = (p['score'] is num) ? (p['score'] as num).toDouble() : double.tryParse('${p['score']}') ?? 0.0;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Expanded(child: Text(label)),
              Text('${(s * 100).toStringAsFixed(1)}%'),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final Color bg;
  final Color maroon;
  final VoidCallback onDownload;
  const _ActionRow({required this.bg, required this.maroon, required this.onDownload});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.local_hospital_outlined),
                SizedBox(width: 8),
                Text('Talk to a doctor'),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Material(
            elevation: 1,
            borderRadius: BorderRadius.circular(12),
            child: OutlinedButton.icon(
              onPressed: onDownload,
              icon: Icon(Icons.download_outlined, color: maroon),
              label: Text('Download Report', style: TextStyle(color: maroon)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: maroon),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
