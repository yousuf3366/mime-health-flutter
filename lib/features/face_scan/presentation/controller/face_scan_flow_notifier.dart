import 'dart:async';
import 'dart:convert';

// Temporarily unused while the question-and-answer screen is commented out.
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Temporarily unused while the question-and-answer screen is commented out.
// import '../../../../core/config/app_config.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/services/snackbar_service.dart';
import '../../../profile/domain/entity/profile_entity.dart';
import '../../../profile/presentation/provider/profile_di.dart';
import '../../data/mapper/face_scan_mapper.dart';
import '../../data/model/mime_scan_models.dart';
// Temporarily unused while the question-and-answer screen is commented out.
// import '../../domain/catalog/mime_question_catalog.dart';
import '../../domain/entity/face_scan_entity.dart';
import '../provider/face_scan_di.dart';
import '../screen/face_scan_health_dashboard_screen.dart';
// Temporarily unused while the question-and-answer screen is commented out.
// import '../screen/face_scan_questionnaire_screen.dart';
import '../screen/face_scan_results_loading_screen.dart';
import '../state/face_scan_flow_state.dart';

/// Orchestrates the Face Scan flow using thin use cases + native plugin gateway.
class FaceScanFlowNotifier extends Notifier<FaceScanFlowState> {
  // Temporarily unused while the question-and-answer screen is commented out.
  // static const _timezone = 'Asia/Dhaka';

  /// Bumped by [reset] so in-flight [startScan] work stops updating state.
  var _session = 0;

  @override
  FaceScanFlowState build() => FaceScanFlowState.initial();

