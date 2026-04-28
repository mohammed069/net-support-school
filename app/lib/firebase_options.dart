import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

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
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBdjNULFR98ciRu3SxS4pPk0gCH8mMqIT0',
    appId: '1:102668768091:web:517518837fbd8e97ecc07e',
    messagingSenderId: '102668768091',
    projectId: 'net-support-school',
    authDomain: 'net-support-school.firebaseapp.com',
    storageBucket: 'net-support-school.firebasestorage.app',
    measurementId: 'G-GSSYE2JYNG',
  );

  // Replace these placeholders by running `flutterfire configure`.

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBU7pswMExbJeDaAnnYe-jWI_32XvWtUSo',
    appId: '1:102668768091:android:2f5518838316387cecc07e',
    messagingSenderId: '102668768091',
    projectId: 'net-support-school',
    storageBucket: 'net-support-school.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCIqdMo2UkTADvbD6R8iDbEoiGv3NzLP0E',
    appId: '1:102668768091:ios:b915963e28670b0decc07e',
    messagingSenderId: '102668768091',
    projectId: 'net-support-school',
    storageBucket: 'net-support-school.firebasestorage.app',
    iosBundleId: 'com.example.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCIqdMo2UkTADvbD6R8iDbEoiGv3NzLP0E',
    appId: '1:102668768091:ios:b915963e28670b0decc07e',
    messagingSenderId: '102668768091',
    projectId: 'net-support-school',
    storageBucket: 'net-support-school.firebasestorage.app',
    iosBundleId: 'com.example.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBdjNULFR98ciRu3SxS4pPk0gCH8mMqIT0',
    appId: '1:102668768091:web:7108f4ab3d4005a8ecc07e',
    messagingSenderId: '102668768091',
    projectId: 'net-support-school',
    authDomain: 'net-support-school.firebaseapp.com',
    storageBucket: 'net-support-school.firebasestorage.app',
    measurementId: 'G-V91X9CR581',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'replace-with-linux-api-key',
    appId: 'replace-with-linux-app-id',
    messagingSenderId: 'replace-with-sender-id',
    projectId: 'replace-with-project-id',
    storageBucket: 'replace-with-storage-bucket',
  );
}
