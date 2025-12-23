import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import 'edit_profile_screen.dart';
import '../widgets/watermark_base.dart';
import 'current_reports_screen.dart';
import 'previous_reports_screen.dart';


class ProfileScreen extends StatelessWidget {
  final String name;
  final String phone;
  final String aadhar;

  const ProfileScreen({
    super.key,
    required this.name,
    required this.phone,
    required this.aadhar,
  });

  @override
  Widget build(BuildContext context) {
    return WatermarkBase(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
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
              const SizedBox(height: 20),
              // Profile info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditProfileScreen(
                                  userId: phone,
                                  name: name,
                                  phone: phone,
                                  aadhar: aadhar,
                                  photo: null,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.person, size: 60, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 5),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditProfileScreen(
                                  userId: phone,
                                  name: name,
                                  phone: phone,
                                  aadhar: aadhar,
                                  photo: null,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E3A8A),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Text('EDIT PROFILE', style: TextStyle(color: Colors.white, fontSize: 10)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('NAME : ${name.toUpperCase()}', style: const TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 5),
                          Text('PHONE NO : $phone', style: const TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 5),
                          Text('AADHAR NO : $aadhar', style: const TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Previous Reports button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => PreviousReportsScreen(userId: phone)),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: const BorderSide(color: Color(0xFF1E3A8A), width: 2),
                    ),
                    minimumSize: const Size(double.infinity, 60),
                  ),
                  child: const Text('PREVIOUS REPORTS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                ),
              ),
              const SizedBox(height: 20),
              // Current Reports button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CurrentReportsScreen(userId: phone)),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: const BorderSide(color: Color(0xFF1E3A8A), width: 2),
                    ),
                    minimumSize: const Size(double.infinity, 60),
                  ),
                  child: const Text('CURRENT REPORTS AND\nCOMPLAINTS', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const Spacer(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),

    );
  }
}

