import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy Policy"),
        backgroundColor: Color(0xFFC2615F),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text('''
Last Updated: April 12, 2025
App Name: MensaCare

This Privacy Policy describes how your personal information is collected, used, and protected when you use the MensaCare mobile application ("App"). By using the App, you agree to the terms outlined in this policy.

1. Information We Collect

a. Personal Information
When you register or interact with MensaCare, we may collect:
• Name
• Email address
• Password (securely encrypted)

b. Health and Cycle Data
To support your menstrual health, we collect:
• Menstrual cycle dates (start, end)
• Symptoms, moods, and notes you record
• Tracking preferences and settings

c. Device & Usage Data
We may automatically collect:
• Device type, operating system, and general app usage behavior
• Crash reports and performance diagnostics
• IP address (for security and analytics purposes)

2. How We Use Your Information
Your information is used to:
• Track, predict, and analyze your menstrual cycle
• Provide insights, reminders, and educational tips
• Personalize user experience within the App
• Improve performance, fix bugs, and enhance features
• Communicate app-related updates or respond to support requests

3. Data Security
We are committed to keeping your data safe. MensaCare uses encryption and secure storage to protect your personal and health information from unauthorized access or disclosure.

4. Information Sharing
We do not sell, rent, or share your personal or health information with third parties, except in the following cases:
• With your explicit consent
• To comply with legal obligations or regulatory requirements
• With trusted partners (e.g., cloud services) under strict confidentiality and data protection agreements

5. Contact Us
If you have questions or concerns about your privacy or this policy, please reach out to us:
📧 Email: mensacare@gmail.com
            ''', style: const TextStyle(fontSize: 16, height: 1.5)),
        ),
      ),
    );
  }
}
