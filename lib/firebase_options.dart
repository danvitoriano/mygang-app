// Gere valores reais com: dart pub global activate flutterfire_cli && flutterfire configure
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        return ios;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDx-tTGlQZlj1Mz2EZ24b4BdOXjs9CnPnQ',
    appId: '1:127328884954:web:8e0c92da8e929bfa4dade3',
    messagingSenderId: '127328884954',
    projectId: 'mygang-mvp-apr2026',
    authDomain: 'mygang-mvp-apr2026.firebaseapp.com',
    storageBucket: 'mygang-mvp-apr2026.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDEegzp8kc97ynTeMN8lyKLPoCb63j80LY',
    appId: '1:127328884954:android:ae4b52c1c2a420404dade3',
    messagingSenderId: '127328884954',
    projectId: 'mygang-mvp-apr2026',
    storageBucket: 'mygang-mvp-apr2026.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBrrbGqfU9xCoIvSuurQk555p59HdxJeVk',
    appId: '1:127328884954:ios:fed680490d73b0da4dade3',
    messagingSenderId: '127328884954',
    projectId: 'mygang-mvp-apr2026',
    storageBucket: 'mygang-mvp-apr2026.firebasestorage.app',
    iosBundleId: 'com.example.mygang',
  );

}