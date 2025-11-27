import 'package:flutter/material.dart';

class CycleInfoScreen extends StatefulWidget {
  const CycleInfoScreen({super.key});

  @override
  State<CycleInfoScreen> createState() => _CycleInfoScreenState();
}

class _CycleInfoScreenState extends State<CycleInfoScreen> {
  final _controller = PageController();
  int _index = 0;

  static const Color appBarMaroon = Color(0xFF9B4D4B);
  static const Color cardPink = Color(0xFFFFE0E0);

  final List<String> _texts = const [
    'The menstrual cycle is a natural process that happens in most women and people with a uterus, usually once a month. It prepares the body for a possible pregnancy. A typical cycle lasts about 28 days, but it can range from 21 to 35 days.',
    'The cycle begins with menstruation, also known as a period. This is when the lining of the uterus sheds and leaves the body through the vagina, because there was no pregnancy. This usually lasts 3 to 7 days.',
    'After the period, the body starts building up the uterus lining again. At the same time, one of the ovaries prepares to release an egg. Around the middle of the cycle, ovulation happens — the egg is released and travels down the fallopian tube.',
    'If the egg isn’t fertilized by sperm, hormone levels drop. This signals the body to shed the lining again, and the next period begins. Then the cycle repeats.',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size.width / 360.0;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: appBarMaroon,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('How Does Your Menstrual\nCycle Work?'),
        titleTextStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 16*s, color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: _texts.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (_, i) {
                return Padding(
                  padding: EdgeInsets.fromLTRB(16*s, 16*s, 16*s, 0),
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(18*s),
                          decoration: BoxDecoration(
                            color: cardPink,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: SingleChildScrollView(
                            child: Text(
                              _texts[i],
                              textAlign: TextAlign.left,
                              style: TextStyle(height: 1.6, fontSize: 18*s, color: Colors.black87, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 10*s),
          _Dots(count: _texts.length, index: _index),
          SizedBox(height: 10*s),
          Center(child: Image.asset('assets/images/shrug.png', height: 72*s, fit: BoxFit.contain)),
          SafeArea(
            top: false,
            minimum: EdgeInsets.fromLTRB(16*s, 8*s, 16*s, 8*s),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _index == 0 ? null : () => _controller.previousPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut),
                  child: const Text('Back'),
                ),
                FilledButton(
                  onPressed: _index == _texts.length - 1
                      ? null
                      : () => _controller.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut),
                  style: FilledButton.styleFrom(backgroundColor: appBarMaroon, foregroundColor: Colors.white),
                  child: const Text('Next'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  final int count;
  final int index;
  const _Dots({required this.count, required this.index});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 8 : 6,
          height: active ? 8 : 6,
          decoration: BoxDecoration(
            color: active ? Colors.brown : Colors.grey.shade400,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}
