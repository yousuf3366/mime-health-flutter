import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/providers/core_providers.dart';
import 'core/storage/shared_prefs_service.dart';
import 'core/utils/logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.logNetworkTarget();

  await Firebase.initializeApp();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final prefs = await SharedPrefsService.create();
  final container = ProviderContainer(
    overrides: [
      sharedPrefsProvider.overrideWithValue(prefs),
    ],
  );

  // Initialize connectivity monitoring before the first frame.
  await container.read(connectivityServiceProvider).initialize();
  AppLogger.d('Connectivity service initialized');

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MimeHealthApp(),
    ),
  );
}
