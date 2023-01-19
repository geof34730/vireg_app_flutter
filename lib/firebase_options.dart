// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyBS8nX1_68lKOyi0gSRTxgjYka70rh-KmA',
    appId: '1:126297073825:web:9716f5ecbcd1c1005768e0',
    messagingSenderId: '126297073825',
    projectId: 'vireg-8c22f',
    authDomain: 'vireg-8c22f.firebaseapp.com',
    storageBucket: 'vireg-8c22f.appspot.com',
    measurementId: 'G-GYGVTPGTYP',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCcECli4yQrIw5Pw8L4jEOye4VauSOUti0',
    appId: '1:126297073825:android:1d48fd88ab5631c75768e0',
    messagingSenderId: '126297073825',
    projectId: 'vireg-8c22f',
    storageBucket: 'vireg-8c22f.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyABN9D1EsboU6voz97yppYgFee94f1Ifek',
    appId: '1:126297073825:ios:4f5899ffdaea0cb35768e0',
    messagingSenderId: '126297073825',
    projectId: 'vireg-8c22f',
    storageBucket: 'vireg-8c22f.appspot.com',
    iosClientId: '126297073825-jfbat14anc8qme4af9lu1cln3gqlbi4h.apps.googleusercontent.com',
    iosBundleId: 'verbeirregulieranglais.com.example.verbeIrregulierAnglais',
  );
}