  /// Starts the live scan after the user has already consented on the pre-scan UI.
  ///
  /// Hits Mime `faceScanUrl` first — if no scan access is granted, returns
  /// [FaceScanStartResult.needsPlan] so the UI can prompt plan selection.
  ///
  /// Flow: Mime face-scan URL → native plugin → loading → store → dashboard.
  /// Questionnaire is temporarily skipped (code kept commented below).
  Future<FaceScanStartResult> startScan() async {
    if (state.isBusy) return FaceScanStartResult.aborted;

    final session = ++_session;
    bool isActive() => session == _session;

    final dialog = ref.read(dialogServiceProvider);
    final snackbar = ref.read(snackbarServiceProvider);

    late final ProfileEntity profile;
    try {
      final profiles = await ref.read(profilesProvider.future);
      if (!isActive()) return FaceScanStartResult.aborted;
      if (profiles.isEmpty) {
        const message = 'Create a health profile before starting a face scan.';
        state = state.copyWith(
          status: FaceScanFlowStatus.error,
          errorMessage: message,
        );
        snackbar.showError(message);
        return FaceScanStartResult.aborted;
      }
      profile = _primaryProfile(profiles);
    } catch (error) {
      if (!isActive()) return FaceScanStartResult.aborted;
      final message = error is AppException
          ? error.message
          : 'Unable to load profile for face scan.';
      state = state.copyWith(
        status: FaceScanFlowStatus.error,
        errorMessage: message,
      );
      snackbar.showError(message);
      return FaceScanStartResult.aborted;
    }

    state = state.copyWith(
      status: FaceScanFlowStatus.preparing,
      errorMessage: null,
      result: null,
    );
    dialog.showLoading(message: 'Preparing face scan…');

    try {
      // 1) Face scan plug-in URL from Mime — also acts as plan/access check.
      final urlResult = await ref
          .read(getFaceScanUrlUseCaseProvider)
          .call(profileId: profile.id);
      if (!isActive()) return FaceScanStartResult.aborted;
      final scanUrl = urlResult.dataOrNull;
      if (urlResult.isFailure ||
          scanUrl == null ||
          !scanUrl.hasScanAccess ||
          scanUrl.url.trim().isEmpty) {
        dialog.hideLoading();
        state = state.copyWith(
          status: FaceScanFlowStatus.idle,
          errorMessage: null,
        );
        return FaceScanStartResult.needsPlan;
      }
      final storeExternalUserId =
          int.tryParse(scanUrl.externalUserId ?? '') ?? profile.id;

      // 2) Native Face Scan WebView
      dialog.hideLoading();
      state = state.copyWith(status: FaceScanFlowStatus.scanning);

      late final String faceScanId;
      try {
        faceScanId = await ref
            .read(faceScanPluginGatewayProvider)
            .openScan(scanUrl.url);
      } on FaceScanCancelledException catch (error) {
        state = state.copyWith(
          status: FaceScanFlowStatus.cancelled,
          errorMessage: error.message,
        );
        return FaceScanStartResult.aborted;
      } on AppException catch (error) {
        _fail(error, snackbar);
        return FaceScanStartResult.aborted;
      } catch (error) {
        _fail(
          FaceScanFailedException(error.toString(), originalError: error),
          snackbar,
        );
        return FaceScanStartResult.aborted;
      }
      if (!isActive()) return FaceScanStartResult.aborted;

      // 3) Questionnaire is temporarily disabled. Keep this code so the
      // question-and-answer flow can be restored later.
      /*
      state = state.copyWith(status: FaceScanFlowStatus.questionnaire);
      final externalUserId = scanUrl.externalUserId?.trim().isNotEmpty == true
          ? scanUrl.externalUserId!
          : profile.id.toString();
      await _showAndSubmitQuestionnaire(
        externalUserId: externalUserId,
        sex: profile.sex.trim().isEmpty ? null : profile.sex,
      );
      if (!isActive()) return FaceScanStartResult.aborted;
      */

      // Show loading immediately after the face scan while Mime processes it.
      state = state.copyWith(status: FaceScanFlowStatus.processing);
      final navigator = rootNavigatorKey.currentState;
      if (navigator != null) {
        unawaited(navigator.push<void>(_resultsLoadingRoute()));
        await WidgetsBinding.instance.endOfFrame;
      }

      final storeResult = await ref
          .read(storeMimeFaceScanUseCaseProvider)
          .call(
            faceScanId: faceScanId,
            externalUserId: storeExternalUserId,
            profileId: scanUrl.profileId ?? profile.id,
            faceScanUrlId: scanUrl.faceScanUrlId,
          );
      if (!isActive()) {
        _dismissResultsLoadingScreen();
        return FaceScanStartResult.aborted;
      }
      final storeError = storeResult.errorOrNull;
      if (storeError != null) {
        _dismissResultsLoadingScreen();
        _fail(storeError, snackbar);
        return FaceScanStartResult.aborted;
      }

      // Live API vitals (switch dashboard to this when sample demo is off):
      final vitals = storeResult.dataOrNull!;
      //  final dashBoardVitals = _vitalsFromSampleScanJson();
      _dismissResultsLoadingScreen();

      state = state.copyWith(
        status: FaceScanFlowStatus.success,
        result: vitals,
        errorMessage: null,
      );
      await _showHealthDashboard(
        vitals: vitals,
        displayName: profile.displayName,
      );
      if (!isActive()) return FaceScanStartResult.aborted;
      return FaceScanStartResult.proceeded;
    } on AppException catch (error) {
      if (!isActive()) return FaceScanStartResult.aborted;
      _fail(error, snackbar);
      return FaceScanStartResult.aborted;
    } catch (error) {
      if (!isActive()) return FaceScanStartResult.aborted;
      _fail(
        FaceScanFailedException(error.toString(), originalError: error),
        snackbar,
      );
      return FaceScanStartResult.aborted;
    } finally {
      if (isActive()) {
        dialog.hideLoading();
        if (state.status == FaceScanFlowStatus.processing) {
          _dismissResultsLoadingScreen();
        }
      }
    }
  }

  Route<void> _resultsLoadingRoute() {
    return PageRouteBuilder<void>(
      opaque: true,
      barrierDismissible: false,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      pageBuilder: (context, animation, secondaryAnimation) =>
          const FaceScanResultsLoadingScreen(),
    );
  }

