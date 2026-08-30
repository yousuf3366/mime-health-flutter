import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/language/presentation/provider/language_provider.dart';

/// Extension helpers for reading localized strings from a [WidgetRef]/[Ref].
extension LocalizationRef on WidgetRef {
  String tr(String key, {String? fallback}) {
    return read(languageControllerProvider).t(key, fallback: fallback);
  }
}
