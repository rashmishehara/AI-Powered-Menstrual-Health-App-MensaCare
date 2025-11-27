import 'package:flutter/material.dart';
import '../../services/database_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _userCode = TextEditingController(text: 'MC000001');
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _dob = TextEditingController(); // dd / mm / yyyy
  final _lastMens = TextEditingController(); // dd / mm / yyyy
  bool _loading = false;

  @override
  void dispose() {
    _userCode.dispose();
    _email.dispose();
    _password.dispose();
    _dob.dispose();
    _lastMens.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController controller) async {
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

  String? _validate() {
    if (_userCode.text.trim().isEmpty) return 'Please enter UserID';
    final email = _email.text.trim();
    if (email.isEmpty || !email.contains('@')) return 'Please enter a valid email';
    if (_password.text.length < 6) return 'Password must be at least 6 characters';
    if (_dob.text.isEmpty) return 'Please select Date of Birth';
    if (_lastMens.text.isEmpty) return 'Please select Last menstrual day';
    return null;
  }

  String _toIso(String ddmmyyyy) {
    // expected format: dd  /  mm  /  yyyy
    final parts = ddmmyyyy.replaceAll(' ', '').split('/');
    if (parts.length != 3) return '';
    final dd = parts[0].padLeft(2, '0');
    final mm = parts[1].padLeft(2, '0');
    final yyyy = parts[2];
    return '$yyyy-$mm-$dd';
  }

  Future<void> _register() async {
    final error = _validate();
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    setState(() => _loading = true);
    try {
      await DatabaseService.instance.createUser(
        userCode: _userCode.text.trim(),
        email: _email.text.trim(),
        password: _password.text,
        dobIso: _toIso(_dob.text),
        lastMenstrualDayIso: _toIso(_lastMens.text),
      );
      if (!mounted) return;
      Navigator.pop(context, 'registered');
    } on Exception catch (e) {
      final msg = e.toString().contains('UNIQUE') ? 'Email already registered' : 'Failed to register';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size.width / 360.0;
    return Scaffold(
      backgroundColor: const Color(0xFFF8D6D6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8D6D6),
        elevation: 0,
        centerTitle: true,
        title: const Text('Register now', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20*s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('MensaCare', textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              SizedBox(height: 16*s),
              const Text('UserID'),
              SizedBox(height: 6*s),
              TextField(
                controller: _userCode,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12*s),
              const Text('Email'),
              SizedBox(height: 6*s),
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12*s),
              const Text('Create a password'),
              SizedBox(height: 6*s),
              TextField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12*s),
              const Text('Date of Birth'),
              SizedBox(height: 6*s),
              GestureDetector(
                onTap: () => _pickDate(_dob),
                child: AbsorbPointer(
                  child: TextField(
                    controller: _dob,
                    decoration: const InputDecoration(
                      hintText: 'dd  /  mm  /  yyyy',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12*s),
              const Text('Last menstrual day'),
              SizedBox(height: 6*s),
              GestureDetector(
                onTap: () => _pickDate(_lastMens),
                child: AbsorbPointer(
                  child: TextField(
                    controller: _lastMens,
                    decoration: const InputDecoration(
                      hintText: 'dd  /  mm  /  yyyy',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 18*s),
              ElevatedButton(
                onPressed: _loading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9B4D4B),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14*s),
                ),
                child: _loading
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Register now'),
              ),
              SizedBox(height: 8*s),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account? '),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Text('Login', style: TextStyle(color: Colors.blue)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
