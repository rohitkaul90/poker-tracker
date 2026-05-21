import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/poker_rooms.dart';
import '../models/session_model.dart';
import '../providers/providers.dart';
import '../utils/helpers.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(sessionsProvider);
    return sessionsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (sessions) {
        if (sessions.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'Log some sessions to see analytics here.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        return _AnalyticsBody(sessions: sessions);
      },
    );
  }
}

class _AnalyticsBody extends StatefulWidget {
  final List<SessionModel> sessions;
  const _AnalyticsBody({required this.sessions});

  @override
  State<_AnalyticsBody> createState() => _AnalyticsBodyState();
}

class _AnalyticsBodyState extends State<_AnalyticsBody> {
  String? _gameFilter;
  String? _venueFilter;
  String? _countryFilter;
  String? _displayCurrency;

  @override
  void initState() {
    super.initState();
    // Default country to latest session's country when multiple exist
    final countries = widget.sessions
        .map((s) => s.country)
        .whereType<String>()
        .where((c) => c.isNotEmpty)
        .toSet();
    if (countries.length > 1) {
      final sorted = [...widget.sessions]
        ..sort((a, b) => b.date.compareTo(a.date));
      _countryFilter = sorted.first.country;
    }
  }

  String get _effectiveCurrency {
    if (_displayCurrency != null) return _displayCurrency!;
    if (widget.sessions.isEmpty) return 'CAD';
    final sorted = [...widget.sessions]
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.first.currency;
  }

  Set<String> get _allCountries => widget.sessions
      .map((s) => s.country)
      .whereType<String>()
      .where((c) => c.isNotEmpty)
      .toSet();

  bool get _hasMultipleCountries => _allCountries.length > 1;

  List<SessionModel> get _filtered {
    var result = widget.sessions;
    if (_countryFilter != null) {
      result = result.where((s) => s.country == _countryFilter).toList();
    }
    if (_gameFilter != null) {
      if (_gameFilter == 'tournament') {
        result = result.where((s) => isTournamentType(s.gameType)).toList();
      } else {
        result = result.where((s) => s.gameType == 'cash').toList();
      }
    }
    if (_venueFilter == 'online') {
      result = result.where((s) => isOnlineSession(s.location)).toList();
    } else if (_venueFilter == 'live') {
      result = result.where((s) => !isOnlineSession(s.location)).toList();
    }
    return result;
  }

  List<SessionModel> get _sorted =>
      [..._filtered]..sort((a, b) => a.date.compareTo(b.date));

