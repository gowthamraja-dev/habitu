import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:habitu/app/app.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Android: CONFIGURATION_NOT_FOUND = add SHA-1 in Firebase Console.
  // Run: cd android && ./gradlew signingReport  (use debug SHA-1).
  // Firebase Console → Project settings → Your apps → Android → Add fingerprint.
  // This disables app verification until you add SHA-1 (remove before release).
  await FirebaseAuth.instance.setSettings(
    appVerificationDisabledForTesting: true,
  );
  runApp(const HabituApp());
}
