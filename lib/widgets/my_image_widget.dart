import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:papeeta/models/my_image_model.dart';

class MyImageWidget extends StatelessWidget {
  final MyImageModel image;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const MyImageWidget({
    super.key,
    required this.image,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (image.isLocal) {
      // Soporte para assets o archivos locales
      if (image.file != null) {
        imageWidget = Image.file(
          image.file!,
          fit: fit,
          width: width,
          height: height,
        );
      } else {
        imageWidget = Image.asset(
          image.url,
          fit: fit,
          width: width,
          height: height,
        );
      }
    } else {
      // Imágenes desde la red con caché
      imageWidget = CachedNetworkImage(
        imageUrl: image.url,
        fit: fit,
        width: width,
        height: height,
        placeholder: (context, url) =>
            placeholder ??
            Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        errorWidget: (context, url, error) =>
            errorWidget ?? const Icon(Icons.broken_image, color: Colors.grey),
      );
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: imageWidget,
    );
  }
}
