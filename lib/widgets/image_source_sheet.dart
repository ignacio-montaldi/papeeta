import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageSourceSheet extends StatelessWidget {
  final Function(ImageSource) onImageSourceSelected;

  const ImageSourceSheet({super.key, required this.onImageSourceSelected});

  static Future<void> show(
    BuildContext context, {
    required Function(ImageSource) onImageSourceSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => ImageSourceSheet(onImageSourceSelected: onImageSourceSelected),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: const Text('Tomar foto'),
            onTap: () {
              Navigator.pop(context);
              onImageSourceSelected(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Elegir de la galería'),
            onTap: () {
              Navigator.pop(context);
              onImageSourceSelected(ImageSource.gallery);
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}