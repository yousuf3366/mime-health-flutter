import 'package:flutter/material.dart';

import '../widgets/app_button.dart';
import 'snackbar_service.dart';

/// Centralized loading overlay and confirmation dialogs.
class DialogService {
  OverlayEntry? _loadingEntry;

  BuildContext? get _context => rootNavigatorKey.currentContext;

  OverlayState? get _overlay => rootNavigatorKey.currentState?.overlay;

  void showLoading({String? message}) {
    hideLoading();

    final overlay = _overlay;
    final context = _context;
    if (overlay == null || context == null) return;

    final surfaceColor = Theme.of(context).colorScheme.surface;

    _loadingEntry = OverlayEntry(
      builder: (_) => Material(
        color: Colors.black54,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(message),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    // Use NavigatorState.overlay — Overlay is a *child* of Navigator,
    // so Overlay.of(navigatorContext) cannot find it by walking ancestors.
    overlay.insert(_loadingEntry!);
  }

  void hideLoading() {
    _loadingEntry?.remove();
    _loadingEntry = null;
  }

  Future<bool> confirmationDialog({
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
  }) async {
    final context = _context;
    if (context == null) return false;

    final result = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(cancelLabel),
            ),
            AppButton(
              label: confirmLabel,
              expand: false,
              isDestructive: isDestructive,
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }
}
