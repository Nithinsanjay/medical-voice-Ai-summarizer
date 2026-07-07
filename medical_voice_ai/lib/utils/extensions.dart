extension DoubleExtensions on double {
  String toPercentString() => '${(this * 100).toStringAsFixed(0)}%';
}
