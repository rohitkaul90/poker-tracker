int calcDurationMinutes(String startTime, String endTime) {
  final start = _timeToMinutes(startTime);
  final end = _timeToMinutes(endTime);
  int diff = end - start;
  if (diff < 0) diff += 24 * 60;
  return diff;
}

int _timeToMinutes(String time) {
  final parts = time.split(':');
  return int.parse(parts[0]) * 60 + int.parse(parts[1]);
}

String formatDuration(int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (h == 0) return '${m}m';
  if (m == 0) return '${h}h';
  return '${h}h ${m}m';
}

String formatPL(double amount) {
  if (amount >= 0) return '+\$${amount.toStringAsFixed(0)}';
  return '-\$${amount.abs().toStringAsFixed(0)}';
}
