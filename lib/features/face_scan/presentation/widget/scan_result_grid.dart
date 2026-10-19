import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mime_health/core/extensions/context_extensions.dart';
import 'package:mime_health/core/theme/app_colors.dart';

import '../util/scan_result_items.dart';

/// Two-column grid of [ScanResultCard]s.
class ScanResultGrid extends StatelessWidget {
  const ScanResultGrid({super.key, required this.items});

  final List<ScanResultItem> items;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      crossAxisSpacing: context.scaleWidth(6),
      mainAxisSpacing: context.scaleHeight(6),
      childAspectRatio: 1.9,
      children: [for (final item in items) ScanResultCard(item: item)],
    );
  }
}

class ScanResultCard extends StatelessWidget {
  const ScanResultCard({super.key, required this.item});

  final ScanResultItem item;

  @override
  Widget build(BuildContext context) {
    final iconSize = context.scaleWidth(20);
    final svgAsset = item.svgAsset;
    final badge = item.badge;

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
              if (svgAsset != null)
                SvgPicture.asset(
                  svgAsset,
                  width: iconSize,
                  height: iconSize,
                  fit: BoxFit.contain,
                )
              else
                Icon(
                  item.icon,
                  size: iconSize,
                  color: AppColors.primaryContainer,
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
                    badge,
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
                  item.value,
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
                  item.title,
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
