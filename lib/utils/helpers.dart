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

String currencySymbol(String currency) {
  switch (currency) {
    case 'USD':
      return '\$';
    case 'CAD':
      return 'CA\$';
    case 'GBP':
      return '£';
    case 'EUR':
      return '€';
    case 'AUD':
      return 'A\$';
    case 'NZD':
      return 'NZ\$';
    default:
      return '\$';
  }
}

String formatAmount(double amount, String currency) {
  return '${currencySymbol(currency)}${amount.toStringAsFixed(0)}';
}

String formatPLWithCurrency(double amount, String currency) {
  final sym = currencySymbol(currency);
  if (amount >= 0) return '+$sym${amount.toStringAsFixed(0)}';
  return '-$sym${amount.abs().toStringAsFixed(0)}';
}

double calcROI(double profitLoss, double buyIn) {
  if (buyIn <= 0) return 0;
  return profitLoss / buyIn * 100;
}

String formatROI(double roiPercent) {
  return '${roiPercent >= 0 ? '+' : ''}${roiPercent.toStringAsFixed(1)}%';
}

String tournamentBuyInBucket(double buyIn) {
  if (buyIn < 50) return '< \$50';
  if (buyIn < 100) return '\$50–\$100';
  if (buyIn < 200) return '\$100–\$200';
  if (buyIn < 500) return '\$200–\$500';
  return '> \$500';
}

bool isTournamentType(String gameType) =>
    gameType == 'tournament' || gameType == 'sit_and_go';

String gameTypeLabel(String gameType) {
  switch (gameType) {
    case 'cash':
      return 'Cash Game';
    case 'tournament':
    case 'sit_and_go':
      return 'Tournament';
    default:
      return gameType;
  }
}

String tableQualityLabel(int? quality) {
  switch (quality) {
    case 1:
      return 'Very Tough';
    case 2:
      return 'Tough';
    case 3:
      return 'Average';
    case 4:
      return 'Soft';
    case 5:
      return 'Very Soft';
    default:
      return 'Not rated';
  }
}

String timeOfDayBucket(String startTime) {
  final hour = int.tryParse(startTime.split(':')[0]) ?? 0;
  if (hour >= 6 && hour < 12) return 'Morning (6am–12pm)';
  if (hour >= 12 && hour < 18) return 'Afternoon (12pm–6pm)';
  if (hour >= 18 && hour < 23) return 'Evening (6pm–11pm)';
  return 'Late Night (11pm–6am)';
}

String sessionLengthBucket(int minutes) {
  if (minutes < 120) return '< 2 hours';
  if (minutes < 240) return '2–4 hours';
  if (minutes < 360) return '4–6 hours';
  return '> 6 hours';
}

String dayOfWeekLabel(String date) {
  final dt = DateTime.parse(date);
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return days[dt.weekday - 1];
}

String monthLabel(String date) {
  final dt = DateTime.parse(date);
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return '${months[dt.month - 1]} ${dt.year}';
}
