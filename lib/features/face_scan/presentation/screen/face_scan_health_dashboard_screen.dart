import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mime_health/core/extensions/context_extensions.dart';
import 'package:mime_health/core/theme/app_colors.dart';
import 'package:mime_health/core/widgets/app_app_bar.dart';
import 'package:mime_health/core/widgets/app_button.dart';

import '../../../../core/localization/l10n_keys.dart';
import '../../../language/presentation/provider/language_provider.dart';
import '../../domain/entity/face_scan_entity.dart';

/// Health results dashboard (biomarkers from Mime store / latest-scan response).
class FaceScanHealthDashboardScreen extends ConsumerWidget {
  const FaceScanHealthDashboardScreen({
    super.key,
    required this.vitals,
    required this.displayName,
    this.showCloseAction = true,
  });

  final FaceScanVitalsResult vitals;
  final String displayName;

  /// When false (e.g. Health Hub tab), the AppBar close button is hidden.
  final bool showCloseAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(languageControllerProvider);
    final score = _overallScore(vitals);
    final scoreLabel = _scoreLabel(vitals);
    final spo2 = vitals.spo2 > 0 ? vitals.spo2 : 98.0;
    final quality = (vitals.qualityStatus?.trim().isNotEmpty ?? false)
        ? vitals.qualityStatus!.toUpperCase()
        : 'GOOD';

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
              SizedBox(height: context.scaleHeight(16)),
              _OverallScoreCard(
                score: score,
                label: scoreLabel,
                caption: l10n.t(L10nKeys.healthDashboardOverallScore),
              ),
              SizedBox(height: context.defaultPaddingSc),
              Text(
                l10n.t(L10nKeys.healthDashboardBiomarkers),
                style: TextStyle(
                  color: AppColors.primaryContainer,
                  fontSize: context.titleFontSize,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: context.defaultPaddingSc),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: context.scaleWidth(6),
                mainAxisSpacing: context.scaleHeight(6),
                childAspectRatio: 1.9,
                children: [
                  _BiomarkerCard(
                    iconAsset: 'assets/images/heart_rate_Icon.svg',
                    title: l10n.t(L10nKeys.healthDashboardHeartRate),
                    value: '${vitals.heartRate.toStringAsFixed(0)} BPM',
                  ),
                  _BiomarkerCard(
                    iconAsset: 'assets/images/blood_pressure_icon.svg',
                    title: l10n.t(L10nKeys.healthDashboardBloodPressure),
                    value:
                        '${vitals.bloodPressureSystolic.toStringAsFixed(0)}/'
                        '${vitals.bloodPressureDiastolic.toStringAsFixed(0)}',
                  ),
                  _BiomarkerCard(
                    iconAsset: 'assets/images/resporitory_icon.svg',
                    title: l10n.t(L10nKeys.healthDashboardRespRate),
                    value: '${vitals.respiratoryRate.toStringAsFixed(0)}/MIN',
                  ),
                  _BiomarkerCard(
                    iconAsset: 'assets/images/spo2_icon.svg',
                    title: l10n.t(L10nKeys.healthDashboardSpo2),
                    value: '${spo2.toStringAsFixed(0)}%',
                    badge: quality,
                  ),
                ],
              ),
              // if (vitals.heartRateVariability != null) ...[
              //   SizedBox(height: context.scaleHeight(8)),
              //   SizedBox(
              //     height: context.scaleHeight(72),
              //     child: _BiomarkerCard(
              //       icon: Icons.show_chart,
              //       title: l10n.t(L10nKeys.healthDashboardHrv),
              //       value:
              //           '${vitals.heartRateVariability!.toStringAsFixed(0)} ms',
              //     ),
              //   ),
              // ],
              SizedBox(height: context.defaultPaddingSc),
              Text(
                l10n.t(L10nKeys.healthDashboardMetrics),
                style: TextStyle(
                  color: AppColors.primaryContainer,
                  fontSize: context.titleFontSize,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: context.defaultPaddingSc),
              _MetricsUpgradeCard(
                title: l10n.t(L10nKeys.healthDashboardUpgradeTitle),
                body: l10n.t(L10nKeys.healthDashboardUpgradeBody),
                cta: l10n.t(L10nKeys.healthDashboardUpgradeCta),
                onUpgrade: () {
                  // Placeholder until paywall is wired.
                },
              ),
              SizedBox(height: context.scaleHeight(20)),
              AppButton(
                label: l10n.t(L10nKeys.healthDashboardConsult),
                onPressed: () {},
              ),
              SizedBox(height: context.scaleHeight(10)),
              AppButton(
                label: l10n.t(L10nKeys.healthDashboardLabTest),
                onPressed: () {},
              ),
              SizedBox(height: context.scaleHeight(10)),
              AppButton(
                label: l10n.t(L10nKeys.healthDashboardMedicine),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
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

class _BiomarkerCard extends StatelessWidget {
  const _BiomarkerCard({
    required this.iconAsset,
    required this.title,
    required this.value,
    this.badge,
  });

  final String iconAsset;
  final String title;
  final String value;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final iconSize = context.scaleWidth(20);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.scaleWidth(8),
        vertical: context.scaleHeight(8),
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundDeep,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.borderFocused.withAlpha(120),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                iconAsset,
                width: iconSize,
                height: iconSize,
                fit: BoxFit.contain,
              ),
              const Spacer(),
              if (badge != null)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.scaleWidth(4),
                    vertical: context.scaleHeight(1),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.greenLight.withAlpha(240),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    badge!,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: context.extraSmallFontSize,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.primaryContainer,
                    fontSize: context.scaleWidth(22),
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: context.extraSmallFontSize,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                    height: 1.0,
                  ),
                ),
              ),
              SizedBox(width: context.scaleWidth(4)),
              Image.asset(
                'assets/images/warning_Info_icon.png',
                width: context.scaleWidth(25),
                height: context.scaleWidth(25),
                fit: BoxFit.contain,
              ),
            ],
          ),
        ],
      ),
    );
  }
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
