/// Lenient JSON readers shared by the subscription models.
library;

int? asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

List<String> asStringList(Object? value) {
  if (value is! List) return const [];
  return value.map((e) => e.toString()).toList(growable: false);
}

/// Trimmed string, or `null` when missing / blank.
String? asNullableString(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

Map<String, dynamic>? asJsonMap(Object? value) =>
    value is Map ? Map<String, dynamic>.from(value) : null;
