String formatDouble(double value) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  } else {
    return value.toString();
  }
}
