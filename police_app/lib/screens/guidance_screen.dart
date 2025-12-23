import 'package:flutter/material.dart';
import '../widgets/watermark_base.dart';

class GuidanceScreen extends StatelessWidget {
  const GuidanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WatermarkBase(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
        title: const Text('Guidance and Rules'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection('Emergency Numbers', [
            'Police: 100',
            'Ambulance: 108',
            'Fire: 101',
            'Women Helpline: 181',
            'Child Helpline: 1098',
          ]),
          _buildSection('When to use SOS', [
            'Life threatening situations',
            'Witnessing a crime in progress',
            'Medical emergencies',
            'Fire or natural disasters',
          ]),
          _buildSection('How to Report an Incident', [
            '1. Select the type of incident',
            '2. Provide accurate location',
            '3. Describe what happened clearly',
            '4. Add photos/videos if available',
            '5. Submit and wait for confirmation',
          ]),
        ],
      ),
      ),
    );
  }
  Widget _buildSection(String title, List<String> items) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
            const SizedBox(height: 10),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(item, style: const TextStyle(fontSize: 14)),
            )),
          ],
        ),
      ),
    );
  }
}

