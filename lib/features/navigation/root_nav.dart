import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../home/home_screen.dart';
import '../calendar/calendar_screen.dart';
import '../abnormalities/abnormalities_screen.dart';
import '../settings/settings_screen.dart';

class RootNav extends StatefulWidget {
  final int? userId;
  const RootNav({super.key, this.userId});

  @override
  State<RootNav> createState() => _RootNavState();
}

class _RootNavState extends State<RootNav> {
  int _index = 0;
  DateTime _calendarStart = DateTime.now();

  static const Color backgroundPink = Color(0xFFF8D6D6);
  static const Color buttonMaroon = Color(0xFF9B4D4B);

  @override
  void initState() {
    super.initState();
    _loadCalendarStart();
  }

  Future<void> _loadCalendarStart() async {
    DateTime start = DateTime.now();
    if (widget.userId != null) {
      try {
        final u = await DatabaseService.instance.getUserById(widget.userId!);
        if (u != null) {
          final lmdStr = u['last_menstrual_day'] as String?;
          if (lmdStr != null && lmdStr.isNotEmpty) {
            try {
              final lmd = DateTime.parse(lmdStr);
              start = _calculateDisplayDate(lmd);
            } catch (_) {}
          }
        }
      } catch (_) {}
    }
    if (mounted) setState(() => _calendarStart = start);
  }

  DateTime _calculateDisplayDate(DateTime periodStart) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(periodStart.year, periodStart.month, periodStart.day);
    final daysSinceStart = today.difference(start).inDays;
    
    if (daysSinceStart >= 0 && daysSinceStart < 5) {
      // Today is the period start OR within the 5-day period
      return start;
    } else {
      // After the 5-day period - show next predicted cycle (28 days from start)
      return start.add(const Duration(days: 28));
    }
  }

  void _updateCalendarStart(DateTime newStart) {
    setState(() {
      _calendarStart = _calculateDisplayDate(newStart);
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeScreen(userId: widget.userId, withNav: false, onDateChanged: _updateCalendarStart),
      CalendarScreen(startDate: _calendarStart, userId: widget.userId, withNav: false),
      AbnormalitiesScreen(userId: widget.userId, withNav: false),
      SettingsScreen(userId: widget.userId, withNav: false),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: backgroundPink,
        elevation: 0,
        selectedItemColor: buttonMaroon,
        unselectedItemColor: Colors.black54,
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: ''),
          BottomNavigationBarItem(icon: ImageIcon(AssetImage('assets/images/egg.png')), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: ''),
        ],
      ),
    );
  }
}
