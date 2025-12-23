import 'package:flutter/material.dart';
import '../widgets/watermark_base.dart';

class WriteToUsScreen extends StatefulWidget {
  const WriteToUsScreen({super.key});

  @override
  State<WriteToUsScreen> createState() => _WriteToUsScreenState();
}

class _WriteToUsScreenState extends State<WriteToUsScreen> {
  final TextEditingController _queryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return WatermarkBase(
      appBar: AppBar(
        title: const Text('Write To Us'),
        backgroundColor: const Color(0xFFDC2626), 
        foregroundColor: Colors.white,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          children: [
            // Logo header
            Center(
              child: SizedBox(
                width: 120,
                height: 120,
                child: Image.asset('assets/images/tn_police_logo.png'),
              ),
            ),
            const SizedBox(height: 20),
            // Divider
            Container(height: 3, color: const Color(0xFF8B0000), margin: const EdgeInsets.symmetric(horizontal: 20)),
            const SizedBox(height: 40),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'You can write your suggestions and queries here',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.black, // Darker color
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 25),
            // Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'Help us improve our app by posting your reviews and suggestions',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.w600, 
                  color: Colors.black87, // Darker color
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Text input field (Chatbox)
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: Border.all(color: const Color(0xFF1E3A8A), width: 1.5),
              ),
              child: TextField(
                controller: _queryController,
                maxLines: 6,
                style: const TextStyle(fontSize: 18, color: Colors.black),
                decoration: const InputDecoration(
                  hintText: 'Type your message here...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(20),
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 50),
            // Submit button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                onPressed: () {
                  // Handle submit
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Thank you for your feedback!')),
                  );
                  _queryController.clear();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 5,
                ),
                child: const Center(
                  child: Text(
                    'SUBMIT',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }
}