import 'package:flutter/material.dart';

class WriteToUsScreen extends StatefulWidget {
  const WriteToUsScreen({super.key});

  @override
  State<WriteToUsScreen> createState() => _WriteToUsScreenState();
}

class _WriteToUsScreenState extends State<WriteToUsScreen> {
  final TextEditingController _queryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          image: DecorationImage(
            image: AssetImage('assets/images/app_background.png'),
            fit: BoxFit.cover,
            opacity: 0.85,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Logo header
                Container(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: Image.asset('assets/images/tn_police_logo.png'),
                  ),
                ),
                // Divider
                Container(height: 3, color: const Color(0xFF8B0000), margin: const EdgeInsets.symmetric(horizontal: 20)),
                const SizedBox(height: 30),
                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    'You can write your suggestions and queries here',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.w600, 
                      color: Colors.grey[800],
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Subtitle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    'Help us improve our app by posting your reviews and suggestions',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14, 
                      fontWeight: FontWeight.w500, 
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // Text input field (Chatbox)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: const Color(0xFF1E3A8A).withOpacity(0.2), width: 1.5),
                    ),
                    child: TextField(
                      controller: _queryController,
                      maxLines: 5,
                      style: const TextStyle(fontSize: 16),
                      decoration: const InputDecoration(
                        hintText: 'Type your message here...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(20),
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Submit button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
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
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      'SUBMIT',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
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