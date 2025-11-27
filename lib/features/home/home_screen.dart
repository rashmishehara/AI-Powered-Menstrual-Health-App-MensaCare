import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../calendar/calendar_screen.dart';
import '../settings/settings_screen.dart';
import '../education/cycle_info_screen.dart';
import '../analysis/analysis_screen.dart';
import '../education/tips_screen.dart';
import '../symptoms/add_symptoms_screen.dart';
import '../abnormalities/abnormalities_screen.dart';

class HomeScreen extends StatefulWidget {
  final int? userId;
  final bool withNav;
  final void Function(DateTime)? onDateChanged;
  const HomeScreen({super.key, this.userId, this.withNav = true, this.onDateChanged});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime? _selectedDate;
  bool _isToday = false;
  String? _userCode;
  bool? _seedExact28;
  bool _flagRefreshing = false;
  bool? _hasAnyData; // first-time users have no data

  static const Color backgroundPink = Color(0xFFF8D6D6);
  static const Color buttonMaroon = Color(0xFF9B4D4B);

  String _formatLong(DateTime d) {
    const months = [
      'January','February','March','April','May','June',
      'July','August','September','October','November','December'
    ];
    return '${d.day} /  ${months[d.month-1]}  ${d.year}';
  }

  Future<void> _loadInitialDate() async {
    // If we have a userId, read last menstrual day from DB and compute current cycle start (28-day cycle)
    if (widget.userId == null) return;
    final db = DatabaseService.instance.db;
    final rows = await db.query('users', where: 'id = ?', whereArgs: [widget.userId], limit: 1);
    if (rows.isEmpty) return;
    final row = rows.first;
    _userCode = row['user_code'] as String?;
    final lmdStr = row['last_menstrual_day'] as String?;
    if (lmdStr == null || lmdStr.isEmpty) return;
    // Stored as ISO e.g., YYYY-MM-DD
    DateTime? lmd;
    try {
      lmd = DateTime.parse(lmdStr);
    } catch (_) {
      return;
    }
    final today = DateTime.now();
    // Find the most recent cycle start <= today
    const cycle = Duration(days: 28);
    DateTime start = DateTime(lmd.year, lmd.month, lmd.day);
    if (start.isAfter(today)) {
      // if somehow future, back up cycles
      while (start.isAfter(today)) {
        start = start.subtract(cycle);
      }
    } else {
      while (start.add(cycle).isBefore(today) || start.add(cycle).isAtSameMomentAs(today)) {
        start = start.add(cycle);
      }
    }
    setState(() {
      _selectedDate = start;
      _isToday = _isSameDay(start, today);
      // user code already assigned above
    });
    widget.onDateChanged?.call(start);
  }

  bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

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

  @override
  void initState() {
    super.initState();
    // Load initial cycle date from DB
    _loadInitialDate();
    _refreshFlag();
  }

