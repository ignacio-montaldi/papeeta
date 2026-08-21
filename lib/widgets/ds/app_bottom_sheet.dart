import 'package:flutter/material.dart';

import 'package:papeeta/core/theme/theme.dart';

/// Contenedor de bottom sheet del sistema: radio superior 24, handle y título.
///
/// Se usa junto con [showAppBottomSheet], que aplica el resto de la
/// configuración (scroll, insets del teclado, barrera).
class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.onClose,
    this.padding = const EdgeInsets.fromLTRB(
      AppSpacing.xl,
      AppSpacing.md,
      AppSpacing.xl,
      AppSpacing.xl,
    ),
  });

  final Widget child;
  final String? title;
  final VoidCallback? onClose;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.sheetTop,
      ),
      padding: EdgeInsets.only(
        left: padding.left,
        right: padding.right,
        top: padding.top,
        bottom: padding.bottom + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.outlineVariant,
                borderRadius: AppRadius.fullAll,
              ),
            ),
          ),
          if (title != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: Text(
                    title!,
                    style: AppTypography.title.copyWith(
                      fontSize: 16,
                      color: colors.onSurface,
                    ),
                  ),
                ),
                if (onClose != null)
                  IconButton(
                    onPressed: onClose,
                    icon: const Icon(Icons.close_rounded),
                    color: colors.onSurfaceVariant,
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.sm + 2),
          Flexible(child: child),
        ],
      ),
    );
  }
}

/// Abre un [AppBottomSheet] con la configuración del sistema.
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.4),
    builder: builder,
  );
}
