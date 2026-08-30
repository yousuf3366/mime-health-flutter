import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../extensions/context_extensions.dart';
import '../theme/app_colors.dart';

/// Four single-digit OTP boxes with auto-advance, backspace, and paste support.
class AppOtpField extends HookWidget {
  const AppOtpField({
    super.key,
    required this.onChanged,
    this.length = 4,
    this.initialValue,
    this.errorText,
    this.enabled = true,
    this.autofocus = true,
  });

  final int length;
  final String? initialValue;
  final ValueChanged<String> onChanged;
  final String? errorText;
  final bool enabled;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final controllers = useMemoized(
      () => List.generate(length, (_) => TextEditingController()),
      [length],
    );
    final focusNodes = useMemoized(
      () => List.generate(length, (_) => FocusNode()),
      [length],
    );

    useEffect(() {
      for (var i = 0; i < length; i++) {
        final index = i;
        focusNodes[index].onKeyEvent = (node, event) {
          if (event is! KeyDownEvent) return KeyEventResult.ignored;
          if (event.logicalKey != LogicalKeyboardKey.backspace) {
            return KeyEventResult.ignored;
          }
          if (controllers[index].text.isNotEmpty) {
            return KeyEventResult.ignored;
          }
          if (index > 0) {
            focusNodes[index - 1].requestFocus();
            controllers[index - 1].selection = TextSelection.collapsed(
              offset: controllers[index - 1].text.length,
            );
          }
          return KeyEventResult.handled;
        };
      }

      return () {
        for (final controller in controllers) {
          controller.dispose();
        }
        for (final node in focusNodes) {
          node.onKeyEvent = null;
          node.dispose();
        }
      };
    }, [controllers, focusNodes, length]);

    useEffect(() {
      final value = (initialValue ?? '').replaceAll(RegExp(r'\D'), '');
      final digits = value.padRight(length).substring(0, length);
      for (var i = 0; i < length; i++) {
        final char = digits[i].trim();
        final next = char == ' ' ? '' : char;
        if (controllers[i].text != next) {
          controllers[i].text = next;
        }
      }
      return null;
    }, [initialValue, length]);

    useEffect(() {
      if (!autofocus || !enabled) return null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (focusNodes.first.canRequestFocus) {
          focusNodes.first.requestFocus();
        }
      });
      return null;
    }, [autofocus, enabled]);

    void emitValue() {
      onChanged(controllers.map((c) => c.text).join());
    }

    void fillFrom(String raw, {required int startIndex}) {
      final digits = raw.replaceAll(RegExp(r'\D'), '');
      if (digits.isEmpty) return;

      var index = startIndex;
      for (final digit in digits.split('')) {
        if (index >= length) break;
        controllers[index].text = digit;
        index++;
      }
      emitValue();

      final nextFocus = index < length ? index : length - 1;
      focusNodes[nextFocus].requestFocus();
      controllers[nextFocus].selection = TextSelection.collapsed(
        offset: controllers[nextFocus].text.length,
      );
    }

    final hasError = errorText != null && errorText!.isNotEmpty;
    final theme = Theme.of(context);
    final radius = context.scaleWidth(10);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            for (var index = 0; index < length; index++) ...[
              if (index > 0) SizedBox(width: context.scaleWidth(8)),
              Expanded(
                child: TextField(
                  controller: controllers[index],
                  focusNode: focusNodes[index],
                  enabled: enabled,
                  autofillHints: index == 0
                      ? const [AutofillHints.oneTimeCode]
                      : null,
                  keyboardType: const TextInputType.numberWithOptions(
                    signed: false,
                    decimal: false,
                  ),
                  textAlign: TextAlign.center,
                  cursorColor: Colors.black,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: context.largeFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(length),
                  ],
                  onChanged: (value) {
                    if (value.length > 1) {
                      fillFrom(value, startIndex: index);
                      return;
                    }

                    if (value.isNotEmpty) {
                      controllers[index].text = value.substring(
                        value.length - 1,
                      );
                      emitValue();
                      if (index < length - 1) {
                        focusNodes[index + 1].requestFocus();
                      } else {
                        focusNodes[index].unfocus();
                      }
                    } else {
                      emitValue();
                    }
                  },
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: context.scaleHeight(14),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(radius),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(radius),
                      borderSide: hasError
                          ? BorderSide(color: theme.colorScheme.error)
                          : BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(radius),
                      borderSide: BorderSide(
                        color: hasError
                            ? theme.colorScheme.error
                            : AppColors.button,
                        width: 1.5,
                      ),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(radius),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        if (hasError) ...[
          SizedBox(height: context.scaleHeight(8)),
          Text(
            errorText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
              fontSize: context.smallFontSize,
            ),
          ),
        ],
      ],
    );
  }
}
