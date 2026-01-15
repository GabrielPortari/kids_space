/// Format a [DateTime] into a short time string `HH:mm`.
///
/// Example: `DateTime(2024,1,2,9,5)` -> `"09:05"`.
String formatDate_HHmm(DateTime? dt) {
  if (dt == null) return '';
  return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

/// Format a [DateTime] into a short date string `dd/MM`.
///
/// Example: `DateTime(2024,3,7)` -> `"07/03"`.
String formatDate_ddMM(DateTime? dt) {
  if (dt == null) return '';
  return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}';
}

/// Format a [DateTime] into a full date string `dd/MM/yyyy`.
///
/// Example: `DateTime(2024,3,7)` -> `"07/03/2024"`.
String formatDate_ddMMyyyy(DateTime? dt) {
  if (dt == null) return '';
  return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
}

/// Parse a date string in `dd/MM/yyyy` format and return an ISO-8601 string.
///
/// Returns `null` if parsing fails (invalid format or non-numeric parts).
/// Example: `"07/03/2024"` -> `"2024-03-07T00:00:00.000"`.
String? formatDateToIsoString(String dateStr) {
  try {
    final parts = dateStr.split('/');
    if (parts.length != 3) return null;
    final day = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final year = int.parse(parts[2]);
    final dt = DateTime(year, month, day);
    return dt.toIso8601String();
  } catch (e) {
    return null;
  }
}

/// Format a [DateTime] into `dd/MM HH:mm` (day/month plus hour:minute).
///
/// Example: `DateTime(2026,2,1,10,25)` -> `"01/02 10:25"`.
String formatDate_ddMM_HHmm(DateTime? dt) {
  if (dt == null) return '';
  final date = formatDate_ddMM(dt);
  final time = formatDate_HHmm(dt);
  return '$date $time';
}