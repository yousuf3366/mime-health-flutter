import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';

import '../constants/app_constants.dart';
import '../extensions/context_extensions.dart';
import '../theme/app_colors.dart';

/// Reusable date picker field for forms across the app.
class AppDatePicker extends HookWidget {
  const AppDatePicker({
    super.key,
    required this.label,
    required this.selectedDate,
    required this.onChanged,
    required this.firstDate,
    required this.lastDate,
    this.mandatory = false,
    this.displayFormat = AppConstants.uiDateFormat,
    this.serverFormat = AppConstants.serverDateFormat,
    this.errorText,
    this.enabled = true,
    this.hintText,
  });

  final String label;
  final DateTime? selectedDate;
  final ValueChanged<DateTime?> onChanged;
  final DateTime firstDate;
  final DateTime lastDate;
  final bool mandatory;
  final String displayFormat;
  final String serverFormat;
  final String? errorText;
  final bool enabled;
  final String? hintText;

  String? serverValue() => selectedDate != null
      ? DateFormat(serverFormat).format(selectedDate!)
      : null;

  static String? formatForServer(
    DateTime? date, {
    String format = AppConstants.serverDateFormat,
  }) {
    if (date == null) return null;
    return DateFormat(format).format(date);
  }

  @override
  Widget build(BuildContext context) {
    final touched = useState(false);

    final formattedDate = selectedDate != null
        ? DateFormat(displayFormat).format(selectedDate!)
        : null;

    final resolvedError = errorText ??
        (mandatory && touched.value && selectedDate == null
            ? '$label is required'
            : null);

    Future<void> pickDate() async {
      if (!enabled) return;
      touched.value = true;

      final initialDate = selectedDate ??
          DateTime(
            lastDate.year,
            lastDate.month,
            lastDate.day,
          ).subtract(const Duration(days: 365 * 25));

      final clampedInitial = initialDate.isBefore(firstDate)
          ? firstDate
          : (initialDate.isAfter(lastDate) ? lastDate : initialDate);

      final picked = await showDatePicker(
        context: context,
        initialDate: clampedInitial,
        firstDate: firstDate,
        lastDate: lastDate,
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.dark(
                primary: AppColors.primaryContainer,
                onPrimary: AppColors.onPrimaryContainer,
                surface: AppColors.background,
                onSurface: AppColors.textPrimary,
              ),
            ),
            child: child!,
          );
        },
      );

      if (picked != null) {
        onChanged(picked);
      }
    }

    final radius = context.scaleWidth(10);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          mandatory ? '$label *' : label,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: context.fontSize,
          ),
        ),
        SizedBox(height: context.scaleHeight(8)),
        Material(
          color: enabled ? AppColors.surfaceLow : AppColors.surfaceSolid,
          borderRadius: BorderRadius.circular(radius),
          child: InkWell(
            onTap: enabled ? pickDate : null,
            borderRadius: BorderRadius.circular(radius),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: context.defaultPaddingSc,
                vertical: context.scaleHeight(14),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(
                  color: resolvedError != null
                      ? AppColors.error
                      : AppColors.outlineVariant,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      formattedDate ?? (hintText ?? 'Select $label'),
                      style: TextStyle(
                        color: !enabled
                            ? AppColors.textHint
                            : (selectedDate != null
                                ? AppColors.textPrimary
                                : AppColors.textSecondary),
                        fontSize: context.bodyFontSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.calendar_month,
                    color: enabled
                        ? AppColors.textSecondary
                        : AppColors.textHint,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (resolvedError != null)
          Padding(
            padding: EdgeInsets.only(
              top: context.scaleHeight(6),
              left: context.scaleWidth(4),
            ),
            child: Text(
              resolvedError,
              style: TextStyle(
                color: AppColors.error,
                fontSize: context.smallFontSize,
              ),
            ),
          ),
      ],
    );
  }
}
