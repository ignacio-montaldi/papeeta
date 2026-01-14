import 'dart:io';

class MyImageModel {
  final String? url; // remoto
  final File? file; // local
  final bool isLocal;

  const MyImageModel({this.url, this.file}) : isLocal = file != null;

  factory MyImageModel.network(String url) {
    return MyImageModel(url: url);
  }

  factory MyImageModel.local(File file) {
    return MyImageModel(file: file);
  }
}