  void _dismissResultsLoadingScreen() {
    final navigator = rootNavigatorKey.currentState;
    if (navigator == null || !navigator.canPop()) return;
    navigator.pop();
  }

  Future<void> _showHealthDashboard({
    required FaceScanVitalsResult vitals,
    required String displayName,
  }) async {
    final navigator = rootNavigatorKey.currentState;
    if (navigator == null) return;

    await navigator.push<void>(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => FaceScanHealthDashboardScreen(
          vitals: vitals,
          displayName: displayName,
        ),
      ),
    );
  }

  // Temporarily unused while the question-and-answer screen is commented out.
  // Restore this method together with the questionnaire block in [startScan].
  /*
  Future<void> _showAndSubmitQuestionnaire({
    required String externalUserId,
    String? sex,
  }) async {
    final navigator = rootNavigatorKey.currentState;
    if (navigator == null) return;

    // Completer: finish uses pushReplacement → loading (not pop), so we
    // cannot rely on the route Future for answers.
    final answersCompleter = Completer<List<FaceScanQuestionAnswer>?>();

    unawaited(
      navigator
          .push<List<FaceScanQuestionAnswer>>(
            MaterialPageRoute<List<FaceScanQuestionAnswer>>(
              fullscreenDialog: true,
              builder: (_) => FaceScanQuestionnaireScreen(
                questions: MimeQuestionCatalog.postScanQuestions,
                completionRoute: _resultsLoadingRoute(),
                onCompleted: (answers) {
                  state = state.copyWith(status: FaceScanFlowStatus.processing);
                  if (!answersCompleter.isCompleted) {
                    answersCompleter.complete(answers);
                  }
                },
              ),
            ),
          )
          .then((popped) {
            // Cancel / system back still pops the questionnaire route.
            if (!answersCompleter.isCompleted) {
              answersCompleter.complete(popped);
            }
          }),
    );

    final result = await answersCompleter.future;
    if (result == null || result.isEmpty) return;

    try {
      // Ensure IntelliProve user exists, then submit answers.
      await ref
          .read(ensureIntelliProveUserUseCaseProvider)
          .call(
            externalUserId: externalUserId,
            language: AppConfig.intelliProveValidatedLanguage,
            sex: sex,
          );

      final userIdResult = await ref
          .read(getIntelliProveUserIdUseCaseProvider)
          .call(externalUserId);
      final userId = userIdResult.dataOrNull?.userId;
      if (userId != null && userId.isNotEmpty) {
        final many = await ref
            .read(saveFaceScanQuestionAnswersManyUseCaseProvider)
            .call(userId: externalUserId, answers: result, timezone: _timezone);
        if (many.isSuccess) return;
        if (kDebugMode) {
          debugPrint(
            '[FaceScan] questionnaire bulk submit failed: '
            '${many.errorOrNull?.message}',
          );
        }
      }

      final fallback = await ref
          .read(saveFaceScanQuestionAnswersUseCaseProvider)
          .call(
            externalUserId: externalUserId,
            answers: result,
            timezone: _timezone,
          );
      if (kDebugMode && !fallback.isSuccess) {
        debugPrint(
          '[FaceScan] questionnaire fallback failed: '
          '${fallback.errorOrNull?.message}',
        );
      }
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[FaceScan] questionnaire submit failed: $error');
      }
    }
  }
  */

  ProfileEntity _primaryProfile(List<ProfileEntity> profiles) {
    for (final profile in profiles) {
      if (profile.profileKind == AppConstants.profileKindSelf) {
        return profile;
      }
    }
    return profiles.first;
  }

  void _fail(AppException error, SnackbarService snackbar) {
    state = state.copyWith(
      status: FaceScanFlowStatus.error,
      errorMessage: error.message,
    );
    snackbar.showError(error.message);
  }

  void reset() {
    _session++;
    ref.read(dialogServiceProvider).hideLoading();
    state = FaceScanFlowState.initial();
  }
}

final faceScanFlowNotifierProvider =
    NotifierProvider<FaceScanFlowNotifier, FaceScanFlowState>(
      FaceScanFlowNotifier.new,
    );
