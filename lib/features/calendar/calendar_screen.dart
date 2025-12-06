import 'package:flutter/material.dart';
import '../symptoms/add_symptoms_screen.dart';
import '../symptoms/symptoms_history_screen.dart';
import '../settings/settings_screen.dart';
import '../abnormalities/abnormalities_screen.dart';

class CalendarScreen extends StatefulWidget {
  final DateTime startDate; // first day of period
  final int? userId;
  final bool withNav;
  const CalendarScreen({
    super.key,
    required this.startDate,
    this.userId,
    this.withNav = true,
  });

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _visibleMonth;
  late DateTime _start; // selected cycle start date

  @override
  void initState() {
    super.initState();
    _start = widget.startDate;
    _visibleMonth = DateTime(widget.startDate.year, widget.startDate.month);
  }

  @override
  void didUpdateWidget(CalendarScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.startDate != widget.startDate) {
      setState(() {
        _start = widget.startDate;
        _visibleMonth = DateTime(widget.startDate.year, widget.startDate.month);
      });
    }
  }

  DateTime _monthStart(DateTime d) => DateTime(d.year, d.month, 1);
  DateTime _monthEnd(DateTime d) => DateTime(d.year, d.month + 1, 0);

  List<DateTime> _daysInMonth(DateTime month) {
    final first = _monthStart(month);
    final last = _monthEnd(month);
    final firstWeekday = (first.weekday % 7); // Monday=1..Sunday=0
    final leading = firstWeekday == 0 ? 0 : firstWeekday;
    final total = leading + last.day;
    final rows = (total / 7).ceil();
    final List<DateTime> days = [];
    for (int i = 0; i < rows * 7; i++) {
      final dayNum = i - leading + 1;
      if (dayNum < 1 || dayNum > last.day) {
        days.add(DateTime(0));
      } else {
        days.add(DateTime(month.year, month.month, dayNum));
      }
    }
    return days;
  }

  Set<String> _highlightSet() {
    final Set<String> s = {};
    for (int i = 0; i < 5; i++) {
      final d = _start.add(Duration(days: i));
      s.add('${d.year}-${d.month}-${d.day}');
    }
    return s;
  }

  String monthName(int m) {
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

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size.width / 360.0;
    final days = _daysInMonth(_visibleMonth);
    final highlights = _highlightSet();
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Calendar',
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black),
        ),
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16 * s, 12 * s, 16 * s, 24 * s),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(12 * s, 12 * s, 12 * s, 16 * s),
              decoration: BoxDecoration(
                color: const Color(0xFFF7DCDC),
                borderRadius: BorderRadius.circular(16 * s),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () => setState(() {
                          _visibleMonth = DateTime(
                            _visibleMonth.year,
                            _visibleMonth.month - 1,
                          );
                        }),
                      ),
                      Text(
                        '${monthName(_visibleMonth.month)} ${_visibleMonth.year}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16 * s,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () => setState(() {
                          _visibleMonth = DateTime(
                            _visibleMonth.year,
                            _visibleMonth.month + 1,
                          );
                        }),
                      ),
                    ],
                  ),
                  SizedBox(height: 8 * s),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: weekdays
                        .map(
                          (w) => Expanded(
                            child: Center(
                              child: Text(
                                w,
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12 * s,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  SizedBox(height: 8 * s),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: days.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                        ),
                    itemBuilder: (context, i) {
                      final d = days[i];
                      final isEmpty = d.year == 0;
                      if (isEmpty) return const SizedBox.shrink();
                      final key = '${d.year}-${d.month}-${d.day}';
                      final isHighlighted = highlights.contains(key);
                      return Padding(
                        padding: EdgeInsets.all(2 * s),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _start = DateTime(d.year, d.month, d.day);
                              _visibleMonth = DateTime(d.year, d.month);
                            });
                          },
                          child: Container(
                            decoration: isHighlighted
                                ? BoxDecoration(
                                    color: const Color(0xFFC2615F),
                                    borderRadius: BorderRadius.circular(12 * s),
                                  )
                                : null,
                            child: Center(
                              child: Text(
                                '${d.day}',
                                style: TextStyle(
                                  color: isHighlighted
                                      ? Colors.white
                                      : Colors.black87,
                                  fontWeight: isHighlighted
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 16 * s),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16 * s),
              decoration: BoxDecoration(
                color: const Color(0xFFF7DCDC),
                borderRadius: BorderRadius.circular(16 * s),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'How are you feeling today?',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const Text(
                          'Tell us more about your body to get analysis',
                        ),
                        SizedBox(height: 11 * s),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => AddSymptomsScreen(
                                  date: widget.startDate,
                                  userId: widget.userId,
                                  onPeriodDateChanged: (newDate) {
                                    setState(() {
                                      _start = newDate;
                                      _visibleMonth = DateTime(
                                        newDate.year,
                                        newDate.month,
                                      );
                                    });
                                  },
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC2615F),
                            padding: EdgeInsets.symmetric(
                              horizontal: 16 * s,
                              vertical: 10 * s,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: const Text(
                            'Add Symptom',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        SizedBox(height: 8 * s),
                        OutlinedButton(
                          onPressed: () {
                            if (widget.userId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please login to view history.',
                                  ),
                                ),
                              );
                              return;
                            }
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => SymptomsHistoryScreen(
                                  userId: widget.userId!,
                                  currentCycleStart: widget.startDate,
                                ),
                              ),
                            );
                          },
                          child: const Text('View History'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: Image.asset('assets/images/brain.png', width: 110, ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: widget.withNav
          ? BottomNavigationBar(
              backgroundColor: const Color(0xFFF8D6D6),
              elevation: 0,
              selectedItemColor: const Color(0xFF9B4D4B),
              unselectedItemColor: Colors.black54,
              currentIndex: 1,
              onTap: (i) {
                if (i == 0) {
                  Navigator.of(context).pop();
                }
                if (i == 2) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) =>
                          AbnormalitiesScreen(userId: widget.userId),
                    ),
                  );
                  return;
                }
                if (i == 3) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => SettingsScreen(userId: widget.userId),
                    ),
                  );
                }
              },
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_month),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: ImageIcon(AssetImage('assets/images/egg.png')),
                  label: '',
                ),
                BottomNavigationBarItem(icon: Icon(Icons.settings), label: ''),
              ],
            )
          : null,
    );
  }
}
