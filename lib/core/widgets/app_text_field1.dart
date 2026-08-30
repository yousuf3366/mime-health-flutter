import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../extensions/context_extensions.dart';
import '../theme/app_colors.dart';

class AppTextField1 extends HookWidget {
  final String label;
  final String? initialValue;
  final TextInputType keyboardType;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onDebouncedChanged;
  final int debounceMilliseconds;
  final bool mandatory;
  final bool isPassword;
  final String? errorText;
  final bool isReadOnly;
  final bool isMultiline;
  final int? minLines;
  final int? maxLines;
  final String? Function(String?)? validator;

  const AppTextField1({
    super.key,
    required this.label,
    required this.onChanged,
    this.onDebouncedChanged,
    this.initialValue,
    this.keyboardType = TextInputType.text,
    this.mandatory = false,
    this.isReadOnly = false,
    this.isPassword = false,
    this.errorText,
    this.validator,
    this.debounceMilliseconds = 1000,
    this.isMultiline = false,
    this.minLines,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController();
    final internalError = useState<String?>(null);
    final isHide = useState(true);
    final debounceTimer = useRef<Timer?>(null);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final value = initialValue ?? '';

        if (controller.text == value) {
          return;
        }

        final previousSelection = controller.selection;

        controller.value = TextEditingValue(
          text: value,
          selection: TextSelection.collapsed(
            offset: previousSelection.baseOffset.clamp(0, value.length),
          ),
        );

        internalError.value = null;
      });

      return null;
    }, [initialValue]);

    void handleDebounce(String value) {
      debounceTimer.value?.cancel();

      debounceTimer.value = Timer(
        Duration(milliseconds: debounceMilliseconds),
        () {
          onDebouncedChanged?.call(value);
        },
      );
    }

    useEffect(() {
      return () {
        debounceTimer.value?.cancel();
      };
    }, []);

    String? combinedValidator(String? value) {
      if (mandatory && (value == null || value.trim().isEmpty)) {
        return '$label is required';
      }

      return validator?.call(value);
    }

    final radius = context.scaleWidth(10);
    final resolvedError = mandatory
        ? (errorText ?? internalError.value)
        : errorText;
    final regularBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: const BorderSide(color: AppColors.outlineVariant),
    );
    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: const BorderSide(color: AppColors.error),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          keyboardType: isMultiline ? TextInputType.multiline : keyboardType,
          readOnly: isReadOnly,
          minLines: isMultiline ? (minLines ?? 3) : 1,
          maxLines: isMultiline ? (maxLines ?? 5) : 1,
          obscureText: isPassword ? isHide.value : false,
          validator: combinedValidator,
          cursorColor: AppColors.primaryContainer,
          style: TextStyle(
            color: isReadOnly ? AppColors.textHint : AppColors.textPrimary,
            fontSize: context.bodyFontSize,
            fontWeight: FontWeight.w600,
          ),
          onChanged: isReadOnly
              ? null
              : (value) {
                  internalError.value = null;

                  onChanged(value);

                  handleDebounce(value);
                },
          decoration: InputDecoration(
            label: Container(
              color: isReadOnly ? AppColors.surfaceSolid : AppColors.surfaceLow,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(mandatory ? '$label *' : label),
            ),
            labelStyle: const TextStyle(color: AppColors.textSecondary),
            floatingLabelStyle: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            errorText: resolvedError,
            errorStyle: TextStyle(
              color: AppColors.error,
              fontSize: context.smallFontSize,
            ),
            alignLabelWithHint: isMultiline,
            filled: true,
            fillColor: isReadOnly
                ? AppColors.surfaceSolid
                : AppColors.surfaceLow,
            contentPadding: EdgeInsets.symmetric(
              horizontal: context.defaultPaddingSc,
              vertical: context.scaleHeight(14),
            ),
            suffixIcon: isPassword
                ? IconButton(
                    onPressed: () {
                      isHide.value = !isHide.value;
                    },
                    icon: Icon(
                      isHide.value ? Icons.visibility : Icons.visibility_off,
                      color: AppColors.textSecondary,
                    ),
                  )
                : null,
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
        ),
      ],
    );
  }
}
