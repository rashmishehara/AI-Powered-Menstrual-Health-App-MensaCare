import 'package:flutter/material.dart';

class LogPeriodPage extends StatelessWidget {
  const LogPeriodPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Period'),
        backgroundColor: Color(0xFFA64D4D),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'This is Log Period page',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
