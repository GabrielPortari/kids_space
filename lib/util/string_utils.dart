String getInitials(String? name) {
  if (name == null || name.trim().isEmpty) return '?';
  final parts = name.trim().split(RegExp(r'\s+'));
  return parts[0][0].toUpperCase();
}

String normalizeDigits(String? s) {
  if (s == null) return '';
  return s.replaceAll(RegExp(r'\D'), '');
}
