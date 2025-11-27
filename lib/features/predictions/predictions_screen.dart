import 'package:flutter/material.dart';
import 'dart:convert';
import '../../services/database_service.dart';
import '../../services/inference_service.dart';

class PredictionsScreen extends StatefulWidget {
  final int userId;
  const PredictionsScreen({super.key, required this.userId});

  @override
  State<PredictionsScreen> createState() => _PredictionsScreenState();
}

class _PredictionsScreenState extends State<PredictionsScreen> {
  List<Map<String, dynamic>> _predictions = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPredictions();
  }

  Future<void> _loadPredictions() async {
    try {
      final db = DatabaseService.instance.db;
      final rows = await db.query(
        'model_predictions',
        where: 'user_id = ?',
        whereArgs: [widget.userId],
        orderBy: 'created_at DESC',
      );
      setState(() {
        _predictions = rows.map((e) => Map<String, dynamic>.from(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load predictions: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Predictions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cleaning_services_outlined),
            tooltip: 'Deduplicate',
            onPressed: () async {
              try {
                final removed = await DatabaseService.instance.cleanupDuplicatePredictions(userId: widget.userId);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Removed $removed duplicate entries')),
                );
                await _loadPredictions();
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Dedup failed: $e')),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPredictions,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : _predictions.isEmpty
                  ? const Center(child: Text('No predictions yet. Run the model from History.'))
                  : ListView.builder(
                      itemCount: _predictions.length,
                      itemBuilder: (context, index) {
                        final pred = _predictions[index];
                        final raw = pred['output_json'] as String? ?? '{}';
                        Map<String, dynamic> output;
                        try {
                          final parsed = jsonDecode(raw);
                          output = parsed is Map<String, dynamic>
                              ? parsed
                              : <String, dynamic>{};
                        } catch (_) {
                          output = <String, dynamic>{};
                        }
                        // Support both 'preds' and 'predictions' keys
                        List<dynamic> predsDyn = [];
                        if (output['preds'] is List) predsDyn = output['preds'] as List;
                        else if (output['predictions'] is List) predsDyn = output['predictions'] as List;

                        final preds = predsDyn
                            .whereType<Map>()
                            .map((m) => m.map((k, v) => MapEntry(k.toString(), v)))
                            .toList();

                        // Sort by score desc, take top 3 with score >= 0.5 (as num)
                        const threshold = 0.5;
                        preds.sort((a, b) {
                          final ascore = (a['score'] is num) ? (a['score'] as num).toDouble() : double.tryParse('${a['score']}') ?? 0.0;
                          final bscore = (b['score'] is num) ? (b['score'] as num).toDouble() : double.tryParse('${b['score']}') ?? 0.0;
                          return bscore.compareTo(ascore);
                        });
                        final topPreds = preds
                            .take(3)
                            .where((p) {
                              final s = (p['score'] is num) ? (p['score'] as num).toDouble() : double.tryParse('${p['score']}') ?? 0.0;
                              return s >= threshold;
                            })
                            .toList();

                        // Prepare full list of all class scores (sorted desc)
                        final allScores = preds
                            .map((p) {
                              final s = (p['score'] is num)
                                  ? (p['score'] as num).toDouble()
                                  : double.tryParse('${p['score']}') ?? 0.0;
                              return {
                                'label': (p['label'] ?? '').toString(),
                                'score': s,
                              };
                            })
                            .toList();

                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${pred['window_start']} to ${pred['window_end']}',
                                      style: Theme.of(context).textTheme.titleSmall,
                                    ),
                                    Text(
                                      'v${pred['model_name']?.toString().split('_').last.split('.').first ?? '1.0'}',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                if (topPreds.isNotEmpty) ...[
                                  const Text('Likely conditions:', style: TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  ...topPreds.map((p) => Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 2),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                p['label'] as String,
                                                style: const TextStyle(fontWeight: FontWeight.w500),
                                              ),
                                            ),
                                            Text(
                                              '${(((p['score'] is num) ? (p['score'] as num).toDouble() : double.tryParse('${p['score']}') ?? 0.0)).toStringAsFixed(2)}',
                                              style: TextStyle(
                                                color: Theme.of(context).colorScheme.primary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
                                ] else
                                  const Text('No high-confidence predictions', style: TextStyle(fontStyle: FontStyle.italic)),
                                const SizedBox(height: 8),
                                const Divider(height: 16),
                                const Text('All scores (0–1):', style: TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                ...allScores.map((p) => Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 1),
                                      child: Row(
                                        children: [
                                          Expanded(child: Text(p['label'] as String)),
                                          Text((p['score'] as double).toStringAsFixed(3)),
                                        ],
                                      ),
                                    )),
                                if (output['engine'] == 'stub' && output['error'] != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      'Stub used: ${output['error']}',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.orange),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
