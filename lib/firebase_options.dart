// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyAAKxZ2pbQfNIhVeryok2OgAWIrGObkDFE',
    appId: '1:903974262328:web:45881b5128da553181b8cd',
    messagingSenderId: '903974262328',
    projectId: 'primesse-aca86',
    authDomain: 'primesse-aca86.firebaseapp.com',
    storageBucket: 'primesse-aca86.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDzNwDk2tMj_Q4MlMdeOrTz-kKeSyp-gd0',
    appId: '1:903974262328:android:192dd9416821945f81b8cd',
    messagingSenderId: '903974262328',
    projectId: 'primesse-aca86',
    storageBucket: 'primesse-aca86.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDiHK0dujaWDo97AQOVWRi3mSsdSmKCTiY',
    appId: '1:903974262328:ios:117a04e1274accf481b8cd',
    messagingSenderId: '903974262328',
    projectId: 'primesse-aca86',
    storageBucket: 'primesse-aca86.appspot.com',
    iosBundleId: 'com.primesse.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDiHK0dujaWDo97AQOVWRi3mSsdSmKCTiY',
    appId: '1:903974262328:ios:03335d77fc73c91a81b8cd',
    messagingSenderId: '903974262328',
    projectId: 'primesse-aca86',
    storageBucket: 'primesse-aca86.appspot.com',
    iosBundleId: 'com.example.primesseApp.RunnerTests',
  );
}
