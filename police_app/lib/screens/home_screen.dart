import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'report_incident_screen.dart';
import 'guidance_screen.dart';
import 'ai_chatbot_screen.dart';
import '../services/firebase_service.dart';
import 'write_to_us_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  final String userName;
  final String phone;
  final String aadhar;

  const HomeScreen({
    super.key,
    required this.username,
    required this.userName,
    required this.phone,
    required this.aadhar,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Strict check on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLocationRequirements();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkLocationRequirements();
    }
  }

  Future<void> _checkLocationRequirements() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Check Service
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) _showLocationServiceDialog();
      return;
    }

    // 2. Check Permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) _showLocationPermissionDialog(false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) _showLocationPermissionDialog(true);
      return;
    }
    
    // If all good, close any existing dialogs if unique key approach used, 
    // or we can rely on user interaction. Here we assume dialogs are modal 
    // and blocking until issue resolved.
    // If we are here, it means location is enabled and permitted.
    // If a dialog was open, we might need to pop it? 
    // Since we re-check on resume, the "Open Settings" flow returns here.
    // However, if we just call this, we don't know if a dialog is currently open.
    // Simpler approach: The dialogs have "Retry" or "Open Settings". 
    // If "Open Settings" is clicked, user goes out, comes back, `didChangeAppLifecycleState` runs this again.
    // If resolved, we just need to ensure no dialog is blocking. 
    // BUT `showDialog` pushes a route. We can't easily "close previous" without context tracking.
    // Instead, let the dialog handle the "Retry" action which calls this method again.
    // If successful, we pop the dialog inside the checking logic? No, that's messy.
    // Better: The dialog blocks. The only exit is "Open Settings" -> App Cycle -> Check -> If Good -> Pop Dialog?
    // OR "Retry" -> Check -> If Good -> Pop.
    
    // We already have logic below to handle specific actions.
  }

  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: const Text('Location Services Disabled'),
            content: const Text('Please enable Location Services to use this app for safety features like SOS and Incident Reporting.'),
            actions: <Widget>[
              TextButton(
                child: const Text('ENABLE'),
                onPressed: () async {
                  await Geolocator.openLocationSettings();
                  // Dialog remains until user comes back and we re-check or they click a "Done" button?
                  // Better to close this dialog and let the lifecycle listener re-trigger if still off.
                  // But we want to BLOCK. 
                  // So we DON'T close it. We wait for resume.
                  // BUT invalidating the dialog from outside is hard.
                  // Let's add a "I've Enabled It" button which checks and closes if true.
                },
              ),
              TextButton(
                child: const Text('RETRY'),
                onPressed: () async {
                  bool enabled = await Geolocator.isLocationServiceEnabled();
                  if (enabled && context.mounted) {
                    Navigator.of(context).pop();
                    _checkLocationRequirements(); // Continue to check permissions
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLocationPermissionDialog(bool permanentlyDenied) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: const Text('Location Permission Required'),
            content: Text(permanentlyDenied 
              ? 'Location permission is permanently denied. Please enable it in app settings to use SOS features.'
              : 'This app needs location access to function correctly. Please grant permission.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OPEN SETTINGS'),
                onPressed: () async {
                  await Geolocator.openAppSettings();
                  // Similarly, wait for user to come back.
                },
              ),
              TextButton(
                child: const Text('RETRY'),
                onPressed: () async {
                  LocationPermission permission = await Geolocator.checkPermission();
                  if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
                    if (context.mounted) Navigator.of(context).pop();
                  } else if (!permanentlyDenied) {
                    // Try requesting again if not permanent
                    permission = await Geolocator.requestPermission();
                    if ((permission == LocationPermission.whileInUse || permission == LocationPermission.always) && context.mounted) {
                      Navigator.of(context).pop();
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  void _sendSOS(BuildContext context) async {
    // Show sending indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.red),
            SizedBox(height: 16),
            Text('Fetching location & sending SOS...', style: TextStyle(color: Colors.white, decoration: TextDecoration.none, fontSize: 14)),
          ],
        ),
      ),
    );

    String locationInfo = 'Location from app';

    try {
      Position position = await _determinePosition();
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
        if (placemarks.isNotEmpty) {
           Placemark place = placemarks[0];
           locationInfo = '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode} (${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)})'; 
        } else {
           locationInfo = '${position.latitude}, ${position.longitude}';
        }
      } catch (e) {
        // If geocoding fails, use coordinates
        locationInfo = '${position.latitude}, ${position.longitude}';
      }
    } catch (e) {
      print('Location error: $e');
      // If permission denied or service disabled, still try to send SOS but with default msg
       locationInfo = 'Location error: $e';
    }

    // Close loading dialog
    if (context.mounted) Navigator.pop(context);

    await FirebaseService.sendSOS(
      userId: widget.username,
      userName: widget.userName,
      location: locationInfo,
    );

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.red,
          title: const Text('SOS ALERT SENT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Text(
            'Emergency SOS has been sent to the nearest police station!\n\nDetails:\n$locationInfo',
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
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        image: DecorationImage(
          image: AssetImage('assets/images/app_background.png'),
          fit: BoxFit.cover,
          opacity: 0.85,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // Top navigation bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: _buildNavButton('WRITE TO US', () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => WriteToUsScreen(
                                userName: widget.userName,
                                userId: widget.username,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: _buildNavButton('GUIDANCE\nAND RULES', () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const GuidanceScreen()));
                        }),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: _buildNavButton('REPORT\nINCIDENT', () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ReportIncidentScreen(
                                userName: widget.userName,
                                userId: widget.username,
                                aadhar: widget.aadhar,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: _buildNavButton('MY\nPROFILE', () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProfileScreen(
                                username: widget.username,
                                name: widget.userName,
                                phone: widget.phone,
                                aadhar: widget.aadhar,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Report to Police button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReportIncidentScreen(
                          userName: widget.userName,
                          userId: widget.username,
                          aadhar: widget.aadhar,
                        ),
                      ),
                    );
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
                          child: Text(
                            'ENTER YOUR QUERY HERE ....',
                            style: TextStyle(color: Colors.grey),
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
                            icon: const Icon(Icons.arrow_upward, size: 30),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AIChatbotScreen(
                                    userName: widget.userName,
                                    userId: widget.username,
                                  ),
                                ),
                              );
                            },
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
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Color(0xFFDC2626),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
                  ),
                  child: const Center(
                    child: Text(
                      'SOS',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28),
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
        height: 60, // Fixed height to make buttons even
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E3A8A),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

