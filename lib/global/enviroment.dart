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

  //Cambiar estas si se está en prod o en dev
  static String apiUrl = '$baseUrlProd/api';
  static String uploadsUrl = baseUrlProd;

  // static String apiUrl = '$baseUrlDev/api';
  // static String uploadsUrl = baseUrlDev;
}
