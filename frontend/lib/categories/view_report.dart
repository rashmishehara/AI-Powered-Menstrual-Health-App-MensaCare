import 'package:flutter/material.dart';

class ViewReportPage extends StatelessWidget {
  const ViewReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F7),
      appBar: AppBar(
        title: const Text('View Report'),
        backgroundColor: const Color(0xFFA64D4D),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'This is the View Report page.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
