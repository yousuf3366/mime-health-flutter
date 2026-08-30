import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mime_health/app.dart';
import 'package:mime_health/core/providers/core_providers.dart';
import 'package:mime_health/core/storage/shared_prefs_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('MimeHealthApp boots to splash', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPrefsService.create();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPrefsProvider.overrideWithValue(prefs),
        ],
        child: const MimeHealthApp(),
      ),
    );

    await tester.pump();
    expect(find.textContaining('Mime Health'), findsWidgets);
  });
}
