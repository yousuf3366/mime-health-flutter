import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mime_health/core/extensions/context_extensions.dart';
import 'package:mime_health/core/providers/core_providers.dart';
import 'package:mime_health/core/router/route_names.dart';
import 'package:mime_health/core/theme/app_colors.dart';
import 'package:mime_health/core/widgets/app_app_bar.dart';
import 'package:mime_health/core/widgets/app_button.dart';
import 'package:mime_health/core/widgets/app_warning_card.dart';

import '../../../../core/localization/l10n_keys.dart';
import '../../../language/presentation/provider/language_provider.dart';
import '../../../subscription/presentation/provider/subscription_provider.dart';
import '../../domain/entity/face_scan_entity.dart';
import '../provider/face_scan_di.dart';
import '../util/scan_result_items.dart';
import '../widget/scan_result_grid.dart';

/// Health results dashboard (biomarkers from Mime store / latest-scan response).
class FaceScanHealthDashboardScreen extends HookConsumerWidget {
  const FaceScanHealthDashboardScreen({
    super.key,
    required this.vitals,
    required this.displayName,
    this.showCloseAction = true,
    this.profileId,
  });

  final FaceScanVitalsResult vitals;
  final String displayName;

  /// When false (e.g. Health Hub tab), the AppBar close button is hidden.
  final bool showCloseAction;

  /// Used by Health Hub "All scans" to open scan history.
  final int? profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(languageControllerProvider);
    // Local copy so the scan can be re-fetched after the user upgrades.
    final scanState = useState(this.vitals);
    useEffect(() {
      scanState.value = this.vitals;
      return null;
    }, [this.vitals]);
    final vitals = scanState.value;
    final isRefreshingPlan = useState(false);

    Future<void> openPlansAndRefresh() async {
      final paid = await context.push<bool>(RouteNames.subscriptionPlans);
      if (!context.mounted) return;
      isRefreshingPlan.value = true;
      try {
        final active = await _refreshActivePlan(
          context,
          ref,
          retry: paid == true,
        );
        if (!active || !context.mounted) return;
        final refreshed = await _reloadScan(ref, scanState.value);
        if (refreshed != null && context.mounted) {
          scanState.value = refreshed;
        }
      } finally {
        if (context.mounted) isRefreshingPlan.value = false;
      }
    }

    final hasOverallScore = _wellbeingMental(vitals)?['score'] != null;
    final score = _overallScore(vitals);
    final scoreLabel = _scoreLabel(vitals);
    final biomarkers = biomarkerItems(vitals.rawBiomarkers, l10n);
    final metrics = metricItems(vitals.rawMetrics, l10n);
    final wellbeing = wellbeingItems(vitals.rawMetrics, l10n);
    final mySubscription = ref.watch(mySubscriptionProvider);
    final isCheckingPlan =
        isRefreshingPlan.value ||
        (mySubscription.isLoading && !mySubscription.hasValue);
    final hasActivePlan = mySubscription.asData?.value?.hasActivePlan ?? false;
    final sectionTitleStyle = TextStyle(
      color: AppColors.primaryContainer,
      fontSize: context.titleFontSize,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.2,
    );
    // final quality = (vitals.qualityStatus?.trim().isNotEmpty ?? false)
    //     ? vitals.qualityStatus!.toUpperCase()
    //     : 'GOOD';
    final historyProfileId = profileId ?? vitals.profileId;

