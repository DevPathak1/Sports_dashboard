// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBgdKJiFf68H5nob3lhnoMRiBe5QTJQQqQ',
    appId: '1:552605216280:web:76e657bf3d0c1701329d6d',
    messagingSenderId: '552605216280',
    projectId: 'scu-sports-storage',
    authDomain: 'scu-sports-storage.firebaseapp.com',
    storageBucket: 'scu-sports-storage.firebasestorage.app',
    measurementId: 'G-ZLK8RFDYLV',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB0S7lP6PVcmITuuUPdapJ7JmkwvTnpEBs',
    appId: '1:552605216280:android:3341b0cdd4dc5f53329d6d',
    messagingSenderId: '552605216280',
    projectId: 'scu-sports-storage',
    storageBucket: 'scu-sports-storage.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCqyRmCaCVaU5GNMCaJ8IUmKdenFQR50_4',
    appId: '1:552605216280:ios:6bffb24a390c9b9a329d6d',
    messagingSenderId: '552605216280',
    projectId: 'scu-sports-storage',
    storageBucket: 'scu-sports-storage.firebasestorage.app',
    iosBundleId: 'com.example.sportsDashboard',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCqyRmCaCVaU5GNMCaJ8IUmKdenFQR50_4',
    appId: '1:552605216280:ios:6bffb24a390c9b9a329d6d',
    messagingSenderId: '552605216280',
    projectId: 'scu-sports-storage',
    storageBucket: 'scu-sports-storage.firebasestorage.app',
    iosBundleId: 'com.example.sportsDashboard',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBgdKJiFf68H5nob3lhnoMRiBe5QTJQQqQ',
    appId: '1:552605216280:web:e40838b0edf6d2b2329d6d',
    messagingSenderId: '552605216280',
    projectId: 'scu-sports-storage',
    authDomain: 'scu-sports-storage.firebaseapp.com',
    storageBucket: 'scu-sports-storage.firebasestorage.app',
    measurementId: 'G-KV532CZZ9V',
  );
}
