/// Single selectable option for a post-scan questionnaire item.
class MimeQuestionOption {
  const MimeQuestionOption({
    required this.value,
    required this.labelEn,
    required this.labelBn,
  });

  final int value;
  final String labelEn;
  final String labelBn;

  String labelFor(bool bangla) => bangla ? labelBn : labelEn;
}

/// One post-scan IntelliProve questionnaire question.
class MimeQuestion {
  const MimeQuestion({
    required this.lookupKey,
    required this.questionEn,
    required this.questionBn,
    required this.options,
    this.subtitleEn,
    this.subtitleBn,
  });

  final String lookupKey;
  final String questionEn;
  final String questionBn;
  final String? subtitleEn;
  final String? subtitleBn;
  final List<MimeQuestionOption> options;

  String questionFor(bool bangla) => bangla ? questionBn : questionEn;

  String? subtitleFor(bool bangla) {
    final value = bangla ? subtitleBn : subtitleEn;
    if (value == null || value.trim().isEmpty) return null;
    return value;
  }
}