    return Scaffold(
      // backgroundColor: AppColors.background,
      backgroundColor: Colors.transparent,
      appBar: AppAppBar(
        title: l10n.t(L10nKeys.healthDashboardTitle),
        automaticallyImplyLeading: false,
        actions: [
          if (showCloseAction)
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
              tooltip: l10n.t(L10nKeys.mediaCancel),
            ),
          if (!showCloseAction && historyProfileId != null)
            TextButton(
              onPressed: () {
                context.push(
                  RouteNames.scanHistory,
                  extra: {
                    'profileId': historyProfileId,
                    'displayName': displayName,
                  },
                );
              },
              child: Text(
                l10n.t(L10nKeys.healthDashboardViewAllScans),
                style: TextStyle(
                  color: AppColors.primaryContainer,
                  fontSize: context.smallFontSize,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            context.defaultPaddingSc,
            context.scaleHeight(12),
            context.defaultPaddingSc,
            context.scaleHeight(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${_greeting()}, ${_firstName(displayName)}.',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: context.titleFontSize,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (hasOverallScore) ...[
                SizedBox(height: context.scaleHeight(16)),
                _OverallScoreCard(
                  score: score,
                  label: scoreLabel,
                  caption: l10n.t(L10nKeys.healthDashboardOverallScore),
                ),
              ],
              if (biomarkers.isNotEmpty) ...[
                SizedBox(height: context.defaultPaddingSc),
                Text(
                  l10n.t(L10nKeys.healthDashboardBiomarkers),
                  style: sectionTitleStyle,
                ),
                SizedBox(height: context.defaultPaddingSc),
                ScanResultGrid(items: biomarkers),
                SizedBox(height: context.scaleHeight(10)),
                AppWarningCard(
                  message: l10n.t(L10nKeys.healthDashboardMedicalDisclaimer),
                ),
              ],
              SizedBox(height: context.defaultPaddingSc),
              Text(
                l10n.t(L10nKeys.healthDashboardMetrics),
                style: sectionTitleStyle,
              ),
              SizedBox(height: context.defaultPaddingSc),
              if (isCheckingPlan)
                const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryContainer,
                  ),
                )
              else if (!hasActivePlan)
                _MetricsUpgradeCard(
                  title: l10n.t(L10nKeys.healthDashboardUpgradeTitle),
                  body: l10n.t(L10nKeys.healthDashboardUpgradeBody),
                  cta: l10n.t(L10nKeys.healthDashboardUpgradeCta),
                  onUpgrade: openPlansAndRefresh,
                ),
              if (hasActivePlan && metrics.isNotEmpty)
                ScanResultGrid(items: metrics),
              if (hasActivePlan && wellbeing.isNotEmpty) ...[
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
              SizedBox(height: context.scaleHeight(20)),
              AppButton(
                label: l10n.t(L10nKeys.healthDashboardConsult),
                onPressed: () => _showComingSoon(ref),
              ),
              SizedBox(height: context.scaleHeight(10)),
              AppButton(
                label: l10n.t(L10nKeys.healthDashboardLabTest),
                onPressed: () => _showComingSoon(ref),
              ),
              SizedBox(height: context.scaleHeight(10)),
              AppButton(
                label: l10n.t(L10nKeys.healthDashboardMedicine),
                onPressed: () => _showComingSoon(ref),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Re-fetches `/subscription/me`. After a successful payment the gateway
  /// callback may activate the plan a moment later, so [retry] polls briefly.
  static Future<bool> _refreshActivePlan(
    BuildContext context,
    WidgetRef ref, {
    required bool retry,
  }) async {
    final attempts = retry ? 4 : 1;
    for (var attempt = 0; attempt < attempts; attempt++) {
      if (attempt > 0) await Future<void>.delayed(const Duration(seconds: 2));
      if (!context.mounted) return false;
      try {
        final sub = await ref.refresh(mySubscriptionProvider.future);
        if (sub?.hasActivePlan == true) return true;
      } catch (_) {
        // Keep polling; the provider exposes the error state to the UI.
      }
    }
    return false;
  }

  /// Reloads [scan] so metrics hidden by the old plan are returned.
  static Future<FaceScanVitalsResult?> _reloadScan(
    WidgetRef ref,
    FaceScanVitalsResult scan,
  ) async {
    final scanId = scan.mimeScanId;
    final profileId = scan.profileId;
    if (profileId == null) return null;

    final latest = await ref
        .read(getLatestMimeScanUseCaseProvider)
        .call(profileId: profileId);
    final latestScan = latest.when(success: (v) => v, failure: (_) => null);
    ref.invalidate(latestMimeScanProvider(profileId));
    if (latestScan != null &&
        (scanId == null || latestScan.mimeScanId == scanId)) {
      return latestScan;
    }

    if (scanId == null) return null;
    ref.invalidate(mimeScanHistoryProvider(profileId));
    final history = await ref
        .read(getMimeScansUseCaseProvider)
        .call(profileId: profileId);
    return history.when(
      success: (items) {
        for (final item in items) {
          if (item.mimeScanId == scanId) return item;
        }
        return null;
      },
      failure: (_) => null,
    );
  }

  void _showComingSoon(WidgetRef ref) {
    final l10n = ref.read(languageControllerProvider);
    ref
        .read(dialogServiceProvider)
        .showComingSoon(
          title: l10n.t(L10nKeys.comingSoonTitle),
          message: l10n.t(L10nKeys.comingSoonMessage),
          okLabel: l10n.t(L10nKeys.comingSoonOk),
        );
  }

  static String _firstName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'there';
    return trimmed.split(RegExp(r'\s+')).first;
  }

  static String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  static Map<dynamic, dynamic>? _wellbeingMental(FaceScanVitalsResult vitals) {
    final wellbeing = vitals.rawMetrics?['wellbeing'];
    if (wellbeing is! Map) return null;
    final mental = wellbeing['mental'];
    return mental is Map ? mental : null;
  }

  /// From Mime `metrics.wellbeing.mental.score`.
  static int _overallScore(FaceScanVitalsResult vitals) {
    final mental = _wellbeingMental(vitals);
    if (mental == null) return 0;
    final score = mental['score'];
    if (score is num) return score.round().clamp(0, 100);
    if (score is String) {
      final parsed = double.tryParse(score);
      if (parsed != null) return parsed.round().clamp(0, 100);
    }
    return 0;
  }

  /// From Mime `metrics.wellbeing.mental.assessment`.
  static String _scoreLabel(FaceScanVitalsResult vitals) {
    final assessment = _wellbeingMental(
      vitals,
    )?['assessment']?.toString().trim();
    if (assessment == null || assessment.isEmpty) return '';
    if (assessment.length == 1) return assessment.toUpperCase();
    return assessment[0].toUpperCase() + assessment.substring(1).toLowerCase();
  }
}

class _OverallScoreCard extends StatelessWidget {
  const _OverallScoreCard({
    required this.score,
    required this.label,
    required this.caption,
  });

  final int score;
  final String label;
  final String caption;

  static const _blackCyan = Color(0xFF0A2A30);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.scaleWidth(16),
        vertical: context.scaleWidth(4),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder, width: 0.5),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            AppColors.blackExtraLight,
            AppColors.blackExtraLight,
            AppColors.onPrimaryContainer,
          ],
          stops: [0.0, 0.70, 1.0],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  caption.toUpperCase(),
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: context.extraSmallFontSize,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                // SizedBox(height: context.scaleHeight(6)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$score',
                      style: TextStyle(
                        color: AppColors.primaryContainer,
                        fontSize: context.scaleWidth(36),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: context.scaleWidth(8)),
                    Text(
                      label,
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: context.smallFontSize,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            width: context.scaleWidth(46),
            height: context.scaleWidth(46),
            child: CustomPaint(
              painter: _ScoreRingPainter(progress: score / 100),
              child: Center(
                child: Icon(
                  Icons.shield_outlined,
                  color: AppColors.primaryContainer,
                  size: context.scaleWidth(22),
                ),
              ),
            ),
          ),
          SizedBox(width: context.scaleWidth(50)),
        ],
      ),
    );
  }
}

