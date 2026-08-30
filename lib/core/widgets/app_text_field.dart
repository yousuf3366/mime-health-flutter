import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Styled text field with an internal controller.
///
/// Callers pass [textState] and [errorState] only — never a controller.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.textState,
    required this.onChanged,
    required this.label,
    this.errorState,
    this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.textInputAction,
    this.onSubmitted,
    this.enabled = true,
    this.inputFormatters,
    this.maxLength,
  });

  final String? textState;
  final String? errorState;
  final ValueChanged<String> onChanged;
  final String label;
  final String? hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.textState ?? '');
  }

  @override
  void didUpdateWidget(covariant AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextText = widget.textState ?? '';
    if (nextText != _controller.text) {
      _controller.value = _controller.value.copyWith(
        text: nextText,
        selection: TextSelection.collapsed(offset: nextText.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextField(
      controller: _controller,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: theme.colorScheme.onSurface,
      ),
      cursorColor: theme.colorScheme.primary,
      obscureText: widget.obscureText,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      onSubmitted: widget.onSubmitted,
      enabled: widget.enabled,
      inputFormatters: widget.inputFormatters,
      maxLength: widget.maxLength,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        errorText: widget.errorState,
        counterStyle: theme.textTheme.bodySmall,
        prefixIcon:
            widget.prefixIcon == null ? null : Icon(widget.prefixIcon),
        suffixIcon: widget.suffixIcon,
      ),
    );
  }
}
