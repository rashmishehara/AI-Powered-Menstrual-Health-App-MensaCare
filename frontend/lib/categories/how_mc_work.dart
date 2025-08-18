import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HowMCWorkPage extends StatefulWidget {
  const HowMCWorkPage({super.key});

  @override
  State<HowMCWorkPage> createState() => _HowMCWorkPageState();
}

class _HowMCWorkPageState extends State<HowMCWorkPage> {
  final PageController _controller = PageController();

  static const List<String> explanations = [
    'The menstrual cycle is a natural process that happens in most women and people with a uterus, usually once a month. It prepares the body for a possible pregnancy. A typical cycle lasts about 28 days, but it can range from 21 to 35 days.',
    'The cycle begins with menstruation, also known as a period. This is when the lining of the uterus sheds and leaves the body through the vagina, because there was no pregnancy. This usually lasts 3 to 7 days.',
    'After the period, the body starts building up the uterus lining again. At the same time, one of the ovaries prepares to release an egg. Around the middle of the cycle, ovulation happens — the egg is released and travels down the fallopian tube.',
    'If the egg isn’t fertilized by sperm, hormone levels drop. This signals the body to shed the lining again, and the next period begins. Then the cycle repeats.',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F7),
      appBar: AppBar(
        title: const Text('How Does Your Menstrual Cycle Work?'),
        backgroundColor: const Color(0xFFA64D4D),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 1), 
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: PageView.builder(
                  controller: _controller,
                  itemCount: explanations.length,
                  itemBuilder: (context, index) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFDCDC),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        explanations[index],
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.justify,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            SmoothPageIndicator(
              controller: _controller,
              count: explanations.length,
              effect: const WormEffect(
                dotHeight: 8,
                dotWidth: 8,
                activeDotColor: Color(0xFFA64D4D),
                dotColor: Colors.grey,
              ),
            ),
            const Spacer(flex: 2),
            Image.asset(
              'assets/images/girl_icon.png',
              height: 80,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
