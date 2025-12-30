import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../services/firebase_service.dart';

class OtpScreen extends StatefulWidget {
  final String username;
  final String name;
  final String aadhar;
  final String phone;
  final String verificationId;
  final bool isRegistration;

  const OtpScreen({
    super.key,
    required this.username,
    required this.name,
    required this.aadhar,
    required this.phone,
    required this.verificationId,
    this.isRegistration = false,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E3A5F),
      appBar: AppBar(
        backgroundColor: const Color(0xFFDC2626),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: Image.asset('assets/images/tn_police_logo.png'),
            ),
            const SizedBox(width: 10),
            const Flexible(
                child: Text(
              'POLICE AKKA',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            )),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.notifications, color: Colors.white), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter the OTP',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 24, letterSpacing: 10),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[600],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  final otp = _otpController.text.trim();
                  if (otp.isEmpty || otp.length != 6) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter 6-digit OTP')),
                    );
                    return;
                  }
                  
                  // Show loading indicator
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(child: CircularProgressIndicator()),
                  );
                  
                  try {
                    // Sign in with phone credential
                    final user = await FirebaseService.signInWithPhone(
                      widget.verificationId,
                      otp,
                    );
                    
                    if (user == null) {
                      if (mounted) {
                        Navigator.pop(context); // Close loading
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Invalid OTP. Please try again.')),
                        );
                      }
                      return;
                    }
                    
                    // Save citizen profile with username as ID
                    await FirebaseService.saveCitizenProfile(
                      username: widget.username,
                      name: widget.name,
                      phone: widget.phone,
                      aadhar: widget.aadhar,
                    );
                    
                    if (mounted) {
                      Navigator.pop(context); // Close loading
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HomeScreen(
                            username: widget.username,
                            userName: widget.name,
                            phone: widget.phone,
                            aadhar: widget.aadhar,
                          ),
                        ),
                        (route) => false,
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      Navigator.pop(context); // Close loading
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${e.toString()}')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Submit', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: () {},
                child: Text('No received yet ? Click here to sign up again', style: TextStyle(color: Colors.grey[400])),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

