import 'package:url_launcher/url_launcher.dart' as url_launcher;

Future<void> launchUrl(String urlString) async {
  final Uri url = Uri.parse(urlString);

  if (!await url_launcher.launchUrl(url)) {
    throw Exception('Could not launch $url');
  }
}