  Future<void> _refreshFlag() async {
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
      if (mounted) setState(() { _seedExact28 = (v == true); _hasAnyData = any; });
    } catch (_) {}
  }

  void _showNotificationPopup() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.notifications, color: Colors.black87),
                  const SizedBox(width: 8),
                  const Text(
                    'Notifications',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                "We've noticed irregular patterns in your cycle.",
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AbnormalitiesScreen(userId: widget.userId),
                    ),
                  );
                },
                child: const Text(
                  'View to see what we\'ve noticed',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatShort(DateTime d) {
    const months = [
      'January','February','March','April','May','June',
      'July','August','September','October','November','December'
    ];
    return '${months[d.month-1]} ${d.day}';
  }

  Future<void> _pickAnotherDay() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _isToday = false;
      });
      widget.onDateChanged?.call(picked);
    }
  }

  void _showWhenSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetCtx) {
        final double s = MediaQuery.of(sheetCtx).size.width / 360.0;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 12*s),
              const Text(
                'When did your period start?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),
              ListTile(
                title: const Center(child: Text('Today', style: TextStyle(color: Colors.blue))),
                onTap: () {
                  Navigator.pop(context);
                  final now = DateTime.now();
                  setState(() {
                    _isToday = true;
                    _selectedDate = now;
                  });
                  widget.onDateChanged?.call(now);
                },
              ),
              const Divider(height: 1),
              ListTile(
                title: const Center(child: Text('Another Day', style: TextStyle(color: Colors.blue))),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickAnotherDay();
                },
              ),
              const Divider(height: 1),
              ListTile(
                title: const Center(child: Text('Cancel', style: TextStyle(color: Colors.blueGrey))),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showInfoDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size.width / 360.0; // responsive scale

    // Post-frame refresh of flag to keep in sync with seeding actions
    if (!_flagRefreshing) {
      _flagRefreshing = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _refreshFlag();
        if (mounted) setState(() { _flagRefreshing = false; }); else { _flagRefreshing = false; }
      });
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Determine which date to display and what message to show
    DateTime displayDate;
    String message;
    String headerDate;
    
    if (_selectedDate == null) {
      displayDate = now;
      message = 'Select your period date';
      headerDate = _formatLong(displayDate);
    } else {
      final periodStart = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day);
      final daysSinceStart = today.difference(periodStart).inDays;
      
      if (daysSinceStart == 0) {
        // Today IS the period start
        displayDate = _selectedDate!;
        message = 'Your menstrual date starts today';
        headerDate = _formatLong(displayDate);
      } else if (daysSinceStart > 0 && daysSinceStart < 5) {
        // Within the 5-day period
        displayDate = _selectedDate!;
        message = 'Your cycle started on ${_formatShort(_selectedDate!)}';
        headerDate = _formatLong(displayDate);
      } else {
        // After the 5-day period - show next predicted cycle
        final nextCycle = periodStart.add(const Duration(days: 28));
        displayDate = nextCycle;
        message = 'Your period must likely to start on or around ${_formatShort(nextCycle)}';
        headerDate = _formatLong(nextCycle);
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20*s, 12*s, 20*s, 24*s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Welcome back,\n${_userCode ?? ''}',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (_seedExact28 == false && _hasAnyData == true) {
                        _showNotificationPopup();
                      }
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black54, width: 1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.notifications_none),
                        ),
                        if (_seedExact28 == false && _hasAnyData == true)
                          Positioned(
                            right: -1,
                            top: -1,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Gradient card
              GestureDetector(
                onTap: _showWhenSheet,
                child: Container(
                  width: double.infinity,
                  // height: 96*s,
                  constraints: BoxConstraints(minHeight: 96*s),
                  padding: EdgeInsets.symmetric(horizontal: 16*s, vertical: 14*s),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20*s),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD16B6B), Color(0xFF6A1E1C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_month, color: Colors.white, size: 22*s),
                      SizedBox(width: 10*s),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              headerDate,
                              style: TextStyle(color: Colors.white70, fontSize: 12*s),
                            ),
                            SizedBox(height: 4*s),
                            Text(
                              message,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16*s,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 6*s),
                      Icon(Icons.chevron_right, color: Colors.white, size: 22*s),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20*s),
              const Text(
                'Choose the Categorie,',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 12*s),

              // Grid
              GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                shrinkWrap: true,
                crossAxisSpacing: 16*s,
                mainAxisSpacing: 16*s,
                childAspectRatio: 1.0,
                children: [
                  _CategoryTile(
                    icon: Icons.check_circle_outline,
                    asset: 'assets/images/checkmark.png',
                    label: 'Log Period',
                    onTap: () {
                      if (widget.userId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please login to log your period.')),
                        );
                        return;
                      }
                      final selectedDate = _selectedDate ?? DateTime.now();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AddSymptomsScreen(
                            date: selectedDate,
                            userId: widget.userId!,
                            onPeriodDateChanged: (newDate) {
                              setState(() {
                                _selectedDate = newDate;
                                _isToday = _isSameDay(newDate, DateTime.now());
                              });
                              widget.onDateChanged?.call(newDate);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  _CategoryTile(
                    icon: Icons.receipt_long,
                    asset: 'assets/images/3d-report.png',
                    label: 'View your report',
                    onTap: () async {
                      if (widget.userId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please login to view your report.')),
                        );
                        return;
                      }
                      final start = _selectedDate ?? DateTime.now();
                      final iso = start.toIso8601String().substring(0, 10);
                      try {
                        await DatabaseService.instance.init();
                        await DatabaseService.instance.updateLastMenstrualDay(userId: widget.userId!, lastMenstrualDayIso: iso);
                        // Upsert current cycle and generate previous cycles as samples
                        await DatabaseService.instance.upsertCycle(userId: widget.userId!, firstDayIso: iso, periodLength: 5, cycleLength: 28);
                        await DatabaseService.instance.seedSampleCycles(userId: widget.userId!);
                      } catch (_) {}
                      if (!context.mounted) return;
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AnalysisScreen(userId: widget.userId!),
                        ),
                      );
                    },
                  ),
                  _CategoryTile(
                    icon: Icons.search,
                    asset: 'assets/images/file.png',
                    label: 'How does the Menstrual\nCycle Work?',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CycleInfoScreen()),
                      );
                    },
                  ),
                  _CategoryTile(
                    icon: Icons.lightbulb_outline,
                    asset: 'assets/images/idea.png',
                    label: 'Tips to regulate Your\nPeriods',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const TipsScreen()),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: widget.withNav ? BottomNavigationBar(
        backgroundColor: backgroundPink,
        elevation: 0,
        selectedItemColor: buttonMaroon,
        unselectedItemColor: Colors.black54,
        currentIndex: 0,
        onTap: (i) {
          if (i == 1) {
            final calendarDate = _selectedDate != null 
                ? _calculateDisplayDate(_selectedDate!) 
                : DateTime.now();
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => CalendarScreen(
                  startDate: calendarDate,
                  userId: widget.userId,
                ),
              ),
            );
            return;
          }
          if (i == 2) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => AbnormalitiesScreen(userId: widget.userId),
              ),
            );
            return;
          }
          if (i == 3) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => SettingsScreen(userId: widget.userId)),
            );
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

// settings screen moved to features/settings/settings_screen.dart

class _CategoryTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? asset;
  final VoidCallback? onTap;
  const _CategoryTile({required this.icon, required this.label, this.asset, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF7DCDC),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (asset != null)
              Image.asset(asset!, width: 44, height: 44, fit: BoxFit.contain)
            else
              Icon(icon, size: 32, color: Colors.black87),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
