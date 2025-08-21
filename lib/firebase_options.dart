// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD21LFcoM27f55kUt3JJ2GEkmXFo7FF_gM',
    appId: '1:399319667627:web:175ae0af5e644486b578ee',
    messagingSenderId: '399319667627',
    projectId: 'biteshare-ee6c8',
    authDomain: 'biteshare-ee6c8.firebaseapp.com',
    storageBucket: 'biteshare-ee6c8.firebasestorage.app',
    measurementId: 'G-43F81V8WEZ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC8sRStUDF3BFFkrUtWkUKJxbeiMWxd2_A',
    appId: '1:399319667627:android:bad72e2256b5984db578ee',
    messagingSenderId: '399319667627',
    projectId: 'biteshare-ee6c8',
    storageBucket: 'biteshare-ee6c8.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAijkmLo9K21wBX81qN4CEx4lV_VatlUxo',
    appId: '1:399319667627:ios:39c51ce730ef4715b578ee',
    messagingSenderId: '399319667627',
    projectId: 'biteshare-ee6c8',
    storageBucket: 'biteshare-ee6c8.firebasestorage.app',
    iosBundleId: 'com.example.biteshare',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'YOUR_MACOS_API_KEY',
    appId: '1:399319667627:ios:39c51ce730ef4715b578ee',
    messagingSenderId: '399319667627',
    projectId: 'biteshare-ee6c8',
    storageBucket: 'biteshare-ee6c8.appspot.com',
    iosBundleId: 'com.biteshare.recipeapp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'YOUR_WINDOWS_API_KEY',
    appId: '1:399319667627:web:67b045121cce29fcb578ee',
    messagingSenderId: '399319667627',
    projectId: 'biteshare-ee6c8',
    authDomain: 'biteshare-ee6c8.firebaseapp.com',
    storageBucket: 'biteshare-ee6c8.appspot.com',
    measurementId: 'G-XXXXXXXXXX',
  );
}