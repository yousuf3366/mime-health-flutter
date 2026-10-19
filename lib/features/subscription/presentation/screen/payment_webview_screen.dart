import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mime_health/core/config/app_config.dart';
import 'package:mime_health/core/extensions/context_extensions.dart';
import 'package:mime_health/core/theme/app_colors.dart';
import 'package:mime_health/core/widgets/app_app_bar.dart';
import 'package:mime_health/core/widgets/app_button.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import '../../../../core/localization/l10n_keys.dart';
import '../../../language/presentation/provider/language_provider.dart';
import '../../domain/entity/subscription_entity.dart';

enum PaymentOutcome { success, failed, cancelled, unknown }

/// Hosts the gateway checkout page from [CheckoutEntity.redirectUrl]. When the
/// gateway redirects back to the Mime backend the result page stays visible;
/// the detected [PaymentOutcome] is popped when the user leaves the screen.
class PaymentWebViewScreen extends HookConsumerWidget {
  const PaymentWebViewScreen({super.key, required this.checkout});

  final CheckoutEntity checkout;

  /// Gateway callbacks (success/fail/cancel) land on the API host.
  static PaymentOutcome? outcomeFor(String url) {
    final uri = Uri.tryParse(url);
    final apiHost = Uri.tryParse(AppConfig.baseUrl)?.host;
    if (uri == null || apiHost == null || uri.host != apiHost) return null;
    final path = uri.path.toLowerCase();
    if (path.contains('success')) return PaymentOutcome.success;
    if (path.contains('fail')) return PaymentOutcome.failed;
    if (path.contains('cancel')) return PaymentOutcome.cancelled;
    return null;
  }

  /// Pages without their own background (e.g. "please wait" / result pages)
  /// render on the dark webview background, so give their text the app's
  /// light text color. Pages that paint a background are left untouched.
  static final String _readableTextScript =
      '''
(function () {
  if (!document.body || document.getElementById('mime-readable-text')) return;
  var clear = function (c) {
    return !c || c === 'transparent' || c === 'rgba(0, 0, 0, 0)';
  };
  if (!clear(getComputedStyle(document.documentElement).backgroundColor) ||
      !clear(getComputedStyle(document.body).backgroundColor)) return;
  var style = document.createElement('style');
  style.id = 'mime-readable-text';
  style.textContent = 'html, body { color: $_textColorCss !important; }';
  (document.head || document.body).appendChild(style);
})();
''';

  static final String _textColorCss =
      '#${(AppColors.textPrimary.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(languageControllerProvider);
    final progress = useState(0);
    final isLoading = useState(true);
    final loadError = useState<String?>(null);
    final finished = useRef(false);
    // Set when the gateway lands on a success/fail/cancel page. The user stays
    // on that page; the outcome is returned once they leave the screen.
    final detectedOutcome = useRef<PaymentOutcome?>(null);

    void finish([PaymentOutcome? outcome]) {
      if (finished.value || !context.mounted) return;
      finished.value = true;
      context.pop(outcome ?? detectedOutcome.value ?? PaymentOutcome.unknown);
    }

    final controller = useMemoized(() {
      final controller = WebViewController();
      void applyReadableText() {
        controller.runJavaScript(_readableTextScript).catchError((Object _) {});
      }

      controller
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(AppColors.backgroundDeep)
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (value) {
              // "Please wait" pages may never finish loading, so style them
              // while they stream in too.
              applyReadableText();
              if (context.mounted) progress.value = value;
            },
            onPageStarted: (url) {
              debugPrint('[PaymentWebView] start $url');
              if (!context.mounted) return;
              isLoading.value = true;
              loadError.value = null;
            },
            onPageFinished: (url) {
              debugPrint('[PaymentWebView] finish $url');
              applyReadableText();
              final outcome = outcomeFor(url);
              if (outcome != null) detectedOutcome.value = outcome;
              if (context.mounted) isLoading.value = false;
            },
            onWebResourceError: (error) {
              debugPrint(
                '[PaymentWebView] error ${error.errorCode} '
                '${error.description} main=${error.isForMainFrame}',
              );
              if (error.isForMainFrame != false && context.mounted) {
                isLoading.value = false;
                loadError.value = error.description;
              }
            },
          ),
        );
      final platform = controller.platform;
      if (platform is AndroidWebViewController) {
        platform.setMediaPlaybackRequiresUserGesture(false);
      }
      controller.loadRequest(Uri.parse(checkout.redirectUrl));
      return controller;
    }, [checkout.redirectUrl]);

    Future<void> onBack() async {
      // Once the gateway has reported a result, back leaves the screen rather
      // than stepping into the already-submitted gateway pages.
      if (detectedOutcome.value == null && await controller.canGoBack()) {
        await controller.goBack();
      } else {
        finish();
      }
    }

    final webView = defaultTargetPlatform == TargetPlatform.android
        ? WebViewWidget.fromPlatformCreationParams(
            params:
                AndroidWebViewWidgetCreationParams.fromPlatformWebViewWidgetCreationParams(
                  PlatformWebViewWidgetCreationParams(
                    controller: controller.platform,
                  ),
                  displayWithHybridComposition: true,
                ),
          )
        : WebViewWidget(controller: controller);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) onBack();
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundDeep,
        appBar: AppAppBar(
          title: l10n.t(L10nKeys.paymentGatewayTitle),
          onBack: onBack,
          actions: [
            IconButton(
              onPressed: finish,
              icon: const Icon(Icons.close),
              color: AppColors.textPrimary,
              tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            ),
          ],
        ),
        body: Stack(
          children: [
            Positioned.fill(child: webView),
            if (progress.value < 100)
              LinearProgressIndicator(
                value: progress.value / 100,
                minHeight: 2,
                color: AppColors.primaryContainer,
                backgroundColor: Colors.transparent,
              ),
            if (isLoading.value && loadError.value == null)
              const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryContainer,
                ),
              ),
            if (loadError.value != null)
              Positioned.fill(
                child: ColoredBox(
                  color: AppColors.backgroundDeep,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(context.defaultPaddingSc),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            loadError.value!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: context.fontSize,
                            ),
                          ),
                          SizedBox(height: context.scaleHeight(16)),
                          AppButton(
                            label: l10n.t(L10nKeys.retry),
                            expand: false,
                            onPressed: controller.reload,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
