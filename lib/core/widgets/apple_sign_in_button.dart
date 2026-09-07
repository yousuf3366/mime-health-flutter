import 'package:flutter/material.dart';

/// Rectangular Apple sign-in icon button matching [GoogleSignInButton] sizing.
class AppleSignInButton extends StatelessWidget {
  const AppleSignInButton({
    super.key,
    required this.onPressed,
    this.enabled = true,
    this.width = 70,
    this.height = 42,
  });

  final VoidCallback? onPressed;
  final bool enabled;
  final double width;
  final double height;

  static const BorderRadius _radius = BorderRadius.all(Radius.circular(10));

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 1,
      borderRadius: _radius,
      child: InkWell(
        borderRadius: _radius,
        onTap: enabled ? onPressed : null,
        child: SizedBox(
          width: width,
          height: height,
          child: Center(
            child: Opacity(
              opacity: enabled ? 1 : 0.45,
              child: Icon(
                Icons.apple,
                size: height * 0.62,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