class _ScoreRingPainter extends CustomPainter {
  _ScoreRingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;
    final bg = Paint()
      ..color = AppColors.surfaceElevated
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final fg = Paint()
      ..color = AppColors.primaryContainer
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3;

    canvas.drawCircle(center, radius, bg);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress.clamp(0, 1),
      false,
      fg,
    );
  }

  @override
  bool shouldRepaint(covariant _ScoreRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _MetricsUpgradeCard extends StatelessWidget {
  const _MetricsUpgradeCard({
    required this.title,
    required this.body,
    required this.cta,
    required this.onUpgrade,
  });

  final String title;
  final String body;
  final String cta;
  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.blackLight,
        borderRadius: radius,
        border: Border.all(
          color: AppColors.borderFocused.withAlpha(120),
          width: 0.5,
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(context.scaleWidth(8)),
        decoration: BoxDecoration(
          color: Colors.transparent,
          // borderRadius: radius,
          // border: Border.all(color: AppColors.glassBorder, width: 0.5),
          image: const DecorationImage(
            image: AssetImage('assets/images/blurred_mock_content.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.lock_outline,
              color: AppColors.primaryContainer,
              size: context.scaleWidth(32),
            ),
            // SizedBox(height: context.scaleHeight(10)),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: context.titleFontSize,
                fontWeight: FontWeight.w700,
              ),
            ),
            // SizedBox(height: context.scaleHeight(6)),
            Text(
              body,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: context.smallFontSize,
                height: 1.35,
              ),
            ),
            SizedBox(height: context.scaleHeight(10)),
            Align(
              alignment: Alignment.center,
              child: _BlueGradientButton(label: cta, onPressed: onUpgrade),
            ),
            // AppButton(
            //   expand: false,
            //   label: cta,
            //   onPressed: onUpgrade,
            // ),
          ],
        ),
      ),
    );
  }
}

/// Compact blue-gradient CTA (not [AppButton]).
class _BlueGradientButton extends StatelessWidget {
  const _BlueGradientButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  static const _top = Color(0xFF357E7A);
  static const _bottom = Color(0xFF1775E1);

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(context.scaleWidth(50));
    final enabled = onPressed != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: radius,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: enabled
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [_top, _bottom, _bottom, _bottom],
                  )
                : null,
            color: enabled ? null : AppColors.surfaceElevated,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.scaleWidth(20),
              vertical: context.scaleHeight(5),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: context.bodyFontSize,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
