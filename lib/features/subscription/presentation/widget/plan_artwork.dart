import 'package:flutter/material.dart';
import 'package:mime_health/core/config/app_config.dart';
import 'package:mime_health/core/widgets/app_network_image.dart';

/// Plan image from `image_path` (absolute or API-relative), falling back to
/// the bundled default artwork.
class PlanArtwork extends StatelessWidget {
  const PlanArtwork({super.key, required this.imageUrl});

  static const _fallbackAsset = 'assets/images/health_plan_default.png';

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    Widget fallback() => Image.asset(
      _fallbackAsset,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
    );

    final url = imageUrl?.trim();
    if (url == null || url.isEmpty) return fallback();
    final uri = Uri.tryParse(url);
    final resolvedUrl = uri?.hasScheme == true
        ? url
        : '${AppConfig.baseUrl.replaceAll(RegExp(r'/+$'), '')}/'
              '${url.replaceFirst(RegExp(r'^/+'), '')}';

    return AppNetworkImage(
      resolvedUrl,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => fallback(),
      loadingBuilder: (context, child, progress) {
        return progress == null ? child : fallback();
      },
    );
  }
}
