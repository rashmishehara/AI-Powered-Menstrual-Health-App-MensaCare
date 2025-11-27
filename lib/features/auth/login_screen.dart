import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _email.text.trim();
    final password = _password.text;
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter email and password')));
      return;
    }
    setState(() => _loading = true);
    try {
      final ok = await DatabaseService.instance.validateLogin(email: email, password: password);
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid email or password')));
        return;
      }
      // Fetch user to pass userId to Home
      final user = await DatabaseService.instance.getUserByEmail(email);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home', arguments: user?['id']);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size.width / 360.0;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20*s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: 'Mensa', style: TextStyle(color: const Color(0xFFBE4B49), fontWeight: FontWeight.w800, fontSize: 24 * s, letterSpacing: 0.5)),
                        TextSpan(text: 'Care', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w800, fontSize: 24 * s, letterSpacing: 0.5)),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 12*s),
                const Text('Login', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                SizedBox(height: 20*s),
                Center(
                  child: Image.asset(
                    'assets/images/sign_up.png',
                    height: 180 * s,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 20*s),
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'Email',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 12*s),
                TextField(
                  controller: _password,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Password',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16*s),
                ElevatedButton(
                  onPressed: _loading ? null : _login,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF9B4D4B), foregroundColor: Colors.white, padding: EdgeInsets.symmetric(vertical: 14*s)),
                  child: _loading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Login'),
                ),
                SizedBox(height: 10*s),
                TextButton(
                  onPressed: () async {
                    final res = await Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
                    if (!mounted) return;
                    if (res == 'registered') {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registration successful. Please log in.')));
                    }
                  },
                  child: const Text('Create an account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
