// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// 
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
    apiKey: 'AIzaSyAGOH97K2FStDlOPc9zNTpGVmfescwGJP8',
    appId: '1:1034490958807:web:9e7fe1300c18f9432e7192',
    messagingSenderId: '1034490958807',
    projectId: 'hackathon-app123',
    authDomain: 'hackathon-app123.firebaseapp.com',
    storageBucket: 'hackathon-app123.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD1Lc7cYTOAiFnK203qCftahbtozaoDPfw',
    appId: '1:1034490958807:android:e7a51407171022832e7192',
    messagingSenderId: '1034490958807',
    projectId: 'hackathon-app123',
    storageBucket: 'hackathon-app123.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDWrt9aElcbFLvLRn5SKZt9JqJJ4G4l9uU',
    appId: '1:1034490958807:ios:594ec0b12897758d2e7192',
    messagingSenderId: '1034490958807',
    projectId: 'hackathon-app123',
    storageBucket: 'hackathon-app123.firebasestorage.app',
    iosBundleId: 'com.example.flutterApplication2',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDWrt9aElcbFLvLRn5SKZt9JqJJ4G4l9uU',
    appId: '1:1034490958807:ios:594ec0b12897758d2e7192',
    messagingSenderId: '1034490958807',
    projectId: 'hackathon-app123',
    storageBucket: 'hackathon-app123.firebasestorage.app',
    iosBundleId: 'com.example.flutterApplication2',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAGOH97K2FStDlOPc9zNTpGVmfescwGJP8',
    appId: '1:1034490958807:web:299ebf6a32671f682e7192',
    messagingSenderId: '1034490958807',
    projectId: 'hackathon-app123',
    authDomain: 'hackathon-app123.firebaseapp.com',
    storageBucket: 'hackathon-app123.firebasestorage.app',
  );
}
