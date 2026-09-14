// File generated for Firebase configuration
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
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
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC1gPwF8z67ul7rHaNNBayYUxQiPsGvAxE',
    appId: '1:749958478708:web:6f366fccddda6d4c584a21',
    messagingSenderId: '749958478708',
    projectId: 'jeihanmuthia-assesment-ppkd',
    authDomain: 'jeihanmuthia-assesment-ppkd.firebaseapp.com',
    storageBucket: 'jeihanmuthia-assesment-ppkd.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC1gPwF8z67ul7rHaNNBayYUxQiPsGvAxE',
    appId: '1:749958478708:android:6f366fccddda6d4c584a21',
    messagingSenderId: '749958478708',
    projectId: 'jeihanmuthia-assesment-ppkd',
    storageBucket: 'jeihanmuthia-assesment-ppkd.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC1gPwF8z67ul7rHaNNBayYUxQiPsGvAxE',
    appId: '1:749958478708:ios:6f366fccddda6d4c584a21',
    messagingSenderId: '749958478708',
    projectId: 'jeihanmuthia-assesment-ppkd',
    storageBucket: 'jeihanmuthia-assesment-ppkd.firebasestorage.app',
    iosBundleId: 'com.halojeje.assesment_ppkd',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC1gPwF8z67ul7rHaNNBayYUxQiPsGvAxE',
    appId: '1:749958478708:ios:6f366fccddda6d4c584a21',
    messagingSenderId: '749958478708',
    projectId: 'jeihanmuthia-assesment-ppkd',
    storageBucket: 'jeihanmuthia-assesment-ppkd.firebasestorage.app',
    iosBundleId: 'com.halojeje.assesment_ppkd',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC1gPwF8z67ul7rHaNNBayYUxQiPsGvAxE',
    appId: '1:749958478708:web:6f366fccddda6d4c584a21',
    messagingSenderId: '749958478708',
    projectId: 'jeihanmuthia-assesment-ppkd',
    authDomain: 'jeihanmuthia-assesment-ppkd.firebaseapp.com',
    storageBucket: 'jeihanmuthia-assesment-ppkd.firebasestorage.app',
  );
}
