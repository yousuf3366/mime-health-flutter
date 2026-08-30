/// DTO for `GET /translations/locales/{locale}`.
class TranslationsResponseModel {
  const TranslationsResponseModel({
    required this.success,
    required this.message,
    required this.locale,
    required this.items,
    this.version,
    this.count,
  });

  final bool success;
  final String message;
  final String locale;
  final Map<String, String> items;
  final String? version;
  final int? count;

  factory TranslationsResponseModel.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?) ?? {};
    final rawItems = (data['items'] as Map<String, dynamic>?) ?? {};
    final meta = (data['meta'] as Map<String, dynamic>?) ?? {};

    return TranslationsResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      locale: data['locale']?.toString() ?? '',
      items: rawItems.map(
        (key, value) => MapEntry(key, value?.toString() ?? ''),
      ),
      version: meta['version']?.toString(),
      count: (meta['count'] as num?)?.toInt(),
    );
  }
}
