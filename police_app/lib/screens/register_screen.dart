import 'package:flutter/material.dart';
import 'otp_screen.dart';
import '../services/supabase_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();
  final _aadharController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E3A5F),
      appBar: AppBar(
        backgroundColor: const Color(0xFFDC2626),
        title: Row(
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: Image.asset('assets/images/tn_police_logo.png'),
            ),
            const SizedBox(width: 10),
            const Text(
              'POLICE AKKA',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Register',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Enter Username (Cannot be changed)',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[600],
                hintText: 'e.g., john_doe',
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            const Text(
              'Enter your Full Name',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[600],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            const Text(
              'Enter Aadhar Number',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _aadharController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[600],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            const Text(
              'Enter Phone Number',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[600],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  final username = _usernameController.text.trim();
                  final phone = _phoneController.text.trim();
                  
                  if (username.isEmpty || phone.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all required fields')),
                    );
                    return;
                  }
                  
                  // Check if username is unique
                  final exists = await SupabaseService.checkUsernameExists(username);
                  if (exists) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Username already taken. Please choose another.')),
                      );
                    }
                    return;
                  }
                  
                  // Add +91 country code if not present
                  final fullPhone = phone.startsWith('+') ? phone : '+91$phone';
                  
                  // Show loading indicator
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(child: CircularProgressIndicator()),
                  );
                  
                  await SupabaseService.verifyPhoneNumber(
                    phoneNumber: fullPhone,
                    onCodeSent: (String verificationId) {
                      Navigator.pop(context); // Close loading
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OtpScreen(
                            username: username,
                            name: _nameController.text,
                            aadhar: _aadharController.text,
                            phone: phone,
                            verificationId: verificationId,
                            isRegistration: true,
                          ),
                        ),
                      );
                    },
                    onError: (String error) {
                      Navigator.pop(context); // Close loading
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $error')),
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Register',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Already have an account? Login',
                  style: TextStyle(color: Colors.grey[400]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
