import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mime_health/core/extensions/context_extensions.dart';
import 'package:mime_health/core/theme/app_colors.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/localization/l10n_keys.dart';
import '../../../language/presentation/provider/language_provider.dart';
import '../../domain/entity/consent_document_codes.dart';
import '../provider/terms_and_condition_provider.dart';

/// Displays a consent document from `/api/v1/consent-documents/{code}`.
class TermsAndConditionScreen extends ConsumerWidget {
  const TermsAndConditionScreen({
    super.key,
    this.documentCode = ConsentDocumentCodes.tos,
    this.fallbackTitleKey = L10nKeys.faceScanConsentLink,
  });

  final String documentCode;
  final String fallbackTitleKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(languageControllerProvider);
    final asyncDoc = ref.watch(consentDocumentProvider(documentCode));
    final fallbackTitle = l10n.t(fallbackTitleKey);

    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDeep,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.icon),
          onPressed: () => context.pop(),
        ),
        title: Text(
          asyncDoc.maybeWhen(
            data: (doc) => doc.title.isNotEmpty ? doc.title : fallbackTitle,
            orElse: () => fallbackTitle,
          ),
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: context.titleFontSize,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: asyncDoc.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primaryContainer),
          ),
          error: (error, _) => _ErrorBody(
            message: error is AppException
                ? error.message
                : l10n.t(L10nKeys.genericError),
            retryLabel: l10n.t(L10nKeys.retry),
            onRetry: () =>
                ref.invalidate(consentDocumentProvider(documentCode)),
          ),
          data: (doc) => Markdown(
            data: doc.content,
            padding: EdgeInsets.fromLTRB(
              context.defaultPaddingSc,
              context.scaleHeight(8),
              context.defaultPaddingSc,
              context.scaleHeight(24),
            ),
            styleSheet: MarkdownStyleSheet(
              p: TextStyle(
                color: AppColors.textSecondary,
                fontSize: context.fontSize,
                height: 1.45,
              ),
              h1: TextStyle(
                color: AppColors.textPrimary,
                fontSize: context.largeFontSize,
                fontWeight: FontWeight.w800,
                height: 1.3,
              ),
              h2: TextStyle(
                color: AppColors.textPrimary,
                fontSize: context.titleFontSize,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
              h3: TextStyle(
                color: AppColors.textPrimary,
                fontSize: context.bodyFontSize,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
              listBullet: TextStyle(
                color: AppColors.textSecondary,
                fontSize: context.fontSize,
              ),
              strong: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
              a: const TextStyle(
                color: AppColors.primaryContainer,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.defaultPaddingSc),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
            SizedBox(height: context.scaleHeight(12)),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: context.fontSize,
                height: 1.4,
              ),
            ),
            SizedBox(height: context.scaleHeight(16)),
            TextButton(
              onPressed: onRetry,
              child: Text(
                retryLabel,
                style: const TextStyle(
                  color: AppColors.primaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
