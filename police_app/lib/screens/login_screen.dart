import 'package:flutter/material.dart';
import 'otp_screen.dart';
import '../services/firebase_service.dart';

class LoginScreen extends StatefulWidget {
  final bool isNewUser;
  
  const LoginScreen({super.key, this.isNewUser = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: Image.asset('assets/images/tn_police_logo.png'),
            ),
            const SizedBox(width: 8),
            const Flexible(
              child: Text(
                'POLICE AKKA',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isNewUser ? 'Sign Up' : 'Login using Aadhar',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            if (widget.isNewUser) ...[
              const Text(
                'Enter your Name',
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

              const SizedBox(height: 20),
              const SizedBox(height: 20),
            ],
            
            // Aadhar Number (Always Visible)
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

            // Phone Number (Only for Registration)
            if (widget.isNewUser) ...[
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
            ],

            const SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  String fullPhone = '';
                  String usernameToPass = '';
                  String nameToPass = '';
                  String aadharToPass = '';
                  String displayedPhone = '';

                  // Show loading indicator
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(child: CircularProgressIndicator()),
                  );

                  // LOGIC FOR LOGIN (AADHAR -> PHONE)
                  if (!widget.isNewUser) {
                    final aadhar = _aadharController.text.trim();
                    if (aadhar.isEmpty) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter Aadhar Number')),
                      );
                      return;
                    }

                    // Lookup User by Aadhar
                    final userData = await FirebaseService.getUserByAadhar(aadhar);
                    
                    if (userData == null) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Aadhar not registered. Please Register first.')),
                      );
                      return;
                    }
                    
                    fullPhone = userData['phone'] ?? '';
                    if (!fullPhone.startsWith('+')) fullPhone = '+91$fullPhone';
                    
                    usernameToPass = userData['username'] ?? '';
                    nameToPass = userData['name'] ?? '';
                    aadharToPass = userData['aadhar'] ?? '';
                    displayedPhone = fullPhone;

                  } else {
                    // LOGIC FOR REGISTER (NEW USER)
                    if (_nameController.text.isEmpty || 
                        _aadharController.text.isEmpty || 
                        _phoneController.text.isEmpty) {
                       Navigator.pop(context); // Close loading
                       ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all fields')),
                      );
                      return;
                    }
                    
                    final inputPhone = _phoneController.text.trim();
                    fullPhone = inputPhone.startsWith('+') ? inputPhone : '+91$inputPhone';
                    
                    usernameToPass = _nameController.text.trim().toLowerCase().replaceAll(' ', '_');
                    nameToPass = _nameController.text.trim();
                    aadharToPass = _aadharController.text.trim();
                    displayedPhone = fullPhone;
                  }
                  
                  // Verify Phone (Send OTP)
                  await FirebaseService.verifyPhoneNumber(
                    phoneNumber: fullPhone,
                    onCodeSent: (String verificationId) {
                      Navigator.pop(context); // Close loading
                      
                      // Notify user if Login where OTP is going
                      if (!widget.isNewUser) {
                         ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('OTP sent to registered mobile: $displayedPhone')),
                        );
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OtpScreen(
                            username: usernameToPass,
                            name: nameToPass,
                            aadhar: aadharToPass,
                            phone: displayedPhone,
                            verificationId: verificationId,
                            isRegistration: widget.isNewUser,
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
                  'Submit',
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
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LoginScreen(isNewUser: !widget.isNewUser),
                    ),
                  );
                },
                child: Text(
                  widget.isNewUser
                      ? 'Already have an account ? Login'
                      : 'New user ? Register',
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

