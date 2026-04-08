import 'dart:io';

class Enviroment {
  static String get baseUrlDev {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    } else if (Platform.isIOS) {
      return 'http://localhost:3000';
    }
    return 'http://localhost:3000';
  }

  static String baseUrlProd = 'https://allowing-starling-heroic.ngrok-free.app';

  static String apiUrl = '$baseUrlDev/api';

  static String get uploadsUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    } else if (Platform.isIOS) {
      return 'http://localhost:3000';
    }
    return 'http://localhost:3000';
  }
}
