import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:papeeta/core/theme/theme.dart';
import 'package:papeeta/widgets/ds/app_bottom_sheet.dart';

/// Sheet para elegir el origen de una foto.
class ImageSourceSheet extends StatelessWidget {
  const ImageSourceSheet({super.key, required this.onImageSourceSelected});

  final ValueChanged<ImageSource> onImageSourceSelected;

  static Future<void> show(
    BuildContext context, {
    required ValueChanged<ImageSource> onImageSourceSelected,
  }) {
    return showAppBottomSheet(
      context: context,
      builder: (_) => ImageSourceSheet(
        onImageSourceSelected: onImageSourceSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      title: 'Agregar foto',
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Opcion(
            icon: Icons.photo_camera_rounded,
            label: 'Tomar foto',
            onTap: () {
              Navigator.pop(context);
              onImageSourceSelected(ImageSource.camera);
            },
          ),
          Divider(height: 1, color: context.semantic.divider),
          _Opcion(
            icon: Icons.photo_library_rounded,
            label: 'Elegir de la galería',
            onTap: () {
              Navigator.pop(context);
              onImageSourceSelected(ImageSource.gallery);
            },
          ),
        ],
      ),
    );
  }
}

class _Opcion extends StatelessWidget {
  const _Opcion({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.mdAll,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.md + 2,
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: colors.primary),
            const SizedBox(width: 14),
            Text(
              label,
              style: AppTypography.body.copyWith(
                fontSize: 15,
                color: colors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
