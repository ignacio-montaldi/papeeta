import 'package:flutter/material.dart';

import 'package:papeeta/core/theme/theme.dart';

/// Campo de texto único del sistema.
///
/// Reemplaza tanto a `CustomInput` (la píldora con sombra) como a los
/// `TextFormField` con `OutlineInputBorder` sueltos. Relleno, label flotante,
/// texto de ayuda y error, con toggle de visibilidad cuando es contraseña.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.helper,
    this.errorText,
    this.icon,
    this.keyboardType,
    this.isPassword = false,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.textCapitalization = TextCapitalization.none,
    this.onChanged,
    this.validator,
    this.textInputAction,
    this.autofocus = false,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final String? helper;

  /// Error controlado desde afuera. Si se usa [validator], dejarlo en `null`.
  final String? errorText;

  final IconData? icon;
  final TextInputType? keyboardType;
  final bool isPassword;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final bool autofocus;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscure = widget.isPassword;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasError = widget.errorText != null;

    return TextFormField(
      controller: widget.controller,
      enabled: widget.enabled,
      obscureText: _obscure,
      keyboardType: widget.keyboardType,
      maxLines: _obscure ? 1 : widget.maxLines,
      minLines: widget.minLines,
      textCapitalization: widget.textCapitalization,
      onChanged: widget.onChanged,
      validator: widget.validator,
      textInputAction: widget.textInputAction,
      autofocus: widget.autofocus,
      autocorrect: !widget.isPassword,
      style: AppTypography.body.copyWith(
        fontSize: 15,
        color: widget.enabled ? colors.onSurface : AppColors.disabledContent,
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        helperText: widget.helper,
        errorText: widget.errorText,
        filled: true,
        fillColor: !widget.enabled
            ? AppColors.inputDisabledFill
            : hasError
                ? AppColors.errorFieldFill
                : colors.surfaceContainer,
        prefixIcon: widget.icon == null
            ? null
            : Icon(
                widget.icon,
                size: 20,
                color: hasError ? colors.error : colors.onSurfaceVariant,
              ),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscure
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  size: 20,
                  color: colors.onSurfaceVariant,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
                tooltip: _obscure ? 'Mostrar contraseña' : 'Ocultar contraseña',
              )
            : null,
      ),
    );
  }
}

/// Campo de búsqueda: relleno, sin borde, con lupa.
class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    required this.onChanged,
    this.hint = 'Buscar…',
    this.controller,
    this.autofocus = false,
  });

  final ValueChanged<String> onChanged;
  final String hint;
  final TextEditingController? controller;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return TextField(
      controller: controller,
      autofocus: autofocus,
      onChanged: onChanged,
      style: AppTypography.body.copyWith(fontSize: 15, color: colors.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: colors.surfaceContainer,
        prefixIcon: Icon(
          Icons.search_rounded,
          size: 20,
          color: colors.onSurfaceVariant,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 11),
        border: const OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
      ),
    );
  }
}
