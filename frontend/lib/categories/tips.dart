import 'package:flutter/material.dart';

class TipsPage extends StatelessWidget {
  const TipsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFA64D4D),
        foregroundColor: Colors.white,
        title: const Text('Tips'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: const [
            TipCard(
              number: '1.',
              title: 'Eat a Balanced Diet:',
              description:
                  'Include fruits, vegetables, whole grains, and healthy fats in your meals. Foods rich in iron, calcium, and vitamin B can help balance hormones.',
              imagePath: 'assets/tileicons/diet.png',
              imageOnLeft: false,
            ),
            SizedBox(height: 24),
            TipCard(
              number: '2.',
              title: 'Exercise Regularly:',
              description:
                  'Moderate exercise like walking, yoga, or cycling can help maintain a healthy weight and reduce stress, which may help regulate your cycle.',
              imagePath: 'assets/tileicons/exercise.png',
              imageOnLeft: true,
            ),
            SizedBox(height: 24),
            TipCard(
              number: '3.',
              title: 'Get Enough Sleep:',
              description:
                  'Aim for 7–8 hours of sleep each night. Good sleep helps your body maintain a regular hormonal rhythm.',
              imagePath: 'assets/tileicons/sleep.png',
              imageOnLeft: false,
            ),
            SizedBox(height: 24),
            TipCard(
              number: '4.',
              title: 'Manage Stress:',
              description:
                  'High stress can affect hormone levels and delay your period. Try relaxing activities like meditation, deep breathing, or hobbies you enjoy.',
              imagePath: 'assets/tileicons/stress.png',
              imageOnLeft: true,
            ),
          ],
        ),
      ),
    );
  }
}

class TipCard extends StatelessWidget {
  final String number;
  final String title;
  final String description;
  final String imagePath;
  final bool imageOnLeft;

  const TipCard({
    super.key,
    required this.number,
    required this.title,
    required this.description,
    required this.imagePath,
    this.imageOnLeft = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(
            imageOnLeft ? 64 : 16,
            16,
            imageOnLeft ? 16 : 64,
            16,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFFFE4E4),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$number $title',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: imageOnLeft ? -4 : null,
          right: imageOnLeft ? null : -4,
          bottom: -8,
          child: Image.asset(
            imagePath,
            width: 56,
            height: 56,
          ),
        ),
      ],
    );
  }
}
