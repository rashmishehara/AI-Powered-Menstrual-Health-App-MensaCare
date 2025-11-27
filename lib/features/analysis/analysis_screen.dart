import 'package:flutter/material.dart';
import '../../services/database_service.dart';

class AnalysisScreen extends StatefulWidget {
  final int userId;
  const AnalysisScreen({super.key, required this.userId});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _cycles = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      await DatabaseService.instance.init();
      final rows = await DatabaseService.instance.getRecentCycles(userId: widget.userId, limit: 6);
      setState(() { _cycles = rows; });
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  Future<void> _seedSamples() async {
    try {
      await DatabaseService.instance.seedSampleCycles(userId: widget.userId);
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sample cycles seeded')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Seed failed: $e')));
    }
  }

  String _fmtDate(String iso) {
    try {
      final d = DateTime.parse(iso);
      const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${d.day} ${months[d.month-1]} ${d.year}';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size.width / 360.0;
    final avgPeriod = _cycles.isEmpty ? null : (_cycles.map((e) => (e['period_length'] as int)).reduce((a,b)=>a+b) / _cycles.length);
    final avgCycle = _cycles.isEmpty ? null : (_cycles.map((e) => (e['cycle_length'] as int)).reduce((a,b)=>a+b) / _cycles.length);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.playlist_add),
            tooltip: 'Seed samples',
            onPressed: _seedSamples,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(16*s, 12*s, 16*s, 24*s),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16*s),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7DCDC),
                          borderRadius: BorderRadius.circular(16*s),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Your Cycle', style: TextStyle(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            const Text('Overview of your cycle'),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _StatTile(
                                    title: (avgPeriod ?? 0).toStringAsFixed(0) + ' Days',
                                    subtitle: 'Period Length',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _StatTile(
                                    title: (avgCycle ?? 0).toStringAsFixed(0) + ' Days',
                                    subtitle: 'Cycle Length',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      const Text('Period History', style: TextStyle(fontWeight: FontWeight.w700)),
                      const Text('Averaging your last 6 cycles'),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12*s),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF6F6),
                          borderRadius: BorderRadius.circular(12*s),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: const [
                                Expanded(child: Text('First Day', style: TextStyle(fontWeight: FontWeight.w600))),
                                SizedBox(width: 12),
                                SizedBox(width: 60, child: Text('Length', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.w600))),
                                SizedBox(width: 12),
                                SizedBox(width: 60, child: Text('Cycle', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.w600))),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ..._cycles.map((c) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      Expanded(child: Text(_fmtDate(c['first_day'] as String))),
                                      const SizedBox(width: 12),
                                      SizedBox(width: 60, child: Text('${c['period_length']}', textAlign: TextAlign.right)),
                                      const SizedBox(width: 12),
                                      SizedBox(width: 60, child: Text('${c['cycle_length']}', textAlign: TextAlign.right)),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String title;
  final String subtitle;
  const _StatTile({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE3E3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
          const SizedBox(height: 4),
          Text(subtitle),
        ],
      ),
    );
  }
}
