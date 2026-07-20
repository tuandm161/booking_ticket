import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/services/preferences_service.dart';
import '../firebase_options.dart';

class AppStartup {
  const AppStartup._(this.preferences, this.firebaseInitialized);

  final PreferencesService preferences;
  final bool firebaseInitialized;

  static Future<AppStartup> load() async {
    WidgetsFlutterBinding.ensureInitialized();
    final prefs = await SharedPreferences.getInstance();
    var firebaseInitialized = false;
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      firebaseInitialized = true;
    } on FirebaseException {
      // google-services.json is supplied when a Firebase project is attached.
    }
    return AppStartup._(PreferencesService(prefs), firebaseInitialized);
  }
}
