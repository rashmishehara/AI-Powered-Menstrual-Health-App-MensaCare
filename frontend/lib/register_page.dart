import 'package:flutter/material.dart';
import 'login_page.dart';
import 'home_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _dobController = TextEditingController();
  final _lastPeriodController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _dobController.dispose();
    _lastPeriodController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE0E0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const SizedBox(height: 16),
                const Center(
                  child: Text.rich(
                    TextSpan(
                      text: 'Mensa',
                      style: TextStyle(
                        fontFamily: 'HermeneusOne',
                        fontSize: 28,
                        color: Color.fromARGB(255, 213, 98, 98),
                      ),
                      children: [
                        TextSpan(
                          text: 'Care',
                          style: TextStyle(
                            fontFamily: 'HermeneusOne',
                            fontSize: 28,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                const Center(
                  child: Text(
                    'Register now',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Username'),
                const SizedBox(height: 6),
                _roundedInputBox(controller: _usernameController),
                const SizedBox(height: 10),
                const Text('Email'),
                const SizedBox(height: 6),
                _roundedInputBox(
                  controller: _emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'This field is required';
                    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegex.hasMatch(value)) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                const Text('Create a password'),
                const SizedBox(height: 6),
                _roundedInputBox(controller: _passwordController, obscure: true),
                const SizedBox(height: 10),
                const Text('Date of Birth'),
                const SizedBox(height: 6),
                _roundedInputBox(
                  controller: _dobController,
                  hint: 'dd   /   mm   /   yyyy',
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'This field is required';
                    final dateRegex = RegExp(r'^\d{2}\s*/\s*\d{2}\s*/\s*\d{4}$');
                    if (!dateRegex.hasMatch(value)) return 'Enter date as dd / mm / yyyy';
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                const Text('Last menstrual day'),
                const SizedBox(height: 6),
                _roundedInputBox(
                  controller: _lastPeriodController,
                  hint: 'dd   /   mm   /   yyyy',
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'This field is required';
                    final dateRegex = RegExp(r'^\d{2}\s*/\s*\d{2}\s*/\s*\d{4}$');
                    if (!dateRegex.hasMatch(value)) return 'Enter date as dd / mm / yyyy';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Center(
                  child: SizedBox(
                    width: 200,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA64D4D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const HomePage()),
                          );
                        }
                      },
                      child: const Text(
                        'Register now',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                      },
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _roundedInputBox({
    required TextEditingController controller,
    bool obscure = false,
    String? hint,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint ?? '',
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        validator: validator ??
            (value) {
              if (value == null || value.trim().isEmpty) {
                return 'This field is required';
              }
              return null;
            },
      ),
    );
  }
}