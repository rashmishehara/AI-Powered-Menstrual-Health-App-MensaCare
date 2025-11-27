import 'package:flutter/material.dart';

class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key});

  static const Color appBarMaroon = Color(0xFF9B4D4B);
  static const Color cardPink = Color(0xFFFFE0E0);
  static const Color cardBorder = Color(0xFFFFC7C7);

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size.width / 360.0;
    final tips = <Map<String, String>>[
      {
        'title': '1. Eat a Balanced Diet:',
        'body': 'Include fruits, vegetables, whole grains, and healthy fats in your meals. Foods rich in iron, calcium, and vitamin B can help balance hormones.'
      },
      {
        'title': '2. Exercise Regularly:',
        'body': 'Moderate exercise like walking, yoga, or cycling can help maintain a healthy weight and reduce stress, which may help regulate your cycle.'
      },
      {
        'title': '3. Get Enough Sleep:',
        'body': 'Aim for 7–8 hours of sleep each night. Good sleep helps your body maintain a regular hormonal rhythm.'
      },
      {
        'title': '4. Manage Stress:',
        'body': 'High stress can affect hormone levels and delay your period. Try relaxing activities like meditation, deep breathing, or hobbies you enjoy.'
      },
    ];
    final emojis = ['📝','🤸‍♀️','🛌','🧘‍♀️'];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: appBarMaroon,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Tips'),
      ),
      body: ListView.separated(
        padding: EdgeInsets.fromLTRB(16*s, 16*s, 16*s, 24*s),
        itemBuilder: (_, i) {
          final t = tips[i];
          final emoji = emojis[i % emojis.length];
          return Stack(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: cardPink,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: cardBorder),
                  boxShadow: const [
                    BoxShadow(color: Color(0x14000000), blurRadius: 6, offset: Offset(0, 3)),
                  ],
                ),
                padding: EdgeInsets.fromLTRB(16*s, 16*s, 16*s, 16*s),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t['title']!,
                      style: TextStyle(fontSize: 18*s, fontWeight: FontWeight.w800, color: const Color(0xFF5A3B3A)),
                    ),
                    SizedBox(height: 8*s),
                    Text(
                      t['body']!,
                      style: TextStyle(fontSize: 15*s, height: 1.55, color: Colors.black87),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 8*s,
                top: -2*s,
                child: Text(emoji, style: TextStyle(fontSize: 28*s)),
              ),
            ],
          );
        },
        separatorBuilder: (_, __) => SizedBox(height: 12*s),
        itemCount: tips.length,
      ),
    );
  }
}
