bool isValidUrl(String? url) {
  if (url == null || url.isEmpty) return false;

  final uri = Uri.tryParse(url);
  return uri != null && (uri.isScheme("http") || uri.isScheme("https"));
}
