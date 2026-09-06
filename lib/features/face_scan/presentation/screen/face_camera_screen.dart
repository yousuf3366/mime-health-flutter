import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mime_health/core/extensions/context_extensions.dart';
import 'package:mime_health/core/localization/l10n_keys.dart';
import 'package:mime_health/core/services/face_recognition_service.dart';
import 'package:mime_health/core/theme/app_colors.dart';
import 'package:mime_health/core/utils/face_embedding_utils.dart';
import 'package:mime_health/core/widgets/app_button.dart';
import 'package:mime_health/features/language/presentation/provider/language_provider.dart';

enum FaceCameraMode { capture, verify }

/// Camera screen for registering or verifying a face embedding.
class FaceCameraScreen extends ConsumerStatefulWidget {
  const FaceCameraScreen({
    super.key,
    required this.mode,
    this.storedEmbedding,
  });

  final FaceCameraMode mode;
  final String? storedEmbedding;

  @override
  ConsumerState<FaceCameraScreen> createState() => _FaceCameraScreenState();
}

class _FaceCameraScreenState extends ConsumerState<FaceCameraScreen> {
  CameraController? _controller;
  int _cameraIndex = 0;
  bool _initializing = true;
  bool _processing = false;
  String? _statusKey;
  bool? _verifyFailed;

  bool get _isCapture => widget.mode == FaceCameraMode.capture;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final service = ref.read(faceRecognitionServiceProvider);
    await service.ensureInitialized();
    final cameras = service.cameras;
    if (cameras.isEmpty) {
      if (mounted) {
        setState(() {
          _initializing = false;
          _statusKey = L10nKeys.faceRecognitionCameraUnavailable;
        });
      }
      return;
    }

    _cameraIndex = cameras.indexWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
    );
    if (_cameraIndex < 0) _cameraIndex = 0;

    await _openCamera(cameras[_cameraIndex]);
  }

  Future<void> _openCamera(CameraDescription camera) async {
    await _controller?.dispose();
    final controller = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    _controller = controller;
    try {
      await controller.initialize();
    } catch (_) {
      if (mounted) {
        setState(() {
          _initializing = false;
          _statusKey = L10nKeys.faceRecognitionCameraUnavailable;
        });
      }
      return;
    }
    if (mounted) {
      setState(() {
        _initializing = false;
        _statusKey = null;
        _verifyFailed = null;
      });
    }
  }

  Future<void> _switchCamera() async {
    final service = ref.read(faceRecognitionServiceProvider);
    final cameras = service.cameras;
    if (cameras.length < 2) return;

    setState(() {
      _initializing = true;
      _statusKey = null;
      _verifyFailed = null;
    });

    _cameraIndex = (_cameraIndex + 1) % cameras.length;
    await _openCamera(cameras[_cameraIndex]);
  }

  Future<void> _capture() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _processing) {
      return;
    }

    setState(() {
      _processing = true;
      _statusKey = L10nKeys.faceRecognitionProcessing;
      _verifyFailed = null;
    });

    try {
      final photo = await controller.takePicture();
      final service = ref.read(faceRecognitionServiceProvider);
      final embedding = await service.captureEmbeddingFromPhoto(photo);

      if (!mounted) return;

      if (embedding == null) {
        setState(() {
          _processing = false;
          _statusKey = L10nKeys.faceRecognitionNoFace;
        });
        return;
      }

      if (_isCapture) {
        Navigator.of(context).pop(encodeEmbedding(embedding));
        return;
      }

      final stored = decodeEmbedding(widget.storedEmbedding);
      if (stored == null) {
        setState(() {
          _processing = false;
          _statusKey = L10nKeys.faceRecognitionNoStoredFace;
        });
        return;
      }

      if (facesMatch(stored, embedding)) {
        Navigator.of(context).pop(true);
        return;
      }

      setState(() {
        _processing = false;
        _verifyFailed = true;
        _statusKey = L10nKeys.faceRecognitionVerifyFailed;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _processing = false;
        _statusKey = L10nKeys.faceRecognitionCaptureFailed;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(languageControllerProvider);
    final title = l10n.t(
      _isCapture
          ? L10nKeys.faceRecognitionCaptureTitle
          : L10nKeys.faceRecognitionVerifyTitle,
    );
    final subtitle = l10n.t(
      _isCapture
          ? L10nKeys.faceRecognitionCaptureHint
          : L10nKeys.faceRecognitionVerifyHint,
    );
    final actionLabel = l10n.t(
      _isCapture
          ? L10nKeys.faceRecognitionCaptureButton
          : L10nKeys.faceRecognitionVerifyButton,
    );
    final statusText = _statusKey == null ? null : l10n.t(_statusKey!);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                context.scaleWidth(8),
                context.scaleHeight(8),
                context.scaleWidth(8),
                context.defaultPaddingSc,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _processing ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    color: AppColors.primaryContainer,
                  ),
                  Expanded(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: context.bodyFontSize,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _processing || _initializing ? null : _switchCamera,
                    icon: const Icon(Icons.cameraswitch_outlined),
                    color: AppColors.primaryContainer,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.defaultPaddingSc,
                ),
                child: Column(
                  children: [
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: context.fontSize,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: context.scaleHeight(16)),
                    Expanded(
                      child: _CameraPreviewCard(
                        controller: _controller,
                        initializing: _initializing,
                      ),
                    ),
                    if (statusText != null) ...[
                      SizedBox(height: context.scaleHeight(12)),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(context.scaleWidth(12)),
                        decoration: BoxDecoration(
                          color: (_verifyFailed == true
                                  ? AppColors.error
                                  : AppColors.glass)
                              .withValues(
                            alpha: _verifyFailed == true ? 0.15 : 1,
                          ),
                          borderRadius:
                              BorderRadius.circular(context.scaleWidth(12)),
                          border: Border.all(
                            color: _verifyFailed == true
                                ? AppColors.error.withValues(alpha: 0.5)
                                : AppColors.glassBorder,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _verifyFailed == true
                                  ? Icons.warning_amber_rounded
                                  : Icons.info_outline,
                              color: _verifyFailed == true
                                  ? AppColors.error
                                  : AppColors.primaryContainer,
                              size: context.scaleWidth(20),
                            ),
                            SizedBox(width: context.scaleWidth(8)),
                            Expanded(
                              child: Text(
                                statusText,
                                style: TextStyle(
                                  color: _verifyFailed == true
                                      ? AppColors.error
                                      : AppColors.textSecondary,
                                  fontSize: context.smallFontSize,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    SizedBox(height: context.scaleHeight(16)),
                    AppButton(
                      label: actionLabel,
                      icon: Icons.face_retouching_natural,
                      isLoading: _processing,
                      isEnabled: !_initializing &&
                          _controller?.value.isInitialized == true,
                      onPressed: _capture,
                    ),
                    SizedBox(height: context.scaleHeight(8)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CameraPreviewCard extends StatelessWidget {
  const _CameraPreviewCard({
    required this.controller,
    required this.initializing,
  });

  final CameraController? controller;
  final bool initializing;

  @override
  Widget build(BuildContext context) {
    final radius = context.scaleWidth(20);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.glass,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.glassBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: initializing || controller == null || !controller!.value.isInitialized
          ? Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryContainer,
              ),
            )
          : Stack(
              fit: StackFit.expand,
              children: [
                CameraPreview(controller!),
                Center(
                  child: Container(
                    width: context.scaleWidth(220),
                    height: context.scaleWidth(280),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.primaryContainer.withValues(alpha: 0.8),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(radius),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
