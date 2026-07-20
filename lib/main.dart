import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/app_startup.dart';
import 'core/services/preferences_service.dart';

Future<void> main() async {
  final startup = await AppStartup.load();
  runApp(
    ProviderScope(
      overrides: [
        preferencesServiceProvider.overrideWithValue(startup.preferences),
      ],
      child: const MovieBookingApp(),
    ),
  );
}
