import 'package:flutter/material.dart';
import 'settings_page.dart';
import 'abnormalities_page.dart';
import 'calendar_page.dart';
import 'categories/log_period.dart';
import 'categories/view_report.dart';
import 'categories/how_mc_work.dart';
import 'categories/tips.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    _MainHomeContent(),
    CalendarPage(),
    AbnormalitiesPage(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F7),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFFA64D4D),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/home_page.png',
              height: 24,
              width: 24,
              color: _selectedIndex == 0 ? const Color(0xFFA64D4D) : Colors.grey,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/calendar_page.png',
              height: 24,
              width: 24,
              color: _selectedIndex == 1 ? const Color(0xFFA64D4D) : Colors.grey,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/abnormalities_page.png',
              height: 24,
              width: 24,
              color: _selectedIndex == 2 ? const Color(0xFFA64D4D) : Colors.grey,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/settings_page.png',
              height: 24,
              width: 24,
              color: _selectedIndex == 3 ? const Color(0xFFA64D4D) : Colors.grey,
            ),
            label: '',
          ),
        ],
      ),
    );
  }
}

class _MainHomeContent extends StatelessWidget {
  const _MainHomeContent();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Welcome back,\nMC000001',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(Icons.notifications_none, size: 30),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFA64D4D), Color(0xFF6F2F2F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_month, color: Colors.white, size: 18),
                      SizedBox(width: 6),
                      Text(
                        '21/ February 2025',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your period is likely to start on or around\nFebruary 24',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Choose the Categorie,',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1,
                children: [
                  _categoryTile(
                    context,
                    'assets/images/log_period.png',
                    'Log Period',
                    const LogPeriodPage(),
                  ),
                  _categoryTile(
                    context,
                    'assets/images/view_report.png',
                    'View your report',
                    const ViewReportPage(),
                  ),
                  _categoryTile(
                    context,
                    'assets/images/how_work.png',
                    'How does the\nMenstrual Cycle Work?',
                    const HowMCWorkPage(),
                  ),
                  _categoryTile(
                    context,
                    'assets/images/tips.png',
                    'Tips to regulate Your\nPeriods',
                    const TipsPage(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _categoryTile(BuildContext context, String imagePath, String title, Widget page) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFE0E0),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              height: 40,
              width: 40,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
