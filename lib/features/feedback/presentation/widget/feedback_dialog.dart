import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/l10n_keys.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field1.dart';
import '../../../language/presentation/provider/language_provider.dart';
import '../provider/feedback_di.dart';

Future<void> showFeedbackDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const FeedbackDialog(),
  );
}

class FeedbackDialog extends ConsumerStatefulWidget {
  const FeedbackDialog({super.key});

  @override
  ConsumerState<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends ConsumerState<FeedbackDialog> {
  final AudioRecorder _recorder = AudioRecorder();

  String _message = '';
  String? _audioPath;
  String? _error;
  bool _isRecording = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    unawaited(_recorder.dispose());
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _recorder.stop();
      if (!mounted) return;
      setState(() {
        _isRecording = false;
        _audioPath = path;
        _error = null;
      });
      return;
    }

    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      if (!mounted) return;
      final l10n = ref.read(languageControllerProvider);
      setState(() {
        _error = l10n.t(L10nKeys.feedbackMicrophonePermission);
      });
      return;
    }

    final directory = await getTemporaryDirectory();
    final path =
        '${directory.path}/feedback_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: path,
    );
    if (!mounted) return;
    setState(() {
      _isRecording = true;
      _audioPath = null;
      _error = null;
    });
  }

  Future<void> _removeAudio() async {
    if (_isRecording) {
      await _recorder.cancel();
    }
    final path = _audioPath;
    if (path != null) {
      final file = File(path);
      if (await file.exists()) await file.delete();
    }
    if (!mounted) return;
    setState(() {
      _isRecording = false;
      _audioPath = null;
    });
  }

  Future<void> _submit() async {
    if (_isRecording) {
      final path = await _recorder.stop();
      if (!mounted) return;
      setState(() {
        _isRecording = false;
        _audioPath = path;
      });
    }

    final l10n = ref.read(languageControllerProvider);
    if (_message.trim().isEmpty && _audioPath == null) {
      setState(() {
        _error = l10n.t(L10nKeys.feedbackRequired);
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    final result = await ref
        .read(submitFeedbackUseCaseProvider)
        .call(message: _message, audioPath: _audioPath);
    if (!mounted) return;

    result.when(
      success: (feedback) {
        Navigator.of(context).pop();
        ref.read(snackbarServiceProvider).showSuccess(feedback.successMessage);
      },
      failure: (error) {
        setState(() {
          _isSubmitting = false;
          _error = error.message;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(languageControllerProvider);
    final hasAudio = _audioPath != null;

    return AlertDialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scaleWidth(20)),
        side: const BorderSide(color: AppColors.border),
      ),
      title: Text(
        l10n.t(L10nKeys.feedbackTitle),
        style: const TextStyle(color: AppColors.textPrimary),
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: context.scaleWidth(360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField1(
                label: l10n.t(L10nKeys.feedbackMessage),
                initialValue: _message,
                isMultiline: true,
                minLines: 3,
                maxLines: 5,
                onChanged: (value) {
                  _message = value;
                  if (_error != null) setState(() => _error = null);
                },
              ),
              SizedBox(height: context.scaleHeight(16)),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isSubmitting ? null : _toggleRecording,
                  icon: Icon(
                    _isRecording ? Icons.stop_circle : Icons.mic,
                    color: _isRecording
                        ? AppColors.error
                        : AppColors.primaryContainer,
                  ),
                  label: Text(
                    l10n.t(
                      _isRecording
                          ? L10nKeys.feedbackStopRecording
                          : L10nKeys.feedbackRecordVoice,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.outlineVariant),
                    padding: EdgeInsets.symmetric(
                      vertical: context.scaleHeight(14),
                    ),
                  ),
                ),
              ),
              if (hasAudio) ...[
                SizedBox(height: context.scaleHeight(10)),
                Row(
                  children: [
                    const Icon(Icons.audio_file, color: AppColors.success),
                    SizedBox(width: context.scaleWidth(8)),
                    Expanded(
                      child: Text(
                        l10n.t(L10nKeys.feedbackAudioReady),
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                    IconButton(
                      onPressed: _isSubmitting ? null : _removeAudio,
                      tooltip: l10n.t(L10nKeys.feedbackRemoveAudio),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ],
              if (_error != null) ...[
                SizedBox(height: context.scaleHeight(10)),
                Text(
                  _error!,
                  style: const TextStyle(color: AppColors.error),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting
              ? null
              : () async {
                  await _removeAudio();
                  if (context.mounted) Navigator.of(context).pop();
                },
          child: Text(l10n.t(L10nKeys.feedbackCancel)),
        ),
        AppButton(
          label: l10n.t(L10nKeys.feedbackSend),
          onPressed: _submit,
          isLoading: _isSubmitting,
          expand: false,
        ),
      ],
    );
  }
}
