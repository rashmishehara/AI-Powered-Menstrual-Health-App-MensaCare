import 'package:flutter/material.dart';
import 'services/database_service.dart';
import 'features/auth/login_screen.dart' as auth;
import 'features/auth/register_screen.dart' as auth_reg;
import 'features/home/home_screen.dart';
import 'features/navigation/root_nav.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.instance.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MensaCare',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF8D6D6), // soft pink background
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF9B4D4B)),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w800,
            fontSize: 20,
            letterSpacing: 0.3,
          ),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.2),
          titleMedium: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      routes: {
        '/login': (_) => const auth.LoginScreen(),
        '/register': (_) => const auth_reg.RegisterScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          final arg = settings.arguments;
          final int? userId = arg is int ? arg : null;
          return MaterialPageRoute(builder: (_) => RootNav(userId: userId));
        }
        return null;
      },
      home: const auth.LoginScreen(),
    );
  }
}

/*
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime? _selectedDate;
  bool _isToday = false;

  String _formatLong(DateTime d) {
    const months = [
      'January','February','March','April','May','June',
      'July','August','September','October','November','December'
    ];
    return '${d.day} /  ${months[d.month-1]}  ${d.year}';
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
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _isToday = false;
      });
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
                  setState(() {
                    _isToday = true;
                    _selectedDate = DateTime.now();
                  });
                },
              ),
              const Divider(height: 1),
              ListTile(
                title: const Center(child: Text('Another Day', style: TextStyle(color: Colors.blue))),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickAnotherDay();
        ? 'Your Period Starts Today'
        : (_selectedDate != null
            ? 'Selected date: ${_formatShort(displayDate)}'
            : 'Select your period date');

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
                  const Expanded(
                    child: Text(
                      'Welcome back,\nMC000001',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black54, width: 1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.notifications_none),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Gradient card
              GestureDetector(
                onTap: _showWhenSheet,
                child: Container(
                  width: double.infinity,
                  height: 96*s,
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

              // Simple grid placeholders
              GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                shrinkWrap: true,
                crossAxisSpacing: 16*s,
                mainAxisSpacing: 16*s,
                childAspectRatio: 1.0,
                children: [
                  const _CategoryTile(icon: Icons.check_circle_outline, label: 'Log Period'),
                  const _CategoryTile(icon: Icons.receipt_long, label: 'View your report'),
                  _CategoryTile(
                    icon: Icons.search,
                    label: 'How does the Menstrual\nCycle Work?',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CycleInfoScreen()),
                      );
                    },
                  ),
                  _CategoryTile(
                    icon: Icons.lightbulb_outline,
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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: LandingScreen.backgroundPink,
        elevation: 0,
        selectedItemColor: LandingScreen.buttonMaroon,
        unselectedItemColor: Colors.black54,
        currentIndex: 0,
        onTap: (i) {
          if (i == 1) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CalendarScreen(startDate: _selectedDate ?? DateTime.now()),
              ),
            );
            return;
          }
          if (i == 3) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_ind_outlined), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: ''),
        ],
      ),
    );
  }
}

class NotesScreen extends StatefulWidget {
  final String initialText;
  const NotesScreen({super.key, required this.initialText});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size.width / 360.0;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Add notes', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
        foregroundColor: Colors.black,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, _controller.text);
            },
            child: Text('Save', style: TextStyle(color: LandingScreen.buttonMaroon, fontWeight: FontWeight.w700)),
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(12*s),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3F3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black12),
          ),
          padding: EdgeInsets.all(12*s),
          child: TextField(
            controller: _controller,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            decoration: const InputDecoration.collapsed(hintText: ''),
          ),
        ),
      ),
    );
  }
}

class AddSymptomsScreen extends StatefulWidget {
  final DateTime date;
  const AddSymptomsScreen({super.key, required this.date});

  @override
  State<AddSymptomsScreen> createState() => _AddSymptomsScreenState();
}

class _AddSymptomsScreenState extends State<AddSymptomsScreen> {
  final _sleepController = TextEditingController();
  String _weightChange = '';
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
    'Stress': false,
    'Irritability': false,
    'Forgetfulness': false,
    'Depression': false,
    'Tension': false,
    'Social withdrawal': false,
  };

  final Map<String, int> _intensity = {
    'Headache': 0,
    'Lower back pain': 0,
    'Pain during sex': 0,
    'Flow': 0,
    'Pelvic pain': 0,
  };

  @override
  void dispose() {
    _sleepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size.width / 360.0;
    String monthName(int m) {
      const months = ['January','February','March','April','May','June','July','August','September','October','November','December'];
      return months[m-1];
    }
    final titleDate = '${monthName(widget.date.month)} ${widget.date.day}';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('Today', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black)),
        actions: [
          TextButton(
            onPressed: () { Navigator.pop(context); },
            child: Text('Done', style: TextStyle(color: LandingScreen.buttonMaroon, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16*s, 0, 16*s, 24*s),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Mini week strip
            _WeekStrip(centerDate: widget.date),
            SizedBox(height: 10*s),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.redAccent),
                      foregroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(vertical: 12*s),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {},
                    child: const Text('Edit Period'),
                  ),
                ),
                SizedBox(width: 10*s),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: LandingScreen.buttonMaroon),
                      foregroundColor: LandingScreen.buttonMaroon,
                      padding: EdgeInsets.symmetric(vertical: 12*s),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => NotesScreen(initialText: ''),
                        ),
                      );
                    },
                    child: const Text('Add Notes'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8*s),
            Container(
              padding: EdgeInsets.all(8*s),
              decoration: BoxDecoration(color: const Color(0xFFFFEFEF), borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: const [
                  Expanded(
                    child: Text(
                      '🔎  Your entries help us detect early signs of imbalance,\n it only takes a minute!',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 14*s),
            _SectionTitle('Lifestyle Symptoms'),
            _CardWrap(children: [
              _FieldRow(label: 'Sleep hours', trailing: SizedBox(
                width: 120*s,
                child: TextField(
                  controller: _sleepController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    isDense: true,
                    hintText: 'Input (hrs)',
                    border: OutlineInputBorder(),
                  ),
                ),
              )),
              _LabelRow('Weight changes'),
              Wrap(
                spacing: 8,
                children: [
                  for (final opt in ['Weight Loss','Weight Gain','Normal'])
                    ChoiceChip(
                      label: Text(opt),
                      selected: _weightChange == opt,
                      onSelected: (_) => setState(() => _weightChange = opt),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              _ToggleRow(
                label: 'Smoking / Alcohol',
                value: _toggles['Smoking / Alcohol']!,
                onChanged: (v) => setState(() => _toggles['Smoking / Alcohol'] = v),
              ),
              _ToggleRow(
                label: 'Birth control use',
                value: _toggles['Birth control use']!,
                onChanged: (v) => setState(() => _toggles['Birth control use'] = v),
              ),
              _ToggleRow(
                label: 'Hair Loss',
                value: _toggles['Hair Loss']!,
                onChanged: (v) => setState(() => _toggles['Hair Loss'] = v),
              ),
            ]),

            SizedBox(height: 16*s),
            _SectionTitle('Physical Symptoms'),
            _CardWrap(children: [
              for (final k in _intensity.keys)
                _IntensityRow(
                  label: k,
                  value: _intensity[k]!,
                  onChanged: (v) => setState(() => _intensity[k] = v),
                ),
              const SizedBox(height: 8),
              _ToggleRow(
                label: 'Acne',
                value: _toggles['Acne']!,
                onChanged: (v) => setState(() => _toggles['Acne'] = v),
              ),
              _ToggleRow(
                label: 'Fatigue',
                value: _toggles['Fatigue']!,
                onChanged: (v) => setState(() => _toggles['Fatigue'] = v),
              ),
              _ToggleRow(
                label: 'Bloating',
                value: _toggles['Bloating']!,
                onChanged: (v) => setState(() => _toggles['Bloating'] = v),
              ),
              _ToggleRow(
                label: 'Nausea',
                value: _toggles['Nausea']!,
                onChanged: (v) => setState(() => _toggles['Nausea'] = v),
              ),
              _ToggleRow(
                label: 'Dizziness',
                value: _toggles['Dizziness']!,
                onChanged: (v) => setState(() => _toggles['Dizziness'] = v),
              ),
              _ToggleRow(
                label: 'Hot flashes',
                value: _toggles['Hot flashes']!,
                onChanged: (v) => setState(() => _toggles['Hot flashes'] = v),
              ),
            ]),

            SizedBox(height: 16*s),
            _SectionTitle('Mental Symptoms'),
            _CardWrap(children: [
              for (final entry in _toggles.entries.where((e) => ['Stress','Irritability','Forgetfulness','Depression','Tension','Social withdrawal'].contains(e.key)))
                _ToggleRow(
                  label: entry.key,
                  value: entry.value,
                  onChanged: (v) => setState(() => _toggles[entry.key] = v),
                ),
            ]),
          ],
        ),
      ),
    );
  }
}

class _WeekStrip extends StatelessWidget {
  final DateTime centerDate;
  const _WeekStrip({required this.centerDate});

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size.width / 360.0;
    DateTime start = centerDate.subtract(const Duration(days: 3));
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10*s, horizontal: 12*s),
      decoration: BoxDecoration(color: const Color(0xFFF7DCDC), borderRadius: BorderRadius.circular(14)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (i) {
          final d = start.add(Duration(days: i));
          final isHighlighted = d.day == centerDate.day && d.month == centerDate.month && d.year == centerDate.year;
          return Column(
            children: [
              Text(['Mon','Tue','Wed','Thu','Fri','Sat','Sun'][d.weekday-1], style: TextStyle(fontSize: 12*s)),
              const SizedBox(height: 4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8*s, vertical: 6*s),
                decoration: BoxDecoration(
                  color: isHighlighted ? const Color(0xFFBE4B49) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('${d.day}', style: TextStyle(color: isHighlighted ? Colors.white : Colors.black87)),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
    );
  }
}

class _CardWrap extends StatelessWidget {
  final List<Widget> children;
  const _CardWrap({required this.children});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7DCDC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }
}

class _FieldRow extends StatelessWidget {
  final String label;
  final Widget trailing;
  const _FieldRow({required this.label, required this.trailing});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          trailing,
        ],
      ),
    );
  }
}

class _LabelRow extends StatelessWidget {
  final String text;
  const _LabelRow(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ToggleRow({required this.label, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          SizedBox(
            width: 96,
            child: OutlinedButton(
              onPressed: () => onChanged(true),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: value ? LandingScreen.buttonMaroon : Colors.black26),
                foregroundColor: value ? LandingScreen.buttonMaroon : Colors.black87,
              ),
              child: const Text('Yes'),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 96,
            child: OutlinedButton(
              onPressed: () => onChanged(false),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: !value ? LandingScreen.buttonMaroon : Colors.black26),
                foregroundColor: !value ? LandingScreen.buttonMaroon : Colors.black87,
              ),
              child: const Text('No'),
            ),
          ),
        ],
      ),
    );
  }
}

class _IntensityRow extends StatelessWidget {
  final String label;
  final int value; // 0..5
  final ValueChanged<int> onChanged;
  const _IntensityRow({required this.label, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    Widget dot(int i) {
      final active = i <= value;
      return InkWell(
        onTap: () => onChanged(i),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: active ? LandingScreen.buttonMaroon : Colors.black26),
            color: active ? const Color(0xFFFFE6E6) : Colors.transparent,
          ),
          child: active ? Center(child: Text('💧', style: const TextStyle(fontSize: 12))) : null,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Row(children: [for (int i = 1; i <= 5; i++) dot(i)]),
        ],
      ),
    );
  }
}

class CalendarScreen extends StatefulWidget {
  final DateTime startDate; // first day of period
  const CalendarScreen({super.key, required this.startDate});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _visibleMonth;

  @override
  void initState() {
    super.initState();
    _visibleMonth = DateTime(widget.startDate.year, widget.startDate.month);
  }

  DateTime _monthStart(DateTime d) => DateTime(d.year, d.month, 1);
  DateTime _monthEnd(DateTime d) => DateTime(d.year, d.month + 1, 0);

  List<DateTime> _daysInMonth(DateTime month) {
    final first = _monthStart(month);
    final last = _monthEnd(month);
    final firstWeekday = (first.weekday % 7); // make Monday=1..Sunday=0
    final leading = firstWeekday == 0 ? 0 : firstWeekday; // Mon-first layout
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
    // 5-day window from startDate
    final Set<String> s = {};
    for (int i = 0; i < 5; i++) {
      final d = widget.startDate.add(Duration(days: i));
      s.add('${d.year}-${d.month}-${d.day}');
    }
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size.width / 360.0;
    final days = _daysInMonth(_visibleMonth);
    final highlights = _highlightSet();
    const weekdays = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];

    String monthName(int m) {
      const months = ['January','February','March','April','May','June','July','August','September','October','November','December'];
      return months[m-1];
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('Calendar', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black)),
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16*s, 12*s, 16*s, 24*s),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(12*s, 12*s, 12*s, 16*s),
              decoration: BoxDecoration(
                color: const Color(0xFFF7DCDC),
                borderRadius: BorderRadius.circular(16*s),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () => setState(() {
                          _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month - 1);
                        }),
                      ),
                      Text(
                        '${monthName(_visibleMonth.month)} ${_visibleMonth.year}',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16*s),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () => setState(() {
                          _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1);
                        }),
                      ),
                    ],
                  ),
                  SizedBox(height: 8*s),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: weekdays.map((w) => Expanded(
                              child: Center(
                                child: Text(
                                  w,
                                  style: TextStyle(color: Colors.black54, fontSize: 12 * s),
                                ),
                              ),
                            )).toList(),
                  ),
                  SizedBox(height: 8*s),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: days.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
                    itemBuilder: (context, i) {
                      final d = days[i];
                      final isEmpty = d.year == 0;
                      if (isEmpty) return const SizedBox.shrink();
                      final key = '${d.year}-${d.month}-${d.day}';
                      final isHighlighted = highlights.contains(key);
                      return Padding(
                        padding: EdgeInsets.all(2*s),
                        child: Container(
                          decoration: isHighlighted
                              ? BoxDecoration(
                                  color: const Color(0xFFBE4B49),
                                  borderRadius: BorderRadius.circular(12*s),
                                )
                              : null,
                          child: Center(
                            child: Text(
                              '${d.day}',
                              style: TextStyle(
                                color: isHighlighted ? Colors.white : Colors.black87,
                                fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w500,
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
            SizedBox(height: 16*s),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16*s),
              decoration: BoxDecoration(
                color: const Color(0xFFF7DCDC),
                borderRadius: BorderRadius.circular(16*s),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('How are you feeling today?', style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        const Text('Tell us more about your body to get analysis'),
                        SizedBox(height: 10*s),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: LandingScreen.buttonMaroon,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          ),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => AddSymptomsScreen(date: widget.startDate),
                              ),
                            );
                          },
                          child: const Text('Add Symptom'),
                        ),
                      ],
                    ),
                  ),
                  Text('🧠', style: TextStyle(fontSize: 42*s)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size.width / 360.0;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black,
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20*s, 16*s, 20*s, 24*s),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar
            Container(
              width: 96*s,
              height: 96*s,
              decoration: const BoxDecoration(
                color: Color(0xFFFAD9D9),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person, size: 56*s, color: LandingScreen.buttonMaroon),
            ),
            SizedBox(height: 10*s),
            const Text(
              'MC000001',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 16*s),

            _SettingRow(label: 'Email', value: 'user1234@gmail.com', onEdit: () {}),
            SizedBox(height: 12*s),
            _SettingRow(label: 'Birthday', value: '1996/06/21', onEdit: () {}),
            SizedBox(height: 12*s),
            _SettingRow(label: 'Password', value: '********', onEdit: () {}),

            SizedBox(height: 16*s),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
                );
              },
              child: const Text(
                'Read Privacy and Policy',
                style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
              ),
            ),

            SizedBox(height: 8*s),
            SizedBox(
              width: double.infinity,
              height: 48*s,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFBE4B49),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                ),
                onPressed: () {},
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete Account'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onEdit;
  const _SettingRow({required this.label, required this.value, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2)),
        ],
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$label: $value',
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, size: 20),
            splashRadius: 20,
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const _CategoryTile({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final tile = Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAD9D9),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: LandingScreen.buttonMaroon),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ],
      ),
    );
    if (onTap == null) return tile;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: tile,
    );
  }
}

class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size.width / 360.0;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: LandingScreen.buttonMaroon,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Tips', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16*s, 16*s, 16*s, 24*s),
        child: Column(
          children: [
            _TipCard(
              number: 1,
              title: 'Eat a Balanced Diet:',
              body:
                  'Include fruits, vegetables, whole grains, and healthy fats in your meals. Foods rich in iron, calcium, and vitamin B can help balance hormones.',
              emoji: '📝',
            ),
            SizedBox(height: 12*s),
            _TipCard(
              number: 2,
              title: 'Exercise Regularly:',
              body:
                  'Moderate exercise like walking, yoga, or cycling can help maintain a healthy weight and reduce stress, which may help regulate your cycle.',
              emoji: '🧘‍♀️',
            ),
            SizedBox(height: 12*s),
            _TipCard(
              number: 3,
              title: 'Get Enough Sleep:',
              body:
                  'Aim for 7–8 hours of sleep each night. Good sleep helps your body maintain a regular hormonal rhythm.',
              emoji: '🛌',
            ),
            SizedBox(height: 12*s),
            _TipCard(
              number: 4,
              title: 'Manage Stress:',
              body:
                  'High stress can affect hormone levels and delay your period. Try relaxing activities like meditation, deep breathing, or hobbies you enjoy.',
              emoji: '🧘',
            ),
          ],
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final int number;
  final String title;
  final String body;
  final String emoji;
  const _TipCard({required this.number, required this.title, required this.body, this.emoji = ''});

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size.width / 360.0;
    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(14*s),
          decoration: BoxDecoration(
            color: const Color(0xFFF7DCDC), // softer pink card
            borderRadius: BorderRadius.circular(16*s),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6*s,
                offset: Offset(0, 3*s),
              )
            ],
          ),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black87, fontSize: 14*s, height: 1.45),
              children: [
                TextSpan(
                  text: '$number. ',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16*s,
                    color: Colors.black,
                  ),
                ),
                TextSpan(
                  text: '$title ',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16*s,
                    color: Colors.black,
                  ),
                ),
                const TextSpan(text: '\n'),
                TextSpan(text: body),
              ],
            ),
          ),
        ),
        if (emoji.isNotEmpty)
          Positioned(
            right: 8*s,
            top: -4*s,
            child: Text(
              emoji,
              style: TextStyle(fontSize: 20*s),
            ),
          ),
      ],
    );
  }
}

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final _idOrEmailController = TextEditingController();

  @override
  void dispose() {
    _idOrEmailController.dispose();
    super.dispose();
  }

  void _submit() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('If this account exists, reset instructions were sent.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LandingScreen.backgroundPink,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Center(child: _MensaCareTitle()),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'Forget Password',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Enter your registered Email or UserID and we'll send reset instructions.",
                style: TextStyle(color: Colors.black87),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 20),
              const _FieldLabel('Email or UserID'),
              const SizedBox(height: 6),
              _RoundedTextField(
                controller: _idOrEmailController,
                hintText: '',
                obscure: false,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LandingScreen.buttonMaroon,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    elevation: 0,
                  ),
                  onPressed: _submit,
                  child: const Text('Send reset link'),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  child: const Text(
                    'Back to Login',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  static const Color backgroundPink = Color(0xFFF8D6D6);
  static const Color mensaCoral = Color(0xFFD16B6B);
  static const Color buttonMaroon = Color(0xFF9B4D4B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundPink,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 28),
              // Title: MensaCare (with colored 'Mensa')
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Mensa',
                      style: TextStyle(
                        color: mensaCoral,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    TextSpan(
                      text: 'Care',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              // Illustration
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: AspectRatio(
                  aspectRatio: 3/4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1521791136064-7986c2920216?q=80&w=800&auto=format&fit=crop',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.image_outlined, size: 96, color: Colors.black26),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const Spacer(),
              // Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48.0),
                child: Column(
                  children: [
                    _primaryPillButton(
                      label: 'Login',
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _primaryPillButton(
                      label: 'Register',
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const RegisterScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _primaryPillButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonMaroon,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LandingScreen.backgroundPink,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Center(child: _MensaCareTitle()),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const _FieldLabel('UserID'),
              const SizedBox(height: 6),
              _RoundedTextField(
                key: const Key('login_user_field'),
                controller: _userController,
                hintText: '',
                obscure: false,
              ),
              const SizedBox(height: 16),
              const _FieldLabel('Password'),
              const SizedBox(height: 6),
              _RoundedTextField(
                key: const Key('login_password_field'),
                controller: _passController,
                hintText: '',
                obscure: true,
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ForgetPasswordScreen()),
                    );
                  },
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  child: const Text(
                    'Forget Password',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LandingScreen.buttonMaroon,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    // For now, navigate to Home after a successful login
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                    );
                  },
                  key: const Key('login_button'),
                  child: const Text('Login now'),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Colors.black87),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const RegisterScreen()),
                        );
                      },
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        key: const Key('login_register_button'),
                        child: const Text(
                          'Register now',
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MensaCareTitle extends StatelessWidget {
  const _MensaCareTitle();

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: const TextSpan(
        children: [
          TextSpan(
            text: 'Mensa',
            style: TextStyle(
              color: LandingScreen.mensaCoral,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          TextSpan(
            text: 'Care',
            style: TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFFB07F7F),
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _RoundedTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscure;
  const _RoundedTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.obscure,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _userController = TextEditingController(text: 'MC000001');
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _dobController = TextEditingController();
  final _lmdController = TextEditingController();

  @override
  void dispose() {
    _userController.dispose();
    _emailController.dispose();
    _passController.dispose();
    _dobController.dispose();
    _lmdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LandingScreen.backgroundPink,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Center(child: _MensaCareTitle()),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'Register now',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const _FieldLabel('UserID'),
              const SizedBox(height: 6),
              _RoundedTextField(
                key: const Key('register_user_field'),
                controller: _userController,
                hintText: '',
                obscure: false,
              ),
              const SizedBox(height: 16),
              const _FieldLabel('Email'),
              const SizedBox(height: 6),
              _RoundedTextField(
                key: const Key('register_email_field'),
                controller: _emailController,
                hintText: '',
                obscure: false,
              ),
              const SizedBox(height: 16),
              const _FieldLabel('Create a password'),
              const SizedBox(height: 6),
              _RoundedTextField(
                key: const Key('register_password_field'),
                controller: _passController,
                hintText: '',
                obscure: true,
              ),
              const SizedBox(height: 16),
              const _FieldLabel('Date of Birth'),
              const SizedBox(height: 6),
              _DateField(controller: _dobController),
              const SizedBox(height: 16),
              const _FieldLabel('Last menstrual day'),
              const SizedBox(height: 6),
              _DateField(controller: _lmdController),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LandingScreen.buttonMaroon,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {},
                  key: const Key('register_button'),
                  child: const Text('Register now'),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(color: Colors.black87),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      },
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final TextEditingController controller;
  const _DateField({required this.controller});

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      final dd = picked.day.toString().padLeft(2, '0');
      final mm = picked.month.toString().padLeft(2, '0');
      final yyyy = picked.year.toString();
      controller.text = '$dd  /  $mm  /  $yyyy';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pick(context),
      child: AbsorbPointer(
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'dd  /  mm  /  yyyy',
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}

// --- Placeholder screens to satisfy navigation targets ---
class CycleInfoScreen extends StatelessWidget {
  const CycleInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cycle Info')),
      body: const Center(child: Text('Cycle information goes here')),
    );
  }
}

class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tips')),
      body: const Center(child: Text('Tips content goes here')),
    );
  }
}

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy & Policy')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Privacy policy details will be shown here.'),
      ),
    );
  }
}
*/
