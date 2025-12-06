import 'package:flutter/material.dart';
import '../../services/database_service.dart';

class AddSymptomsScreen extends StatefulWidget {
  final DateTime date;
  final int? userId;
  final void Function(DateTime)? onPeriodDateChanged;
  const AddSymptomsScreen({
    super.key,
    required this.date,
    this.userId,
    this.onPeriodDateChanged,
  });

  @override
  State<AddSymptomsScreen> createState() => _AddSymptomsScreenState();
}

class _AddSymptomsScreenState extends State<AddSymptomsScreen> {
  final Set<String> _selected = {};
  double _pain = 0;
  final _notes = TextEditingController();
  bool _saving = false;
  late DateTime _periodStart;
  final _sleepController = TextEditingController();
  String _weightChange = '';
  // Yes/No toggles exactly as earlier naming
  final Map<String, bool> _toggles = {
    'Smoking / Alcohol': false,
    'Birth control use': false,
    'Hair Loss': false,
    'Acne': false,
    'Fatigue': false,
    'Bloating': false,
    'Nausea': false,
    'Dizziness': false,
    'Hot flashes': false,
    'Irritability': false,
    'Forgetfulness': false,
    'Depression': false,
    'Tension': false,
    'Social withdrawal': false,
  };
  // 1-5 intensity scales exactly as earlier naming
  final Map<String, int> _intensity = {
    'Headache': 0,
    'Lower back pain': 0,
    'Pain during sex': 0,
    'Flow': 0,
    'Pelvic pain': 0,
    'Stress': 0,
  };

  List<String> get _symptomOptions => const [
    'Cramps',
    'Headache',
    'Back pain',
    'Bloating',
    'Acne',
    'Fatigue',
    'Mood swings',
    'Nausea',
    'Breast tenderness',
    'Food cravings',
  ];

