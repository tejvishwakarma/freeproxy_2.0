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
    apiKey: 'AIzaSyAtAQIPBTNtBczh_rylXcJrKrMhwjA-SGU',
    appId: '1:516150859033:web:c37f5e7d3939bfcd93e188',
    messagingSenderId: '516150859033',
    projectId: 'freeproxy-f9fac',
    authDomain: 'freeproxy-f9fac.firebaseapp.com',
    storageBucket: 'freeproxy-f9fac.appspot.com',
    measurementId: 'G-MTGX8C1X05',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDzuOpCY1zd_oVKJ6coJyjjtPcWKQaVC_M',
    appId: '1:516150859033:android:9f392ee16013e4c093e188',
    messagingSenderId: '516150859033',
    projectId: 'freeproxy-f9fac',
    storageBucket: 'freeproxy-f9fac.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDbn_V8AK0f4VGxjHkavpSsN3bbNZdCFyI',
    appId: '1:516150859033:ios:258d140be4af514c93e188',
    messagingSenderId: '516150859033',
    projectId: 'freeproxy-f9fac',
    storageBucket: 'freeproxy-f9fac.appspot.com',
    iosBundleId: 'com.digitalchitrakar.freeproxy',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDbn_V8AK0f4VGxjHkavpSsN3bbNZdCFyI',
    appId: '1:516150859033:ios:258d140be4af514c93e188',
    messagingSenderId: '516150859033',
    projectId: 'freeproxy-f9fac',
    storageBucket: 'freeproxy-f9fac.appspot.com',
    iosBundleId: 'com.digitalchitrakar.freeproxy',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAtAQIPBTNtBczh_rylXcJrKrMhwjA-SGU',
    appId: '1:516150859033:web:c37f5e7d3939bfcd93e188',
    messagingSenderId: '516150859033',
    projectId: 'freeproxy-f9fac',
    authDomain: 'freeproxy-f9fac.firebaseapp.com',
    storageBucket: 'freeproxy-f9fac.appspot.com',
    measurementId: 'G-MTGX8C1X05',
  );
}