  bool get _hasCash => widget.sessions.any((s) => s.gameType == 'cash');
  bool get _hasTournament =>
      widget.sessions.any((s) => isTournamentType(s.gameType));
  bool get _hasOnline =>
      widget.sessions.any((s) => isOnlineSession(s.location));
  bool get _hasLive =>
      widget.sessions.any((s) => !isOnlineSession(s.location));

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final sorted = _sorted;
    final displayCurrency = _effectiveCurrency;
    final showingTournaments = filtered.any((s) => isTournamentType(s.gameType));
    final showingCash = filtered.any((s) => s.gameType == 'cash');
    final showRow2 = _hasMultipleCountries || (_hasOnline && _hasLive);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
      children: [
        // Row 1: game type + currency
        Row(
          children: [
            _DropdownContainer(
              child: DropdownButton<String>(
                value: _gameFilter ?? 'all',
                isDense: true,
                underline: const SizedBox.shrink(),
                items: [
                  const DropdownMenuItem(
                      value: 'all',
                      child: Text('All Games',
                          style: TextStyle(fontSize: 13))),
                  if (_hasCash)
                    const DropdownMenuItem(
                        value: 'cash',
                        child:
                            Text('Cash', style: TextStyle(fontSize: 13))),
                  if (_hasTournament)
                    const DropdownMenuItem(
                        value: 'tournament',
                        child: Text('Tournament',
                            style: TextStyle(fontSize: 13))),
                ],
                onChanged: (v) =>
                    setState(() => _gameFilter = v == 'all' ? null : v),
              ),
            ),
            const SizedBox(width: 8),
            _CurrencyDropdown(
              value: displayCurrency,
              onChanged: (c) => setState(() => _displayCurrency = c),
            ),
          ],
        ),

        // Row 2: country + venue (conditional)
        if (showRow2) ...[
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (_hasMultipleCountries) ...[
                _CountryDropdown(
                  countries: _allCountries.toList()..sort(),
                  value: _countryFilter,
                  onChanged: (c) => setState(() => _countryFilter = c),
                ),
                if (_hasOnline && _hasLive) const SizedBox(width: 8),
              ],
              if (_hasOnline && _hasLive)
                _DropdownContainer(
                  child: DropdownButton<String>(
                    value: _venueFilter ?? 'all',
                    isDense: true,
                    underline: const SizedBox.shrink(),
                    items: const [
                      DropdownMenuItem(
                          value: 'all',
                          child: Text('All Venues',
                              style: TextStyle(fontSize: 13))),
                      DropdownMenuItem(
                          value: 'live',
                          child: Text('Live',
                              style: TextStyle(fontSize: 13))),
                      DropdownMenuItem(
                          value: 'online',
                          child: Text('Online',
                              style: TextStyle(fontSize: 13))),
                    ],
                    onChanged: (v) => setState(
                        () => _venueFilter = v == 'all' ? null : v),
                  ),
                ),
            ],
          ),
        ],
        const SizedBox(height: 12),

        if (filtered.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: Text('No sessions match this filter.')),
          )
        else ...[
          _StatsCard(sessions: filtered, displayCurrency: displayCurrency),
          const SizedBox(height: 16),

          // Recommendations
          if (_gameFilter == null && showingCash && showingTournaments) ...[
            _sectionHeader(context, 'Cash Game Recommendations'),
            const SizedBox(height: 8),
            _RecommendationsCard(
              sessions: filtered.where((s) => s.gameType == 'cash').toList(),
              gameTypeLabel: 'cash',
              displayCurrency: displayCurrency,
            ),
            const SizedBox(height: 16),
            _sectionHeader(context, 'Tournament Recommendations'),
            const SizedBox(height: 8),
            _RecommendationsCard(
              sessions: filtered
                  .where((s) => isTournamentType(s.gameType))
                  .toList(),
              gameTypeLabel: 'tournament',
              displayCurrency: displayCurrency,
            ),
          ] else if (showingCash) ...[
            _sectionHeader(context, 'Recommendations'),
            const SizedBox(height: 8),
            _RecommendationsCard(
              sessions: filtered.where((s) => s.gameType == 'cash').toList(),
              gameTypeLabel: 'cash',
              displayCurrency: displayCurrency,
            ),
          ] else if (showingTournaments) ...[
            _sectionHeader(context, 'Recommendations'),
            const SizedBox(height: 8),
            _RecommendationsCard(
              sessions: filtered
                  .where((s) => isTournamentType(s.gameType))
                  .toList(),
              gameTypeLabel: 'tournament',
              displayCurrency: displayCurrency,
            ),
          ],
          const SizedBox(height: 20),

          _sectionHeader(context, 'Charts'),
          const SizedBox(height: 8),

          _PLChart(sessions: sorted, displayCurrency: displayCurrency),
          const SizedBox(height: 12),

          _WinRateByAttributeChart(
            sessions: filtered,
            hasLiveAndOnline: _hasLive && _hasOnline,
            displayCurrency: displayCurrency,
          ),
          const SizedBox(height: 20),

          _sectionHeader(context, "What's Affecting Your Win Rate"),
          Text(
            'hrs  ·  ${currencySymbol(displayCurrency)}/hr  ·  P&L',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: 8),

          if (showingCash) ...[
            _InsightCard(
              title: 'By Stakes',
              sessions: filtered.where((s) => s.gameType == 'cash').toList(),
              keyFn: (s) => s.stakes,
              displayCurrency: displayCurrency,
            ),
            const SizedBox(height: 8),
          ],
          if (showingTournaments) ...[
            _InsightCard(
              title: 'By Buy-in Level',
              sessions: filtered
                  .where((s) => isTournamentType(s.gameType))
                  .toList(),
              keyFn: (s) => tournamentBuyInBucket(s.buyIn),
              orderedKeys: const [
                '< \$50', '\$50–\$100', '\$100–\$200', '\$200–\$500', '> \$500'
              ],
              displayCurrency: displayCurrency,
            ),
            const SizedBox(height: 8),
          ],
          if (_gameFilter == null && _hasCash && _hasTournament) ...[
            _InsightCard(
              title: 'By Game Type',
              sessions: filtered,
              keyFn: (s) => gameTypeLabel(s.gameType),
              displayCurrency: displayCurrency,
            ),
            const SizedBox(height: 8),
          ],
          _InsightCard(
            title: 'By Day of Week',
            sessions: filtered,
            keyFn: (s) => dayOfWeekLabel(s.date),
            orderedKeys: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
            displayCurrency: displayCurrency,
          ),
          const SizedBox(height: 8),
          _InsightCard(
            title: 'By Time of Day',
            sessions: filtered,
            keyFn: (s) => timeOfDayBucket(s.startTime),
            displayCurrency: displayCurrency,
          ),
          const SizedBox(height: 8),
          _InsightCard(
            title: 'By Session Length',
            sessions: filtered,
            keyFn: (s) => sessionLengthBucket(s.durationMinutes),
            orderedKeys: const [
              '< 2 hours', '2–4 hours', '4–6 hours', '> 6 hours'
            ],
            displayCurrency: displayCurrency,
          ),
          if (showingCash &&
              filtered.any(
                  (s) => s.tableQuality != null && s.gameType == 'cash')) ...[
            const SizedBox(height: 8),
            _InsightCard(
              title: 'By Table Quality',
              sessions: filtered
                  .where(
                      (s) => s.tableQuality != null && s.gameType == 'cash')
                  .toList(),
              keyFn: (s) =>
                  '${s.tableQuality}★ ${tableQualityLabel(s.tableQuality)}',
              orderedKeys: List.generate(
                  5, (i) => '${i + 1}★ ${tableQualityLabel(i + 1)}'),
              displayCurrency: displayCurrency,
            ),
          ],
          if (_hasMultipleLocations(filtered)) ...[
            const SizedBox(height: 8),
            _InsightCard(
              title: 'By Location',
              sessions: filtered
                  .where((s) => s.location?.isNotEmpty == true)
                  .toList(),
              keyFn: (s) => s.location!,
              displayCurrency: displayCurrency,
            ),
          ],
          if (_hasLive && _hasOnline) ...[
            const SizedBox(height: 8),
            _InsightCard(
              title: 'Live vs Online',
              sessions: filtered,
              keyFn: (s) => isOnlineSession(s.location) ? 'Online' : 'Live',
              orderedKeys: const ['Live', 'Online'],
              displayCurrency: displayCurrency,
            ),
          ],
        ],
      ],
    );
  }

  bool _hasMultipleLocations(List<SessionModel> sessions) {
    final locs = sessions
        .map((s) => s.location)
        .whereType<String>()
        .where((l) => l.isNotEmpty)
        .toSet();
    return locs.length > 1;
  }

  Widget _sectionHeader(BuildContext context, String title) => Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.bold),
      );
}

