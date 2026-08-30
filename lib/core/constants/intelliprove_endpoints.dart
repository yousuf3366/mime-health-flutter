/// IntelliProve Engine path constants (relative to [AppConfig.intelliProveBaseUrl]).
///
/// Only Q&A-related Engine APIs remain; scan URL / biomarkers come from Mime.
class IntelliProveEndpoints {
  IntelliProveEndpoints._();

  static const String users = '/v2/users';
  static const String questionAnswer = '/v2/questions/answer';
  static const String questionAnswerMany = '/v2/questions/answer/many';
}
