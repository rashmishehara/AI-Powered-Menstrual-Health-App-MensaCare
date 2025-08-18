import 'package:flutter/material.dart';

class PeriodStartPage extends StatelessWidget {
  const PeriodStartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF7F7),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Today',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12.0),
            child: Center(
              child: Text(
                'Done',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _buildCalendarRow(),
            const SizedBox(height: 16),
            Row(
              children: [
                _button('Edit Period', Colors.red),
                const SizedBox(width: 10),
                _button('Add Notes', Colors.blue),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              '* Your entries help us detect early signs of imbalance, it only takes a minute!',
              style: TextStyle(fontSize: 12, color: Colors.red),
            ),
            const SizedBox(height: 20),
            const Text('Lifestyle Symptoms', style: _sectionTitleStyle),
            _lifestyleSymptomsSection(),
            const SizedBox(height: 20),
            const Text('Physical Symptoms', style: _sectionTitleStyle),
            _symptomRow(['Headache', 'Lower back pain', 'Pain during sex', 'Flow', 'Pelvic pain']),
            const SizedBox(height: 20),
            const Text('Mental Symptoms', style: _sectionTitleStyle),
            _mentalSymptomsSection(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarRow() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dates = ['17', '18', '19', '20', '21', '22', '23'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(days.length, (index) {
        final isSelected = dates[index] == '21';
        return Column(
          children: [
            Text(days[index], style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.red : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Text(
                dates[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _button(String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _lifestyleSymptomsSection() {
    return Column(
      children: [
        Row(
          children: [
            const Text('Sleep hours:'),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  hintText: 'Input (hrs)',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _weightChangeRow(),
        const SizedBox(height: 10),
        _yesNoRow('Smoking / Alcohol'),
        _yesNoRow('Birth control use'),
        _yesNoRow('Hair Loss'),
      ],
    );
  }

  Widget _weightChangeRow() {
    final options = ['Weight Loss', 'Weight Gain', 'Normal'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: options.map((e) => _outlinedButton(e)).toList(),
    );
  }

  Widget _yesNoRow(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Row(
            children: [
              _outlinedButton('Yes'),
              const SizedBox(width: 8),
              _outlinedButton('No'),
            ],
          )
        ],
      ),
    );
  }

  Widget _outlinedButton(String label) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.red),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      child: Text(label, style: const TextStyle(color: Colors.red)),
    );
  }

  Widget _symptomRow(List<String> symptoms) {
    return Wrap(
      spacing: 20,
      runSpacing: 12,
      children: symptoms.map((s) => _symptomIcon(s)).toList(),
    );
  }

  Widget _symptomIcon(String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: List.generate(
            5,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: Icon(Icons.water_drop_outlined, color: Colors.red.shade300),
            ),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 80,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _mentalSymptomsSection() {
    final mentalSymptomButtons = ['Acne', 'Fatigue', 'Bloating', 'Nausea', 'Dizziness', 'Hot flashes'];
    final iconSymptoms = ['Stress', 'Irritability', 'Forgetfulness', 'Depression', 'Tension', 'Social withdrawal'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: mentalSymptomButtons.map((s) => _yesNoRow(s)).toList(),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 20,
          runSpacing: 12,
          children: iconSymptoms.map((s) => _symptomIcon(s)).toList(),
        ),
      ],
    );
  }
}

const TextStyle _sectionTitleStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.bold,
);
