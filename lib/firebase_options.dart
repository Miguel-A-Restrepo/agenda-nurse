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
    apiKey: 'AIzaSyCQpTbU7CD4s5EXndx_DIvB07w06t4TymU',
    appId: '1:465364131593:web:1e352f1bb454b55df07dd8',
    messagingSenderId: '465364131593',
    projectId: 'agenda-nurse-4a18a',
    authDomain: 'agenda-nurse-4a18a.firebaseapp.com',
    storageBucket: 'agenda-nurse-4a18a.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAGrOa7Ug7nAH_4K8aTa24dzGzQl5liKoM',
    appId: '1:465364131593:android:25a46e7d2aedaab9f07dd8',
    messagingSenderId: '465364131593',
    projectId: 'agenda-nurse-4a18a',
    storageBucket: 'agenda-nurse-4a18a.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC_OoNDChfcpzf_HjS2VJbwDP8LGCXbnJ4',
    appId: '1:465364131593:ios:b35ea994f1abdbe0f07dd8',
    messagingSenderId: '465364131593',
    projectId: 'agenda-nurse-4a18a',
    storageBucket: 'agenda-nurse-4a18a.appspot.com',
    iosClientId: '465364131593-2o9rmou43jacqtke8mmk2ulvvj0lkrr1.apps.googleusercontent.com',
    iosBundleId: 'com.techtitans.agendanurse',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC_OoNDChfcpzf_HjS2VJbwDP8LGCXbnJ4',
    appId: '1:465364131593:ios:b35ea994f1abdbe0f07dd8',
    messagingSenderId: '465364131593',
    projectId: 'agenda-nurse-4a18a',
    storageBucket: 'agenda-nurse-4a18a.appspot.com',
    iosClientId: '465364131593-2o9rmou43jacqtke8mmk2ulvvj0lkrr1.apps.googleusercontent.com',
    iosBundleId: 'com.techtitans.agendanurse',
  );
}
