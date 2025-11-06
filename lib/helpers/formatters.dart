String formatDouble(double value) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  } else {
    return value.toString();
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
