import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:papeeta/features/recipes/domain/entities/recipe_image.dart';
import 'package:papeeta/features/recipes/domain/entities/recipe_image_upload.dart';
import 'package:papeeta/features/groups/domain/entities/group_image.dart';

class MyImageWidget extends StatelessWidget {
  final dynamic image;
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

  bool get isLocal => image is RecipeImageUpload;
  bool get isRemoteRecipeImage => image is RecipeImage;
  bool get isRemoteGroupImage => image is GroupImage;

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (isLocal) {
      final uploadImage = image as RecipeImageUpload;
      imageWidget = Image.file(
        uploadImage.file,
        fit: fit,
        width: width,
        height: height,
      );
    } else if (isRemoteRecipeImage) {
      final recipeImage = image as RecipeImage;
      imageWidget = CachedNetworkImage(
        imageUrl: recipeImage.url,
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
    } else if (isRemoteGroupImage) {
      final groupImage = image as GroupImage;
      imageWidget = CachedNetworkImage(
        imageUrl: groupImage.url,
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
    } else {
      imageWidget =
          errorWidget ?? const Icon(Icons.broken_image, color: Colors.grey);
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: imageWidget,
    );
  }
}
