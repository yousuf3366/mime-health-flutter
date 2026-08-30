import 'package:equatable/equatable.dart';

/// Domain representation of loaded localization strings.
class LanguageEntity extends Equatable {
  const LanguageEntity({
    required this.code,
    required this.strings,
  });

  final String code;
  final Map<String, String> strings;

  String translate(String key, {String? fallback}) {
    return strings[key] ?? fallback ?? key;
  }

  LanguageEntity copyWith({
    String? code,
    Map<String, String>? strings,
  }) {
    return LanguageEntity(
      code: code ?? this.code,
      strings: strings ?? this.strings,
    );
  }

  @override
  List<Object?> get props => [code, strings];
}
