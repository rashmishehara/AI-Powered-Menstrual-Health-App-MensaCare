import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../calendar/calendar_screen.dart';
import '../abnormalities/abnormalities_screen.dart';
import '../auth/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  final int? userId;
  final bool withNav;
  const SettingsScreen({super.key, this.userId, this.withNav = true});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Map<String, dynamic>? _user;
  bool _loading = true;

  static const Color backgroundPink = Color(0xFFF8D6D6);
  static const Color buttonMaroon = Color(0xFF9B4D4B);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Logout')),
        ],
      ),
    );
    if (confirm != true) return;
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _load() async {
    if (widget.userId != null) {
      final u = await DatabaseService.instance.getUserById(widget.userId!);
      setState(() {
        _user = u;
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _editEmail() async {
    if (_user == null) return;
    final controller = TextEditingController(text: _user!['email'] as String? ?? '');
    final newEmail = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Email'),
        content: TextField(controller: controller, keyboardType: TextInputType.emailAddress),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Save')),
        ],
      ),
    );
    if (newEmail == null || newEmail.isEmpty) return;
    await DatabaseService.instance.updateUserEmail(userId: _user!['id'] as int, email: newEmail);
    await _load();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email updated')));
    }
  }

  Future<void> _editDob() async {
    if (_user == null) return;
    DateTime initial = DateTime.now();
    final dobStr = _user!['dob'] as String?;
    if (dobStr != null && dobStr.isNotEmpty) {
      try { initial = DateTime.parse(dobStr); } catch (_) {}
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    final iso = '${picked.year.toString().padLeft(4,'0')}-${picked.month.toString().padLeft(2,'0')}-${picked.day.toString().padLeft(2,'0')}';
    await DatabaseService.instance.updateUserDob(userId: _user!['id'] as int, dobIso: iso);
    await _load();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Birthday updated')));
    }
  }

  Future<void> _editPassword() async {
    if (_user == null) return;
    final controller = TextEditingController();
    final newPass = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Change Password'),
        content: TextField(controller: controller, obscureText: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Save')),
        ],
      ),
    );
    if (newPass == null || newPass.isEmpty) return;
    await DatabaseService.instance.updateUserPassword(userId: _user!['id'] as int, newPassword: newPass);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password changed')));
    }
  }

  Future<void> _deleteAccount() async {
    if (_user == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('This will permanently delete your data.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm != true) return;
    await DatabaseService.instance.deleteUser(userId: _user!['id'] as int);
    if (mounted) {
      Navigator.of(context).popUntil((r) => r.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account deleted')));
    }
  }

  String _formatDob(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    try {
      final d = DateTime.parse(iso);
      return '${d.year.toString().padLeft(4,'0')}/${d.month.toString().padLeft(2,'0')}/${d.day.toString().padLeft(2,'0')}';
    } catch (_) { return iso; }
  }

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size.width / 360.0;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black)),
        foregroundColor: Colors.black,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16*s, 12*s, 16*s, 24*s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 96*s,
                    height: 96*s,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFE3E3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person, size: 48, color: Colors.brown),
                  ),
                  const SizedBox(height: 8),
                  Text(_user?['user_code'] as String? ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),

                  Container(
                    decoration: BoxDecoration(color: const Color(0xFFF7DCDC), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black12)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(children: [
                      Expanded(child: Text('Email: ${_user?['email'] ?? ''}')),
                      IconButton(onPressed: _editEmail, icon: const Icon(Icons.edit_outlined))
                    ]),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    decoration: BoxDecoration(color: const Color(0xFFF7DCDC), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black12)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(children: [
                      Expanded(child: Text('Birthday: ${_formatDob(_user?['dob'] as String?) }')),
                      IconButton(onPressed: _editDob, icon: const Icon(Icons.edit_outlined))
                    ]),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    decoration: BoxDecoration(color: const Color(0xFFF7DCDC), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black12)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(children: const [
                      Expanded(child: Text('Password: ********')),
                    ]),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(onPressed: _editPassword, icon: const Icon(Icons.edit_outlined, size: 18), label: const Text('Change')),
                  ),

                  const SizedBox(height: 4),
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => const AlertDialog(title: Text('Privacy & Policy'), content: Text('Privacy policy details will be shown here.')),
                      );
                    },
                    child: const Text('Read Privacy and Policy'),
                  ),

                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      side: const BorderSide(color: Colors.black26),
                      padding: EdgeInsets.symmetric(horizontal: 16*s, vertical: 12*s),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _deleteAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD16B6B),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 16*s, vertical: 12*s),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 1,
                    ),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Delete Account'),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: widget.withNav ? BottomNavigationBar(
        backgroundColor: backgroundPink,
        elevation: 0,
        selectedItemColor: buttonMaroon,
        unselectedItemColor: Colors.black54,
        currentIndex: 3,
        onTap: (i) async {
          if (i == 0) {
            Navigator.of(context).pop();
            return;
          }
          if (i == 1) {
            DateTime start = DateTime.now();
            final lmdStr = _user?['last_menstrual_day'] as String?;
            if (lmdStr != null && lmdStr.isNotEmpty) {
              try { start = DateTime.parse(lmdStr); } catch (_) {}
            }
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CalendarScreen(startDate: start, userId: widget.userId),
              ),
            );
            return;
          }
          if (i == 2) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AbnormalitiesScreen(userId: widget.userId),
              ),
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
