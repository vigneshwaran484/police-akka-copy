import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBs8Lva1lRvkoIvu29kqRbwoPQ_WmjTf18',
    appId: '1:781806321386:web:dbd88a5e79eb67800d2193',
    messagingSenderId: '781806321386',
    projectId: 'tn-police-app-ac17a',
    authDomain: 'tn-police-app-ac17a.firebaseapp.com',
    storageBucket: 'tn-police-app-ac17a.firebasestorage.app',
    measurementId: 'G-BE645HZHMX',
  );
}

