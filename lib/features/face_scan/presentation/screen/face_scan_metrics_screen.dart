import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mime_health/core/extensions/context_extensions.dart';
import 'package:mime_health/core/theme/app_colors.dart';
import 'package:mime_health/core/widgets/app_app_bar.dart';

import '../../../../core/localization/l10n_keys.dart';
import '../../../language/presentation/provider/language_provider.dart';
import '../../domain/entity/face_scan_entity.dart';
import '../util/scan_result_items.dart';
import '../widget/scan_result_grid.dart';

/// Full metrics view opened from Health Dashboard "Upgrade".
class FaceScanMetricsScreen extends ConsumerWidget {
  const FaceScanMetricsScreen({super.key, required this.vitals});

  final FaceScanVitalsResult vitals;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(languageControllerProvider);
    final metrics = metricItems(vitals.rawMetrics, l10n);
    final wellbeing = wellbeingItems(vitals.rawMetrics, l10n);
    final sectionTitleStyle = TextStyle(
      color: AppColors.primaryContainer,
      fontSize: context.titleFontSize,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.2,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppAppBar(title: l10n.t(L10nKeys.healthDashboardMetrics)),
      body: SafeArea(
        top: false,
        child: metrics.isEmpty && wellbeing.isEmpty
            ? Center(
                child: Text(
                  l10n.t(
                    L10nKeys.healthHubNoScan,
                    fallback: 'No metrics available.',
                  ),
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: context.fontSize,
                  ),
                ),
              )
            : ListView(
                padding: EdgeInsets.fromLTRB(
                  context.defaultPaddingSc,
                  context.scaleHeight(12),
                  context.defaultPaddingSc,
                  context.scaleHeight(24),
                ),
                children: [
                  if (metrics.isNotEmpty) ...[
                    Text(
                      l10n.t(L10nKeys.healthDashboardMetrics),
                      style: sectionTitleStyle,
                    ),
                    SizedBox(height: context.defaultPaddingSc),
                    ScanResultGrid(items: metrics),
                  ],
                  if (wellbeing.isNotEmpty) ...[
                    SizedBox(height: context.defaultPaddingSc),
                    Text(
                      l10n.t(
                        L10nKeys.healthDashboardWellbeing,
                        fallback: 'Wellbeing',
                      ),
                      style: sectionTitleStyle,
                    ),
                    SizedBox(height: context.defaultPaddingSc),
                    ScanResultGrid(items: wellbeing),
                  ],
                ],
              ),
      ),
    );
  }
}
