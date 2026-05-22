import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

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
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC4AKdJIU7mzNk5FTG-Zuk34NkpkSPQnks',
    appId: '1:1077828578739:android:886b33895cd75be5722fc6',
    messagingSenderId: '1077828578739',
    projectId: 'romanza-app',
    authDomain: 'romanza-app.firebaseapp.com',
    storageBucket: 'romanza-app.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC4AKdJIU7mzNk5FTG-Zuk34NkpkSPQnks',
    appId: '1:1077828578739:android:886b33895cd75be5722fc6',
    messagingSenderId: '1077828578739',
    projectId: 'romanza-app',
    storageBucket: 'romanza-app.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDtSduh-bOozUXeP1FdW8fiB80bX53XsQI',
    appId: '1:1077828578739:ios:883249e72181beda722fc6',
    messagingSenderId: '1077828578739',
    projectId: 'romanza-app',
    storageBucket: 'romanza-app.firebasestorage.app',
    iosBundleId: 'com.example.romanzaApp',
  );

  static const FirebaseOptions macos = ios;
}
