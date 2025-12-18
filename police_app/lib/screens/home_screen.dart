import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'report_incident_screen.dart';
import 'guidance_screen.dart';
import 'write_to_us_screen.dart';

class HomeScreen extends StatelessWidget {
  final String userName;
  final String phone;
  final String aadhar;

  const HomeScreen({
    super.key,
    required this.userName,
    required this.phone,
    required this.aadhar,
  });

  void _sendSOS(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.red,
        title: const Text('SOS ALERT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'Emergency SOS has been sent to the nearest police station!\n\nYour location is being shared.',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top navigation bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavButton('WRITE TO US', () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const WriteToUsScreen()));
                    }),
                    _buildNavButton('GUIDANCE\nAND RULES', () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const GuidanceScreen()));
                    }),
                    _buildNavButton('REPORT\nINCIDENT', () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportIncidentScreen()));
                    }),
                    _buildNavButton('MY\nPROFILE', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProfileScreen(
                            name: userName,
                            phone: phone,
                            aadhar: aadhar,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Report to Police button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportIncidentScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    'REPORT TO POLICE',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Tagline
              const Text(
                'TAGLINE!!!!!',
                style: TextStyle(
                  color: Color(0xFFDC2626),
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const Spacer(),
              // Query input
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: const Color(0xFF1E3A8A), width: 2),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'ENTER YOUR QUERY HERE ....',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_upward),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text('TNPOLICE GOV', style: TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold)),
              Text('TAMIL NADU POLICE', style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 20),
              // SOS Button
              GestureDetector(
                onTap: () => _sendSOS(context),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xFFDC2626),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
                  ),
                  child: const Center(
                    child: Text(
                      'SOS',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Emergency button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 60),
                child: ElevatedButton(
                  onPressed: () => _sendSOS(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    minimumSize: const Size(double.infinity, 45),
                  ),
                  child: const Text(
                    'TAP FOR EMERGENCY',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E3A8A),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