// ─── Dropdowns ────────────────────────────────────────────────────────────────

class _CurrencyDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const _CurrencyDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return _DropdownContainer(
      child: DropdownButton<String>(
        value: value,
        isDense: true,
        underline: const SizedBox.shrink(),
        items: supportedDisplayCurrencies
            .map((c) => DropdownMenuItem(
                  value: c,
                  child: Text('$c ${currencySymbol(c)}',
                      style: const TextStyle(fontSize: 13)),
                ))
            .toList(),
        onChanged: (c) => onChanged(c!),
      ),
    );
  }
}

class _CountryDropdown extends StatelessWidget {
  final List<String> countries;
  final String? value;
  final ValueChanged<String?> onChanged;
  const _CountryDropdown(
      {required this.countries, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return _DropdownContainer(
      child: DropdownButton<String?>(
        value: value,
        isDense: true,
        underline: const SizedBox.shrink(),
        hint: const Text('All Countries', style: TextStyle(fontSize: 13)),
        items: [
          const DropdownMenuItem<String?>(
            value: null,
            child: Text('All Countries', style: TextStyle(fontSize: 13)),
          ),
          ...countries.map((c) => DropdownMenuItem<String?>(
                value: c,
                child: Text(c, style: const TextStyle(fontSize: 13)),
              )),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

class _DropdownContainer extends StatelessWidget {
  final Widget child;
  const _DropdownContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(
            color: Theme.of(context).colorScheme.outline.withAlpha(80)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}

// ─── Summary Stats Card ───────────────────────────────────────────────────────

class _StatsCard extends StatelessWidget {
  final List<SessionModel> sessions;
  final String displayCurrency;
  const _StatsCard({required this.sessions, required this.displayCurrency});

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) return const SizedBox.shrink();
    final sym = currencySymbol(displayCurrency);
    final count = sessions.length;
    final totalHours =
        sessions.fold(0, (s, e) => s + e.durationMinutes) / 60.0;

    double toD(double amount, String from) =>
        convertCurrency(amount, from, displayCurrency);

    final totalPL =
        sessions.fold(0.0, (sum, s) => sum + toD(s.profitLoss, s.currency));
    final hourlyRate = totalHours > 0 ? totalPL / totalHours : 0.0;

    final tSessions =
        sessions.where((s) => isTournamentType(s.gameType)).toList();
    final hasTournaments = tSessions.isNotEmpty;
    final avgROI = hasTournaments
        ? tSessions.fold(
                0.0,
                (sum, s) =>
                    sum + (s.buyIn > 0 ? s.profitLoss / s.buyIn * 100 : 0.0)) /
            tSessions.length
        : null;
    final itm = hasTournaments
        ? tSessions.where((s) => (s.prizeWon ?? 0) > 0).length
        : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Summary',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 24,
              runSpacing: 12,
              children: [
                _StatItem(label: 'Sessions', value: '$count'),
                _StatItem(
                    label: 'Hours',
                    value: '${totalHours.toStringAsFixed(1)}h'),
                _StatItem(
                  label: 'Win Rate',
                  value: '$sym${hourlyRate.abs().toStringAsFixed(0)}/hr',
                  valueColor: hourlyRate >= 0 ? Colors.green : Colors.red,
                  prefix: hourlyRate >= 0 ? '+' : '-',
                ),
                _StatItem(
                  label: 'Total P&L',
                  value: formatPLWithCurrency(totalPL, displayCurrency),
                  valueColor: totalPL >= 0 ? Colors.green : Colors.red,
                ),
                if (avgROI != null)
                  _StatItem(
                    label: 'Avg ROI',
                    value: formatROI(avgROI),
                    valueColor: avgROI >= 0 ? Colors.green : Colors.red,
                  ),
                if (itm != null && tSessions.isNotEmpty)
                  _StatItem(
                    label: 'ITM',
                    value:
                        '${(itm / tSessions.length * 100).toStringAsFixed(0)}%',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final String? prefix;
  const _StatItem(
      {required this.label, required this.value, this.valueColor, this.prefix});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                )),
        const SizedBox(height: 2),
        Text(value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                )),
      ],
    );
  }
}

// ─── P&L Chart ────────────────────────────────────────────────────────────────

enum _PLMode { cumulative, monthly, yearly }

class _PLChart extends StatefulWidget {
  final List<SessionModel> sessions;
  final String displayCurrency;
  const _PLChart({required this.sessions, required this.displayCurrency});

  @override
  State<_PLChart> createState() => _PLChartState();
}

class _PLChartState extends State<_PLChart> {
  _PLMode _mode = _PLMode.cumulative;

  double _toD(double amount, String from) =>
      convertCurrency(amount, from, widget.displayCurrency);

  @override
  Widget build(BuildContext context) {
    final sym = currencySymbol(widget.displayCurrency);
    const modeLabels = {
      _PLMode.cumulative: 'Cumulative',
      _PLMode.monthly: 'Monthly',
      _PLMode.yearly: 'Yearly',
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text('P&L Over Time',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ),
                Wrap(
                  spacing: 4,
                  children: _PLMode.values
                      .map((mode) => ChoiceChip(
                            label: Text(modeLabels[mode]!,
                                style: const TextStyle(fontSize: 11)),
                            selected: _mode == mode,
                            onSelected: (_) =>
                                setState(() => _mode = mode),
                            visualDensity: VisualDensity.compact,
                          ))
                      .toList(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_mode == _PLMode.monthly)
              _buildMonthlyScrollable(context, sym)
            else
              SizedBox(
                height: 180,
                child: _mode == _PLMode.cumulative
                    ? _buildCumulative(context, sym)
                    : _buildYearly(context, sym),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCumulative(BuildContext context, String sym) {
    final sessions = widget.sessions;
    if (sessions.length < 2) return _emptyChart('Need at least 2 sessions');
    double cum = 0;
    final spots = sessions.asMap().entries.map((e) {
      cum += _toD(e.value.profitLoss, e.value.currency);
      return FlSpot(e.key.toDouble(), cum);
    }).toList();
    final minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final padding = (maxY - minY).abs() * 0.1 + 50;
    final color = cum >= 0 ? Colors.green : Colors.red;
    return LineChart(LineChartData(
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: color,
          barWidth: 2,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: true, color: color.withAlpha(30)),
        ),
      ],
      lineTouchData: const LineTouchData(enabled: false),
      minY: minY - padding,
      maxY: maxY + padding,
      titlesData: _leftTitlesOnly(sym),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (_) =>
            FlLine(color: Colors.white12, strokeWidth: 1),
      ),
      borderData: FlBorderData(show: false),
    ));
  }

  // Monthly view as a horizontally scrollable bar chart.
  Widget _buildMonthlyScrollable(BuildContext context, String sym) {
    final sessions = widget.sessions;
    final monthMap = <String, double>{};
    for (final s in sessions) {
      final key = s.date.substring(0, 7);
      monthMap[key] = (monthMap[key] ?? 0) + _toD(s.profitLoss, s.currency);
    }
    final entries = monthMap.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    if (entries.isEmpty) {
      return const SizedBox(
          height: 200,
          child: Center(
              child: Text('No data',
                  style: TextStyle(color: Colors.white38))));
    }
    final maxAbs = entries
        .map((e) => e.value.abs())
        .reduce((a, b) => a > b ? a : b);
    final effectiveMax = maxAbs < 1 ? 50.0 : maxAbs;
    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    const double barW = 20.0;
    const double perBarSlot = 48.0; // minimum width per bar
    const double leftSize = 60.0;
    const double bottomSize = 40.0;

    final groups = entries.asMap().entries.map((e) {
      final val = e.value.value;
      return BarChartGroupData(x: e.key, barRods: [
        BarChartRodData(
          toY: val,
          fromY: 0,
          color: val >= 0 ? Colors.green : Colors.red,
          width: barW,
          borderRadius: BorderRadius.circular(3),
        ),
      ]);
    }).toList();

    final labels = entries.map((e) {
      final parts = e.key.split('-');
      final month = monthNames[int.parse(parts[1]) - 1];
      final year = parts[0].substring(2);
      return "$month\n'$year";
    }).toList();

    return LayoutBuilder(builder: (_, constraints) {
      final totalWidth = math.max(
          constraints.maxWidth, leftSize + entries.length * perBarSlot);
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: totalWidth,
          height: 200,
          child: BarChart(BarChartData(
            barGroups: groups,
            minY: -(effectiveMax * 1.2),
            maxY: effectiveMax * 1.2,
            barTouchData: BarTouchData(enabled: false),
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: leftSize,
                  getTitlesWidget: (v, _) => Text(
                    _compact(v, sym),
                    style: const TextStyle(fontSize: 9),
                    textAlign: TextAlign.right,
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: bottomSize,
                  getTitlesWidget: (v, meta) {
                    final i = v.toInt();
                    if (i < 0 || i >= labels.length) return const SizedBox();
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(labels[i],
                          style: const TextStyle(fontSize: 9),
                          textAlign: TextAlign.center),
                    );
                  },
                ),
              ),
            ),
          )),
        ),
      );
    });
  }

  Widget _buildYearly(BuildContext context, String sym) {
    final sessions = widget.sessions;
    final yearMap = <String, double>{};
    for (final s in sessions) {
      final key = s.date.substring(0, 4);
      yearMap[key] = (yearMap[key] ?? 0) + _toD(s.profitLoss, s.currency);
    }
    final entries = yearMap.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    if (entries.isEmpty) return _emptyChart('No data');
    final maxAbs = entries
        .map((e) => e.value.abs())
        .reduce((a, b) => a > b ? a : b);
    final effectiveMax = maxAbs < 1 ? 50.0 : maxAbs;
    final groups = entries.asMap().entries.map((e) {
      final val = e.value.value;
      return BarChartGroupData(x: e.key, barRods: [
        BarChartRodData(
          toY: val,
          fromY: 0,
          color: val >= 0 ? Colors.green : Colors.red,
          width: 32,
          borderRadius: BorderRadius.circular(4),
        ),
      ]);
    }).toList();
    return BarChart(BarChartData(
      barGroups: groups,
      minY: -(effectiveMax * 1.2),
      maxY: effectiveMax * 1.2,
      barTouchData: BarTouchData(enabled: false),
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        topTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 64,
            getTitlesWidget: (v, _) => Text(
              _compact(v, sym),
              style: const TextStyle(fontSize: 9),
              textAlign: TextAlign.right,
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 24,
            getTitlesWidget: (v, meta) {
              final i = v.toInt();
              if (i < 0 || i >= entries.length) return const SizedBox();
              return Text(entries[i].key,
                  style: const TextStyle(fontSize: 10),
                  textAlign: TextAlign.center);
            },
          ),
        ),
      ),
    ));
  }

  FlTitlesData _leftTitlesOnly(String sym) => FlTitlesData(
        topTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 64,
            getTitlesWidget: (v, _) => Text(
              _compact(v, sym),
              style: const TextStyle(fontSize: 9),
              textAlign: TextAlign.right,
            ),
          ),
        ),
      );

  String _compact(double v, String sym) {
    final abs = v.abs();
    final sign = v >= 0 ? '+' : '-';
    if (abs >= 10000) return '$sign$sym${(abs / 1000).toStringAsFixed(0)}k';
    if (abs >= 1000) return '$sign$sym${(abs / 1000).toStringAsFixed(1)}k';
    return '$sign$sym${abs.toStringAsFixed(0)}';
  }
}

