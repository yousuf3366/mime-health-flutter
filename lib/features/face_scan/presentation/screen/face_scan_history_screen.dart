import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mime_health/core/error/exceptions.dart';
import 'package:mime_health/core/extensions/context_extensions.dart';
import 'package:mime_health/core/theme/app_colors.dart';
import 'package:mime_health/core/widgets/app_app_bar.dart';
import 'package:mime_health/core/widgets/app_button.dart';

import '../../../../core/localization/l10n_keys.dart';
import '../../../language/presentation/provider/language_provider.dart';
import '../../../scan_share/presentation/widget/scan_share_button.dart';
import '../../domain/entity/face_scan_entity.dart';
import '../provider/face_scan_di.dart';
import '../util/scan_result_items.dart';
import 'face_scan_health_dashboard_screen.dart';

/// Lists past Mime scans for a profile (`GET /api/v1/scans`).
class FaceScanHistoryScreen extends ConsumerWidget {
  const FaceScanHistoryScreen({
    super.key,
    required this.profileId,
    required this.displayName,
  });

  final int profileId;
  final String displayName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(languageControllerProvider);
    final asyncScans = ref.watch(mimeScanHistoryProvider(profileId));

    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      appBar: AppAppBar(
        title: l10n.t(L10nKeys.healthDashboardScanHistoryTitle),
        onBack: () => context.pop(),
      ),
      body: SafeArea(
        top: false,
        child: asyncScans.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primaryContainer),
          ),
          error: (error, _) => _HistoryMessageBody(
            icon: Icons.error_outline,
            message: error is AppException
                ? error.message
                : l10n.t(L10nKeys.genericError),
            actionLabel: l10n.t(L10nKeys.retry),
            onAction: () => ref.invalidate(mimeScanHistoryProvider(profileId)),
          ),
          data: (scans) {
            if (scans.isEmpty) {
              return _HistoryMessageBody(
                icon: Icons.monitor_heart_outlined,
                message: l10n.t(L10nKeys.healthHubNoScan),
                actionLabel: l10n.t(L10nKeys.retry),
                onAction: () =>
                    ref.invalidate(mimeScanHistoryProvider(profileId)),
              );
            }

            return ListView.separated(
              padding: EdgeInsets.fromLTRB(
                context.defaultPaddingSc,
                context.scaleHeight(12),
                context.defaultPaddingSc,
                context.scaleHeight(24),
              ),
              itemCount: scans.length,
              separatorBuilder: (_, _) =>
                  SizedBox(height: context.scaleHeight(10)),
              itemBuilder: (context, index) {
                final scan = scans[index];
                return _ScanHistoryCard(
                  scan: scan,
                  highlights: biomarkerItems(
                    scan.rawBiomarkers,
                    l10n,
                  ).take(3).toList(growable: false),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => FaceScanHealthDashboardScreen(
                          vitals: scan,
                          displayName: displayName,
                          showCloseAction: true,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ScanHistoryCard extends StatelessWidget {
  const _ScanHistoryCard({
    required this.scan,
    required this.highlights,
    required this.onTap,
  });

  final FaceScanVitalsResult scan;
  final List<ScanResultItem> highlights;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final quality = (scan.qualityStatus?.trim().isNotEmpty ?? false)
        ? scan.qualityStatus!.toUpperCase()
        : '—';
    final dateText = DateFormat(
      'MMM d, yyyy · HH:mm',
    ).format(scan.timestamp.toLocal());

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.scaleWidth(14)),
        child: Ink(
          padding: EdgeInsets.all(context.scaleWidth(14)),
          decoration: BoxDecoration(
            color: AppColors.glass,
            borderRadius: BorderRadius.circular(context.scaleWidth(14)),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      dateText,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: context.fontSize,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.scaleWidth(8),
                      vertical: context.scaleHeight(2),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.greenLight.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      quality,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: context.extraSmallFontSize,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  ScanShareButton(
                    profileId: scan.profileId,
                    scanId: scan.mimeScanId,
                  ),
                ],
              ),
              if (highlights.isNotEmpty) ...[
                SizedBox(height: context.scaleHeight(12)),
                Row(
                  children: [
                    for (var i = 0; i < highlights.length; i++) ...[
                      if (i > 0) SizedBox(width: context.scaleWidth(8)),
                      Expanded(
                        child: _MetricChip(
                          label: highlights[i].title,
                          value: highlights[i].value,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppColors.textHint,
            fontSize: context.extraSmallFontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: context.scaleHeight(2)),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppColors.primaryContainer,
            fontSize: context.smallFontSize,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _HistoryMessageBody extends StatelessWidget {
  const _HistoryMessageBody({
    required this.icon,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: context.scaleWidth(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.primaryContainer),
            SizedBox(height: context.scaleHeight(12)),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: context.fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: context.scaleHeight(16)),
            AppButton(expand: false, label: actionLabel, onPressed: onAction),
          ],
        ),
      ),
    );
  }
}
