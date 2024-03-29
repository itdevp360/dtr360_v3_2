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
    apiKey: 'AIzaSyCtGUTdZz41i1xTVMZxwIXx9-KwD1QBgbs',
    appId: '1:1047099632248:web:a90f1feb5b97c36c42db8d',
    messagingSenderId: '1047099632248',
    projectId: 'dtr360-10879',
    authDomain: 'dtr360-10879.firebaseapp.com',
    databaseURL: 'https://dtr360-10879-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'dtr360-10879.appspot.com',
    measurementId: 'G-5C4FG4S15G',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDO5FcOrm6YKCKTNILiUavIxv6-WqaiQlM',
    appId: '1:1047099632248:android:183fcbb85b967ec442db8d',
    messagingSenderId: '1047099632248',
    projectId: 'dtr360-10879',
    databaseURL: 'https://dtr360-10879-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'dtr360-10879.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyClRdrz6MHkYn7jCMfUHww7X9_qsfAydiA',
    appId: '1:1047099632248:ios:5698ab216006a09b42db8d',
    messagingSenderId: '1047099632248',
    projectId: 'dtr360-10879',
    databaseURL: 'https://dtr360-10879-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'dtr360-10879.appspot.com',
    iosClientId: '1047099632248-kfsrt4a50aepvm5gd0pjt8pd6jnt6hev.apps.googleusercontent.com',
    iosBundleId: 'com.people360.com.ph.dtr360',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyClRdrz6MHkYn7jCMfUHww7X9_qsfAydiA',
    appId: '1:1047099632248:ios:5db1bdd5bc5abaca42db8d',
    messagingSenderId: '1047099632248',
    projectId: 'dtr360-10879',
    databaseURL: 'https://dtr360-10879-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'dtr360-10879.appspot.com',
    iosClientId: '1047099632248-l5u1ptq4l556njil7q4781vjr45i3699.apps.googleusercontent.com',
    iosBundleId: 'com.example.dtr360Version32',
  );
}
