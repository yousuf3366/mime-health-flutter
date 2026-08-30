import 'package:flutter/material.dart';

/// Global navigator key used by snackbars, dialogs, and GoRouter.
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// Global scaffold messenger for snackbars outside widget trees.
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

/// Centralized snackbar / toast API. Screens must not use ScaffoldMessenger.
class SnackbarService {
  void showSuccess(String message) => _show(
        message,
        backgroundColor: const Color(0xFF2E7D32),
        icon: Icons.check_circle_outline,
      );

  void showError(String message) => _show(
        message,
        backgroundColor: const Color(0xFFC62828),
        icon: Icons.error_outline,
      );

  void showWarning(String message) => _show(
        message,
        backgroundColor: const Color(0xFFEF6C00),
        icon: Icons.warning_amber_rounded,
      );

  void showInfo(String message) => _show(
        message,
        backgroundColor: const Color(0xFF1565C0),
        icon: Icons.info_outline,
      );

  void _show(
    String message, {
    required Color backgroundColor,
    required IconData icon,
  }) {
    final messenger = rootScaffoldMessengerKey.currentState;
    if (messenger == null) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
  }
}
