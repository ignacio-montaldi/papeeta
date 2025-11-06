import 'dart:io';

class MyImageModel {
  final String url;
  final bool isLocal;
  final File? file;
  final String? description;

  MyImageModel({
    required this.url,
    this.isLocal = false,
    this.file,
    this.description,
  });
}
