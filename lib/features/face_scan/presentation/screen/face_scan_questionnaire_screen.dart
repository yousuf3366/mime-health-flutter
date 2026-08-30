import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mime_health/core/extensions/context_extensions.dart';
import 'package:mime_health/core/theme/app_colors.dart';
import 'package:mime_health/core/widgets/app_app_bar.dart';

import '../../../../core/localization/l10n_keys.dart';
import '../../../language/presentation/provider/language_provider.dart';
import '../../domain/catalog/mime_question_catalog.dart';
import '../../domain/entity/face_scan_entity.dart';
import '../../domain/entity/mime_question.dart';

/// Post-scan questionnaire (one question at a time).
///
/// On finish, replaces itself with [completionRoute] (e.g. results loading)
/// so the pre-scan screen never flashes, then invokes [onCompleted].
/// Cancel / system back still pops with an empty list / `null`.
class FaceScanQuestionnaireScreen extends ConsumerStatefulWidget {
  const FaceScanQuestionnaireScreen({
    super.key,
    this.questions = MimeQuestionCatalog.postScanQuestions,
    this.onCompleted,
    this.completionRoute,
  });

  final List<MimeQuestion> questions;

  /// Called after [completionRoute] replaces this screen (finish only).
  final ValueChanged<List<FaceScanQuestionAnswer>>? onCompleted;

  /// Route to show immediately when the questionnaire finishes.
  final Route<void>? completionRoute;

  @override
  ConsumerState<FaceScanQuestionnaireScreen> createState() =>
      _FaceScanQuestionnaireScreenState();
}

class _FaceScanQuestionnaireScreenState
    extends ConsumerState<FaceScanQuestionnaireScreen> {
  var _index = 0;
  final _answers = <FaceScanQuestionAnswer>[];

  MimeQuestion get _current => widget.questions[_index];

  void _select(int value) {
    _answers.add(
      FaceScanQuestionAnswer(
        lookupKey: _current.lookupKey,
        value: value,
      ),
    );
    _goNext();
  }

  /// Skips the current question (no answer) and advances.
  void _skipCurrent() => _goNext();

  void _goNext() {
    if (_index < widget.questions.length - 1) {
      setState(() => _index++);
    } else {
      _finishQuestionnaire(List<FaceScanQuestionAnswer>.from(_answers));
    }
  }

  void _finishQuestionnaire(List<FaceScanQuestionAnswer> answers) {
    final route = widget.completionRoute;
    if (route != null) {
      Navigator.of(context).pushReplacement(route);
      widget.onCompleted?.call(answers);
      return;
    }
    Navigator.of(context).pop(answers);
  }

  void _cancelQuestionnaire() {
    Navigator.of(context).pop(<FaceScanQuestionAnswer>[]);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(languageControllerProvider);
    final bangla = l10n.entity.code == 'bn';

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppAppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: _cancelQuestionnaire,
            icon: Icon(
              Icons.close,
              color: AppColors.icon,
              size: context.scaleWidth(24),
            ),
            tooltip: l10n.t(L10nKeys.mediaCancel),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            context.defaultPaddingSc,
            context.scaleHeight(4),
            context.defaultPaddingSc,
            context.scaleHeight(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: context.defaultPaddingSc,),
              Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.scaleWidth(20),
                    vertical: context.scaleHeight(12),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundDeep,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: AppColors.glassBorder,
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    l10n.t(L10nKeys.questionnaireTitle),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: context.titleFontSize,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SizedBox(height: context.scaleHeight(20)),
              Text(
                _current.questionFor(bangla),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.success,
                  fontSize: context.largeFontSize,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
              if (_current.subtitleFor(bangla) != null) ...[
                SizedBox(height: context.scaleHeight(8)),
                Text(
                  _current.subtitleFor(bangla)!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: context.fontSize,
                  ),
                ),
              ],
              SizedBox(height: context.scaleHeight(24)),
              ...List.generate(_current.options.length, (i) {
                final option = _current.options[i];
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: context.scaleHeight(10),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _select(option.value),
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: context.scaleWidth(16),
                          vertical: context.scaleHeight(16),
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.glass,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: AppColors.error.withValues(alpha: 0.45),
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          option.labelFor(bangla),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: context.bodyFontSize,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
              TextButton(
                onPressed: _skipCurrent,
                child: Text(
                  l10n.t(L10nKeys.questionnaireSkip),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: context.fontSize,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
