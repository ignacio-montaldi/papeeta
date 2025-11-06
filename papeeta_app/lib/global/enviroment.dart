import 'dart:io';

class Enviroment {
  static String apiUrl = Platform.isAndroid
      ? 'http://localhost:3000/api'
      : 'http://localhost:3000/api';

  static String uploadsUrl = Platform.isAndroid
      ? 'http://localhost:3000'
      : 'http://localhost:3000';
}
