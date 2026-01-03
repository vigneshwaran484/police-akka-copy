import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'firebase_options.dart';
import 'config/supabase_config.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  
  // Initialize Firebase FIRST (so Supabase callback has access to it)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Supabase with Firebase token callback
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl, 
    anonKey: SupabaseConfig.supabaseAnonKey,
    accessToken: () async {
      final user = fa.FirebaseAuth.instance.currentUser;
      if (user != null) {
        // This forces Supabase to use the Firebase identity for all DB requests
        return await user.getIdToken();
      }
      return null;
    },
  );
  
  runApp(const PoliceApp());
}



class PoliceApp extends StatelessWidget {
  const PoliceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TN Police Gov',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
    );
  }
}