// ─── Win Rate by Attribute (dual-axis: P&L bars + win rate line) ──────────────

enum _WRAttr {
  timeOfDay, dayOfWeek, sessionLength, tableQuality, location, liveVsOnline
}

class _WinRateByAttributeChart extends StatefulWidget {
  final List<SessionModel> sessions;
  final bool hasLiveAndOnline;
  final String displayCurrency;

  const _WinRateByAttributeChart({
    required this.sessions,
    required this.displayCurrency,
    this.hasLiveAndOnline = false,
  });

  @override
  State<_WinRateByAttributeChart> createState() =>
      _WinRateByAttributeChartState();
}

class _WinRateByAttributeChartState extends State<_WinRateByAttributeChart> {
  _WRAttr _attr = _WRAttr.dayOfWeek;

  bool get _hasTableQuality => widget.sessions
      .any((s) => s.tableQuality != null && !isTournamentType(s.gameType));

  bool get _hasMultipleLocations {
    final locs = widget.sessions
        .map((s) => s.location)
        .whereType<String>()
        .where((l) => l.isNotEmpty)
        .toSet();
    return locs.length > 1;
  }

  (String? Function(SessionModel), List<String>?, String Function(String))
      _attrConfig() {
    switch (_attr) {
      case _WRAttr.timeOfDay:
        return (
          (s) => timeOfDayBucket(s.startTime),
          const [
            'Morning (6am–12pm)', 'Afternoon (12pm–6pm)',
            'Evening (6pm–11pm)', 'Late Night (11pm–6am)'
          ],
          (k) {
            if (k.startsWith('Morning')) return 'Morn';
            if (k.startsWith('Afternoon')) return 'Aftn';
            if (k.startsWith('Evening')) return 'Eve';
            return 'Late';
          },
        );
      case _WRAttr.dayOfWeek:
        return (
          (s) => dayOfWeekLabel(s.date),
          const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
          (k) => k,
        );
      case _WRAttr.sessionLength:
        return (
          (s) => sessionLengthBucket(s.durationMinutes),
          const ['< 2 hours', '2–4 hours', '4–6 hours', '> 6 hours'],
          (k) {
            if (k.startsWith('< 2')) return '<2h';
            if (k.startsWith('2–4')) return '2-4h';
            if (k.startsWith('4–6')) return '4-6h';
            return '>6h';
          },
        );
      case _WRAttr.tableQuality:
        return (
          (s) => (s.tableQuality != null && !isTournamentType(s.gameType))
              ? '${s.tableQuality}★'
              : null,
          ['1★', '2★', '3★', '4★', '5★'],
          (k) => k,
        );
      case _WRAttr.location:
        return (
          (s) => s.location?.isNotEmpty == true ? s.location : null,
          null,
          (k) => k.length > 8 ? '${k.substring(0, 7)}…' : k,
        );
      case _WRAttr.liveVsOnline:
        return (
          (s) => isOnlineSession(s.location) ? 'Online' : 'Live',
          const ['Live', 'Online'],
          (k) => k,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sym = currencySymbol(widget.displayCurrency);

    final availableAttrs = [
      _WRAttr.timeOfDay,
      _WRAttr.dayOfWeek,
      _WRAttr.sessionLength,
      if (_hasTableQuality) _WRAttr.tableQuality,
      if (_hasMultipleLocations) _WRAttr.location,
      if (widget.hasLiveAndOnline) _WRAttr.liveVsOnline,
    ];

    final attrLabels = {
      _WRAttr.timeOfDay: 'Time of Day',
      _WRAttr.dayOfWeek: 'Day of Week',
      _WRAttr.sessionLength: 'Session Length',
      _WRAttr.tableQuality: 'Table Quality',
      _WRAttr.location: 'Location',
      _WRAttr.liveVsOnline: 'Live vs Online',
    };

    if (!availableAttrs.contains(_attr)) {
      WidgetsBinding.instance.addPostFrameCallback(
          (_) => setState(() => _attr = _WRAttr.dayOfWeek));
    }

    final (keyFn, orderedKeys, shortLabel) = _attrConfig();

    // Build groups: totalPL and totalHours per attribute value.
    final groups =
        <String, ({double totalPL, double totalHours, int count})>{};
    for (final s in widget.sessions) {
      final key = keyFn(s);
      if (key == null) continue;
      final pl = convertCurrency(
          s.profitLoss, s.currency, widget.displayCurrency);
      final existing = groups[key];
      if (existing == null) {
        groups[key] = (
          totalPL: pl,
          totalHours: s.durationMinutes / 60.0,
          count: 1,
        );
      } else {
        groups[key] = (
          totalPL: existing.totalPL + pl,
          totalHours: existing.totalHours + s.durationMinutes / 60.0,
          count: existing.count + 1,
        );
      }
    }

    if (groups.isEmpty) {
      return _ChartCard(
        title: 'Win Rate by Attribute',
        child: _emptyChart('No data for this attribute'),
      );
    }

    final hourlyRates = groups.map((k, v) =>
        MapEntry(k, v.totalHours > 0 ? v.totalPL / v.totalHours : v.totalPL));

    List<String> keys;
    if (orderedKeys != null) {
      keys = orderedKeys.where((k) => groups.containsKey(k)).toList();
      for (final k in groups.keys) {
        if (!keys.contains(k)) keys.add(k);
      }
    } else {
      keys = groups.keys.toList()
        ..sort((a, b) => (groups[b]!.totalPL).compareTo(groups[a]!.totalPL));
    }

    // Win rate scale
    final rateValues = keys.map((k) => hourlyRates[k]!).toList();
    final rateMaxAbs =
        rateValues.map((v) => v.abs()).reduce((a, b) => a > b ? a : b);
    final rateEff = rateMaxAbs < 1 ? 10.0 : rateMaxAbs;
    final rateMinY =
        rateValues.any((v) => v < 0) ? -(rateEff * 1.35) : -(rateEff * 0.1);
    final rateMaxY = rateEff * 1.35;

    final barWidth = keys.length <= 3
        ? 28.0
        : keys.length <= 5
            ? 22.0
            : keys.length <= 7
                ? 16.0
                : 10.0;

    final rateBarGroups = keys.asMap().entries.map((e) {
      final rate = rateValues[e.key];
      return BarChartGroupData(x: e.key, barRods: [
        BarChartRodData(
          toY: rate,
          fromY: 0,
          color: (rate >= 0 ? Colors.amber : Colors.deepOrange).withAlpha(200),
          width: barWidth,
          borderRadius: BorderRadius.circular(3),
        ),
      ]);
    }).toList();

    const double leftSize = 64.0;
    const double bottomSize = 28.0;

    String axisLabel(double v) {
      final abs = v.abs();
      final sign = v >= 0 ? '+' : '-';
      if (abs >= 10000) return '$sign$sym${(abs / 1000).toStringAsFixed(0)}k';
      if (abs >= 1000) return '$sign$sym${(abs / 1000).toStringAsFixed(1)}k';
      return '$sign$sym${abs.toStringAsFixed(0)}';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text('Win Rate by Attribute',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ),
                _DropdownContainer(
                  child: DropdownButton<_WRAttr>(
                    value: availableAttrs.contains(_attr)
                        ? _attr
                        : availableAttrs.first,
                    isDense: true,
                    underline: const SizedBox.shrink(),
                    items: availableAttrs
                        .map((a) => DropdownMenuItem(
                              value: a,
                              child: Text(attrLabels[a]!,
                                  style: const TextStyle(fontSize: 13)),
                            ))
                        .toList(),
                    onChanged: (a) => setState(() => _attr = a!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 180,
              child: BarChart(BarChartData(
                barGroups: rateBarGroups,
                minY: rateMinY,
                maxY: rateMaxY,
                alignment: BarChartAlignment.spaceAround,
                barTouchData: BarTouchData(enabled: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (v) => FlLine(
                    color: v == 0 ? Colors.white38 : Colors.white12,
                    strokeWidth: v == 0 ? 1.5 : 0.5,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: leftSize,
                      getTitlesWidget: (v, _) => Text(
                        axisLabel(v),
                        style: const TextStyle(
                            fontSize: 9, color: Colors.amber),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: bottomSize,
                      getTitlesWidget: (v, meta) {
                        final i = v.toInt();
                        if (i < 0 || i >= keys.length) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(shortLabel(keys[i]),
                              style: const TextStyle(fontSize: 9),
                              textAlign: TextAlign.center),
                        );
                      },
                    ),
                  ),
                ),
              )),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Insight Cards ────────────────────────────────────────────────────────────

class _GroupStats {
  final double totalPL;
  final double avgPL;
  final int count;
  final double hourlyRate;
  final double totalHours;

  _GroupStats({
    required this.totalPL,
    required this.avgPL,
    required this.count,
    required this.hourlyRate,
    required this.totalHours,
  });

  factory _GroupStats.from(List<SessionModel> sessions, String displayCurrency) {
    double toD(double amount, String from) =>
        convertCurrency(amount, from, displayCurrency);
    final total =
        sessions.fold(0.0, (sum, s) => sum + toD(s.profitLoss, s.currency));
    final totalMinutes = sessions.fold(0, (s, e) => s + e.durationMinutes);
    final hours = totalMinutes / 60.0;
    return _GroupStats(
      totalPL: total,
      avgPL: total / sessions.length,
      count: sessions.length,
      hourlyRate: hours > 0 ? total / hours : 0,
      totalHours: hours,
    );
  }
}

class _InsightCard extends StatelessWidget {
  final String title;
  final List<SessionModel> sessions;
  final String Function(SessionModel) keyFn;
  final List<String>? orderedKeys;
  final String displayCurrency;

  const _InsightCard({
    required this.title,
    required this.sessions,
    required this.keyFn,
    required this.displayCurrency,
    this.orderedKeys,
  });

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<SessionModel>>{};
    for (final s in sessions) {
      groups.putIfAbsent(keyFn(s), () => []).add(s);
    }
    if (groups.length < 2) return const SizedBox.shrink();

    final stats =
        groups.map((k, v) => MapEntry(k, _GroupStats.from(v, displayCurrency)));

    List<String> keys;
    if (orderedKeys != null) {
      keys = orderedKeys!.where((k) => stats.containsKey(k)).toList();
      for (final k in stats.keys) {
        if (!keys.contains(k)) keys.add(k);
      }
    } else {
      keys = stats.keys.toList()
        ..sort((a, b) =>
            (stats[b]!.hourlyRate).compareTo(stats[a]!.hourlyRate));
    }

    final maxAbsHourly = stats.values
        .map((s) => s.hourlyRate.abs())
        .reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            for (final key in keys) ...[
              _InsightRow(
                label: key,
                stats: stats[key]!,
                maxAbsHourly: maxAbsHourly,
                displayCurrency: displayCurrency,
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  final String label;
  final _GroupStats stats;
  final double maxAbsHourly;
  final String displayCurrency;

  const _InsightRow({
    required this.label,
    required this.stats,
    required this.maxAbsHourly,
    required this.displayCurrency,
  });

  @override
  Widget build(BuildContext context) {
    final barColor = stats.hourlyRate >= 0 ? Colors.green : Colors.red;
    final barFraction = maxAbsHourly > 0
        ? (stats.hourlyRate.abs() / maxAbsHourly).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(label,
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis),
            ),
            Text('${stats.totalHours.toStringAsFixed(1)}h',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    )),
            const SizedBox(width: 8),
            Text(
              '${formatPLWithCurrency(stats.hourlyRate, displayCurrency)}/hr',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: barColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(width: 8),
            Text(
              formatPLWithCurrency(stats.totalPL, displayCurrency),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: stats.totalPL >= 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        LayoutBuilder(
          builder: (_, constraints) => Stack(
            children: [
              Container(
                height: 4,
                width: constraints.maxWidth,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Container(
                height: 4,
                width: constraints.maxWidth * barFraction,
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────

class _ChartCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _ChartCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(height: 180, child: child),
          ],
        ),
      ),
    );
  }
}

Widget _emptyChart(String message) => Center(
      child: Text(message,
          style: const TextStyle(color: Colors.white38, fontSize: 13)),
    );

// ─── Recommendations (Welch's t-test, actionable) ─────────────────────────────

class _Rec {
  final IconData icon;
  final String title;
  final String explanation;
  final double tStat;

  _Rec({
    required this.icon,
    required this.title,
    required this.explanation,
    required this.tStat,
  });
}

class _RecommendationsCard extends StatelessWidget {
  final List<SessionModel> sessions;
  final String typeLabel;
  final String displayCurrency;

  const _RecommendationsCard({
    required this.sessions,
    required String gameTypeLabel,
    required this.displayCurrency,
  }) : typeLabel = gameTypeLabel;

  @override
  Widget build(BuildContext context) {
    final recs = _buildRecommendations();
    if (recs.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Log at least 5 $typeLabel sessions to get personalised recommendations.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Based on your session history',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
            const SizedBox(height: 12),
            for (int i = 0; i < recs.length; i++) ...[
              if (i > 0) const Divider(height: 20),
              _RecRow(rec: recs[i]),
            ],
          ],
        ),
      ),
    );
  }

  double _sessionRate(SessionModel s) {
    final hours = s.durationMinutes / 60.0;
    if (hours <= 0) return 0;
    return convertCurrency(s.profitLoss, s.currency, displayCurrency) / hours;
  }

  double _welchT(List<double> a, List<double> b) {
    if (a.length < 2 || b.length < 2) return 0;
    final meanA = a.reduce((x, y) => x + y) / a.length;
    final meanB = b.reduce((x, y) => x + y) / b.length;
    final varA = a
            .map((x) => (x - meanA) * (x - meanA))
            .reduce((x, y) => x + y) /
        (a.length - 1);
    final varB = b
            .map((x) => (x - meanB) * (x - meanB))
            .reduce((x, y) => x + y) /
        (b.length - 1);
    final se = math.sqrt(varA / a.length + varB / b.length);
    if (se == 0) return 0;
    return (meanA - meanB) / se;
  }

  String _actionTitle(
      String dimension, String bestKey, String worstKey, double bestRate) {
    switch (dimension) {
      case 'time slot':
        return bestRate > 0
            ? 'Schedule more sessions in the $bestKey'
            : 'Shift sessions away from $worstKey';
      case 'day':
        return 'Prioritise $bestKey sessions';
      case 'session length':
        return 'Target $bestKey sessions';
      case 'table quality':
        return 'Seek out $bestKey tables';
      case 'location':
        return '$bestKey is your strongest venue';
      case 'game type':
        return 'Focus more on ${bestKey.toLowerCase()}';
      default:
        return 'Favour $bestKey over $worstKey';
    }
  }

  List<_Rec> _buildRecommendations() {
    if (sessions.length < 5) return [];

    final recs = <_Rec>[];
    final overallRates = sessions.map(_sessionRate).toList();
    final overallMean =
        overallRates.reduce((a, b) => a + b) / overallRates.length;

    void checkFactor({
      required String? Function(SessionModel) keyFn,
      required IconData icon,
      required String dimension,
      bool cashOnly = false,
    }) {
      final src = cashOnly
          ? sessions.where((s) => s.gameType == 'cash').toList()
          : sessions;
      if (src.length < 4) return;

      final grouped = <String, List<SessionModel>>{};
      for (final s in src) {
        final k = keyFn(s);
        if (k == null || k.isEmpty) continue;
        grouped.putIfAbsent(k, () => []).add(s);
      }

      final qualified = grouped.entries
          .where((e) => e.value.length >= 2)
          .map((e) {
            final rates = e.value.map(_sessionRate).toList();
            return (
              key: e.key,
              rates: rates,
              mean: rates.reduce((a, b) => a + b) / rates.length,
            );
          })
          .toList()
        ..sort((a, b) => b.mean.compareTo(a.mean));

      if (qualified.length < 2) return;

      final best = qualified.first;
      final worst = qualified.last;

      final restSessions = src
          .where((s) {
            final k = keyFn(s);
            return k != null && k != best.key;
          })
          .toList();
      if (restSessions.length < 2) return;

      final restRates = restSessions.map(_sessionRate).toList();
      final tStat = _welchT(best.rates, restRates);
      if (tStat < 1.8) return;

      final bestFmt = formatPLWithCurrency(best.mean, displayCurrency);
      final worstFmt = formatPLWithCurrency(worst.mean, displayCurrency);
      final overallFmt = formatPLWithCurrency(overallMean, displayCurrency);
      final diff = best.mean - worst.mean;
      final diffFmt = formatPLWithCurrency(diff, displayCurrency);

      recs.add(_Rec(
        icon: icon,
        title: _actionTitle(dimension, best.key, worst.key, best.mean),
        explanation: '$bestFmt/hr in ${best.key} sessions'
            '${diff > 0 ? ' — $diffFmt/hr more than ${worst.key} ($worstFmt/hr)' : ''}.'
            ' Your overall rate is $overallFmt/hr.',
        tStat: tStat,
      ));
    }

    checkFactor(
      keyFn: (s) => _shortTime(timeOfDayBucket(s.startTime)),
      icon: Icons.access_time,
      dimension: 'time slot',
    );
    checkFactor(
      keyFn: (s) => dayOfWeekLabel(s.date),
      icon: Icons.calendar_today,
      dimension: 'day',
    );
    checkFactor(
      keyFn: (s) => sessionLengthBucket(s.durationMinutes),
      icon: Icons.timer_outlined,
      dimension: 'session length',
    );
    checkFactor(
      keyFn: (s) => s.tableQuality != null ? '${s.tableQuality}★' : null,
      icon: Icons.star_border,
      dimension: 'table quality',
      cashOnly: true,
    );
    checkFactor(
      keyFn: (s) => s.location?.isNotEmpty == true ? s.location : null,
      icon: Icons.location_on_outlined,
      dimension: 'location',
    );
    if (sessions.any((s) => s.gameType == 'cash') &&
        sessions.any((s) => isTournamentType(s.gameType))) {
      checkFactor(
        keyFn: (s) => gameTypeLabel(s.gameType),
        icon: Icons.casino_outlined,
        dimension: 'game type',
      );
    }

    recs.sort((a, b) => b.tStat.compareTo(a.tStat));
    final top = recs.take(4).toList();

    if (sessions.length < 20) {
      top.add(_Rec(
        icon: Icons.trending_up,
        title: 'Keep building your sample size',
        explanation:
            'You have ${sessions.length} $typeLabel sessions. Patterns become more reliable and actionable at 20+ sessions.',
        tStat: 0,
      ));
    }

    return top;
  }

  String _shortTime(String? bucket) {
    if (bucket == null) return '';
    if (bucket.startsWith('Morning')) return 'Morning';
    if (bucket.startsWith('Afternoon')) return 'Afternoon';
    if (bucket.startsWith('Evening')) return 'Evening';
    return 'Late Night';
  }
}

class _RecRow extends StatelessWidget {
  final _Rec rec;
  const _RecRow({required this.rec});

  @override
  Widget build(BuildContext context) {
    final iconColor = rec.tStat >= 3.0
        ? Colors.green
        : rec.tStat >= 2.0
            ? Colors.amber
            : Theme.of(context).colorScheme.onSurface;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(rec.icon, size: 20, color: iconColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(rec.title,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 3),
              Text(
                rec.explanation,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withAlpha(180),
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
