import 'package:flutter/material.dart';

/// Rectangular Google sign-in icon button with 15px corner radius.
class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
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
              child: CustomPaint(
                size: Size(width * 0.42, height * 0.42),
                painter: const _GoogleLogoPainter(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  const _GoogleLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.shortestSide / 2;

    // Simplified 4-color Google "G" mark.
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -0.55,
      1.8,
      true,
      paint,
    );

    paint.color = const Color(0xFF34A853);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      1.25,
      1.2,
      true,
      paint,
    );

    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      2.45,
      0.9,
      true,
      paint,
    );

    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -2.4,
      1.0,
      true,
      paint,
    );

    paint.color = Colors.white;
    canvas.drawCircle(Offset(cx, cy), r * 0.55, paint);

    paint.color = const Color(0xFF4285F4);
    canvas.drawRect(
      Rect.fromLTWH(cx - r * 0.05, cy - r * 0.18, r * 0.95, r * 0.36),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
