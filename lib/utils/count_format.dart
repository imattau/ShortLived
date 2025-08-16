int parseCount(String s) {
  final n = int.tryParse(s.replaceAll(RegExp(r'[^0-9]'), ''));
  return n ?? 0;
}

String formatCount(int v) {
  if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}m';
  if (v >= 1000)    return '${(v / 1000).toStringAsFixed(1)}k';
  return '$v';
}