  String _monthName(int m) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[m - 1];
  }

  Future<void> _save() async {
    if (widget.userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User missing. Please re-login.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final logDate = widget.date.toIso8601String().substring(0, 10);
      await DatabaseService.instance.insertSymptomsLog(
        userId: widget.userId!,
        logDateIso: logDate,
        sleepHours: _sleepController.text.trim(),
        weightChange: _weightChange,
        toggles: _toggles,
        intensity: _intensity,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Symptoms saved.')));
      Navigator.pop(context, {
        'date': logDate,
        'sleep_hours': _sleepController.text.trim(),
        'weight_change': _weightChange,
        'toggles': _toggles,
        'intensity': _intensity,
      });
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _notes.dispose();
    _sleepController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _periodStart = widget.date;
  }

  List<DateTime> _weekFor(DateTime d) {
    // Monday-start week
    final int weekday = d.weekday; // Mon=1..Sun=7
    final monday = d.subtract(Duration(days: weekday - 1));
    return List.generate(
      7,
      (i) => DateTime(monday.year, monday.month, monday.day + i),
    );
  }

  bool _isPeriodDay(DateTime day) {
    final start = DateTime(
      _periodStart.year,
      _periodStart.month,
      _periodStart.day,
    );
    for (int i = 0; i < 5; i++) {
      final d = start.add(Duration(days: i));
      if (d.year == day.year && d.month == day.month && d.day == day.day)
        return true;
    }
    return false;
  }

  Future<void> _editPeriod() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _periodStart,
      firstDate: DateTime(_periodStart.year - 2),
      lastDate: DateTime(_periodStart.year + 2),
    );
    if (picked != null) {
      setState(() => _periodStart = picked);
      widget.onPeriodDateChanged?.call(picked);
    }
  }

  void _addNotes() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final s = MediaQuery.of(ctx).size.width / 360.0;
        return Padding(
          padding: EdgeInsets.fromLTRB(
            16 * s,
            12 * s,
            16 * s,
            16 + MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add Notes',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _notes,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Write your notes here... ',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD16B6B),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? const Color(0xFFD16B6B) : Colors.black38,
          ),
          color: selected ? const Color(0xFFFFE4E4) : Colors.white,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFFD16B6B) : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _yesNoRow(String title, String key) {
    final v = _toggles[key] ?? false;
    return Row(
      children: [
        Expanded(child: Text(title)),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            OutlinedButton(
              onPressed: () => setState(() => _toggles[key] = true),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                minimumSize: const Size(56, 32),
                visualDensity: VisualDensity.compact,
                side: BorderSide(
                  color: v ? const Color(0xFFD16B6B) : Colors.black38,
                ),
                backgroundColor: v ? const Color(0xFFFFE4E4) : null,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4),),
              ),
              child: const Text('Yes'),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () => setState(() => _toggles[key] = false),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                minimumSize: const Size(56, 32),
                visualDensity: VisualDensity.compact,
                side: BorderSide(
                  color: !v ? const Color(0xFFD16B6B) : Colors.black38,
                ),
                backgroundColor: !v ? const Color(0xFFFFE4E4) : null,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4),),
              ),
              child: const Text('No'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _intensityRow(String title, String key, {int max = 5}) {
    final val = _intensity[key] ?? 0;
    return Row(
      children: [
        Expanded(child: Text(title)),
        Row(
          children: List.generate(max, (i) {
            final selected = i < val;
            return IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              onPressed: () => setState(() => _intensity[key] = i + 1),
              icon: Icon(
                Icons.water_drop_outlined,
                color: selected ? const Color(0xFFD16B6B) : Colors.black26,
              ),
            );
          }),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size.width / 360.0;
    final week = _weekFor(widget.date);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            width: double.infinity, // Full screen width
            color: const Color(0xFFFFEEEE), // Pink background
            padding: EdgeInsets.fromLTRB(
              16 * s,
              MediaQuery.of(context).padding.top + 12 * s,
              16 * s,
              12 * s,
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 40,
                  child: Stack(
                    children: [
                      Center(
                        child: Text(
                          'Today',
                          style: TextStyle(
                            fontSize: 18 * s,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _saving ? null : _save,
                          child: const Text('Done'),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 6 * s),

                // Weekday names
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Mon'),
                    Text('Tue'),
                    Text('Wed'),
                    Text('Thu'),
                    Text('Fri'),
                    Text('Sat'),
                    Text('Sun'),
                  ],
                ),

                SizedBox(height: 6 * s),

                // Dates row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: week.map((d) {
                    final isPeriod = _isPeriodDay(d);
                    return Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isPeriod
                            ? const Color(0xFFD16B6B)
                            : Colors.transparent,
                        border: Border.all(
                          color: const Color(0xFFD16B6B).withOpacity(0.5),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${d.day}',
                        style: TextStyle(
                          color: isPeriod ? Colors.white : Colors.black,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16 * s, 11 * s, 16 * s, 24 * s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _editPeriod,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFEEEE),
                            foregroundColor: Color(0x89600000),
                            side: const BorderSide(color: Color(0x89600000)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: const Text('Edit Period'),
                        ),
                      ),
                      SizedBox(width: 11 * s),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _addNotes,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1976D2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            6,
                          ), // smaller radius
                        ),
                      ),
                      child: const Text('Add Notes'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8 * s),
              Row(
                children: const [
                  Icon(Icons.search, size: 15, color: Color(0x89600000)),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Your entries help us detect early signs of imbalance, it only takes a minute!',
                      style: TextStyle(
                        color: Color(0x89600000),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),
              const Text(
                'Lifestyle Symptoms',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Expanded(child: Text('Sleep hours')),
                  SizedBox(
                    height: 36,
                    width: 120,
                    child: TextField(
                      controller: _sleepController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        isDense: true,
                        hintText: 'Input (hrs)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Expanded(child: Text('Weight changes')),
                  _chip(
                    'Weight Loss',
                    _weightChange == 'Weight Loss',
                    () => setState(() => _weightChange = 'Weight Loss'),
                  ),
                  const SizedBox(width: 7),
                  _chip(
                    'Weight Gain',
                    _weightChange == 'Weight Gain',
                    () => setState(() => _weightChange = 'Weight Gain'),
                  ),
                  const SizedBox(width: 7),
                  _chip(
                    'Normal',
                    _weightChange == 'Normal',
                    () => setState(() => _weightChange = 'Normal'),
                  ),
                ],
              ),
              _yesNoRow('Smoking / Alcohol', 'Smoking / Alcohol'),
              _yesNoRow('Birth control use', 'Birth control use'),
              _yesNoRow('Hair Loss', 'Hair Loss'),

              const SizedBox(height: 16),
              const Divider(color: const Color(0xFFFFE4E4), thickness: 1),
              const SizedBox(height: 16),
              const Text(
                'Physical Symptoms',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              _intensityRow('Headache', 'Headache'),
              _intensityRow('Lower back pain', 'Lower back pain'),
              _intensityRow('Pain during sex', 'Pain during sex'),
              _intensityRow('Flow', 'Flow'),
              _intensityRow('Pelvic pain', 'Pelvic pain'),
              _yesNoRow('Acne', 'Acne'),
              _yesNoRow('Fatigue', 'Fatigue'),
              _yesNoRow('Bloating', 'Bloating'),
              _yesNoRow('Nausea', 'Nausea'),
              _yesNoRow('Dizziness', 'Dizziness'),
              _yesNoRow('Hot flashes', 'Hot flashes'),

              const SizedBox(height: 16),
              const Divider(color: const Color(0xFFFFE4E4), thickness: 1),
              const SizedBox(height: 16),
              const Text(
                'Mental Symptoms',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              _intensityRow('Stress', 'Stress'),
              _yesNoRow('Irritability', 'Irritability'),
              _yesNoRow('Forgetfulness', 'Forgetfulness'),
              _yesNoRow('Depression', 'Depression'),
              _yesNoRow('Tension', 'Tension'),
              _yesNoRow('Social withdrawal', 'Social withdrawal'),

              // Removed Overall Pain level and bottom notes section as requested
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD16B6B),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12 * s),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(_saving ? 'Saving...' : 'Save'),
                ),
              ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
