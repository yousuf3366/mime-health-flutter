import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';
import '../theme/app_colors.dart';

class AppDropdownField<T> extends StatelessWidget {
  const AppDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabelBuilder,
    required this.onChanged,
    this.mandatory = false,
    this.errorText,
    this.enabled = true,
  });

  final String label;
  final T? value;
  final List<T> items;
  final String Function(T item) itemLabelBuilder;
  final ValueChanged<T?> onChanged;
  final bool mandatory;
  final String? errorText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final radius = context.scaleWidth(10);
    final fillColor = enabled ? AppColors.surfaceLow : AppColors.surfaceSolid;
    final regularBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: const BorderSide(color: AppColors.outlineVariant),
    );
    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: const BorderSide(color: AppColors.error),
    );

    return DropdownButtonFormField<T>(
      key: ValueKey(value),
      initialValue: value,
      isExpanded: true,
      dropdownColor: AppColors.surfaceLow,
      iconEnabledColor: AppColors.textSecondary,
      iconDisabledColor: AppColors.textHint,
      style: TextStyle(
        color: enabled ? AppColors.textPrimary : AppColors.textHint,
        fontSize: context.bodyFontSize,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        label: Container(
          color: fillColor,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(mandatory ? '$label *' : label),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        floatingLabelStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        errorText: errorText,
        errorStyle: TextStyle(
          color: AppColors.error,
          fontSize: context.smallFontSize,
        ),
        filled: true,
        fillColor: fillColor,
        contentPadding: EdgeInsets.symmetric(
          horizontal: context.defaultPaddingSc,
          vertical: context.scaleHeight(14),
        ),
        border: regularBorder,
        enabledBorder: regularBorder,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: AppColors.primaryContainer),
        ),
        errorBorder: errorBorder,
        focusedErrorBorder: errorBorder,
        disabledBorder: regularBorder,
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<T>(
              value: item,
              child: Text(itemLabelBuilder(item)),
            ),
          )
          .toList(),
      onChanged: enabled ? onChanged : null,
    );
  }
}
