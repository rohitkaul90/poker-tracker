import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/poker_rooms.dart';
import '../models/session_model.dart';
import '../providers/providers.dart';
import '../utils/helpers.dart';

class AnalyticsScreen extends ConsumerWidget {
  final String? venueFilter;
  final String? countryFilter;
  final String? locationFilter;
  final String? displayCurrency;
  final String? dateFilter;

  const AnalyticsScreen({
    super.key,
    this.venueFilter,
    this.countryFilter,
    this.locationFilter,
    this.displayCurrency,
    this.dateFilter,
  });

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
        return _AnalyticsBody(
          sessions: sessions,
          venueFilter: venueFilter,
          countryFilter: countryFilter,
          locationFilter: locationFilter,
          displayCurrency: displayCurrency,
          dateFilter: dateFilter,
        );
      },
    );
  }
}

class _AnalyticsBody extends StatefulWidget {
  final List<SessionModel> sessions;
  final String? venueFilter;
  final String? countryFilter;
  final String? locationFilter;
  final String? displayCurrency;
  final String? dateFilter;

  const _AnalyticsBody({
    required this.sessions,
    this.venueFilter,
    this.countryFilter,
    this.locationFilter,
    this.displayCurrency,
    this.dateFilter,
  });

  @override
  State<_AnalyticsBody> createState() => _AnalyticsBodyState();
}

class _AnalyticsBodyState extends State<_AnalyticsBody> {
  String? _gameFilter;
  bool _recsExpanded = false;

  String get _effectiveCurrency {
    if (widget.displayCurrency != null) return widget.displayCurrency!;
    if (widget.sessions.isEmpty) return 'CAD';
    final sorted = [...widget.sessions]
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.first.currency;
  }

  List<SessionModel> get _filtered {
    var result = widget.sessions;
    if (widget.dateFilter != null) {
      final days = switch (widget.dateFilter!) {
        '1M' => 30,
        '3M' => 90,
        '6M' => 180,
        '1Y' => 365,
        _ => 0,
      };
      if (days > 0) {
        final cutoff = DateTime.now().subtract(Duration(days: days));
        result =
            result.where((s) => DateTime.parse(s.date).isAfter(cutoff)).toList();
      }
    }
    if (widget.countryFilter != null) {
      result = result.where((s) => s.country == widget.countryFilter).toList();
    }
    if (_gameFilter != null) {
      if (_gameFilter == 'tournament') {
        result = result.where((s) => isTournamentType(s.gameType)).toList();
      } else {
        result = result.where((s) => s.gameType == 'cash').toList();
      }
    }
    if (widget.venueFilter == 'online') {
      result = result.where((s) => isOnlineSession(s.location)).toList();
    } else if (widget.venueFilter == 'live') {
      result = result.where((s) => !isOnlineSession(s.location)).toList();
    }
    if (widget.locationFilter != null) {
      result =
          result.where((s) => s.location == widget.locationFilter).toList();
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

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
      children: [
        // ── Game-type chip strip ───────────────────────────────────────────
        if (_hasCash && _hasTournament) ...[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final entry in [
                  (null, 'All'),
                  ('cash', 'Cash'),
                  ('tournament', 'Tournament'),
                ])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(entry.$2),
                      selected: _gameFilter == entry.$1,
                      onSelected: (_) =>
                          setState(() => _gameFilter = entry.$1),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],

        if (filtered.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: Text('No sessions match this filter.')),
          )
        else ...[
          _StatsCard(sessions: filtered, displayCurrency: displayCurrency),
          const SizedBox(height: 16),

          // Recommendations (collapsible)
          InkWell(
            onTap: () => setState(() => _recsExpanded = !_recsExpanded),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(child: _sectionHeader(context, 'Recommendations')),
                  Icon(
                    _recsExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ],
              ),
            ),
          ),
          if (_recsExpanded) ...[
            const SizedBox(height: 8),
            if (_gameFilter == null && showingCash && showingTournaments) ...[
              _RecommendationsCard(
                sessions: filtered.where((s) => s.gameType == 'cash').toList(),
                gameTypeLabel: 'cash',
                displayCurrency: displayCurrency,
              ),
              const SizedBox(height: 8),
              _RecommendationsCard(
                sessions: filtered
                    .where((s) => isTournamentType(s.gameType))
                    .toList(),
                gameTypeLabel: 'tournament',
                displayCurrency: displayCurrency,
              ),
            ] else if (showingCash)
              _RecommendationsCard(
                sessions: filtered.where((s) => s.gameType == 'cash').toList(),
                gameTypeLabel: 'cash',
                displayCurrency: displayCurrency,
              )
            else if (showingTournaments)
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

enum _PLMode { cumulative, weekly, monthly, yearly }

enum _Lookback { all, oneYear, sixMonths, threeMonths, oneMonth }

class _PLChart extends StatefulWidget {
  final List<SessionModel> sessions;
  final String displayCurrency;
  const _PLChart({required this.sessions, required this.displayCurrency});

  @override
  State<_PLChart> createState() => _PLChartState();
}

class _PLChartState extends State<_PLChart> {
  _PLMode _mode = _PLMode.cumulative;
  _Lookback _lookback = _Lookback.all;
  final Set<String> _expandedYears = {DateTime.now().year.toString()};

  double _toD(double amount, String from) =>
      convertCurrency(amount, from, widget.displayCurrency);

  List<SessionModel> get _lookbackSessions {
    if (_lookback == _Lookback.all) return widget.sessions;
    final now = DateTime.now();
    final days = switch (_lookback) {
      _Lookback.oneMonth => 30,
      _Lookback.threeMonths => 90,
      _Lookback.sixMonths => 180,
      _Lookback.oneYear => 365,
      _Lookback.all => 0,
    };
    final cutoff = now.subtract(Duration(days: days));
    return widget.sessions
        .where((s) => DateTime.parse(s.date).isAfter(cutoff))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final sym = currencySymbol(widget.displayCurrency);
    const modeLabels = {
      _PLMode.cumulative: 'Cumulative',
      _PLMode.weekly: 'Weekly',
      _PLMode.monthly: 'Monthly',
      _PLMode.yearly: 'Yearly',
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('P&L Over Time',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            // Mode toggle
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _PLMode.values
                    .map((mode) => Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            label: Text(modeLabels[mode]!,
                                style: const TextStyle(fontSize: 11)),
                            selected: _mode == mode,
                            onSelected: (_) => setState(() => _mode = mode),
                            visualDensity: VisualDensity.compact,
                          ),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 12),
            if (_mode == _PLMode.cumulative) ...[
              // Lookback period selector
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final entry in [
                      (_Lookback.all, 'All'),
                      (_Lookback.oneYear, '1Y'),
                      (_Lookback.sixMonths, '6M'),
                      (_Lookback.threeMonths, '3M'),
                      (_Lookback.oneMonth, '1M'),
                    ])
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(entry.$2,
                              style: const TextStyle(fontSize: 11)),
                          selected: _lookback == entry.$1,
                          onSelected: (_) =>
                              setState(() => _lookback = entry.$1),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(height: 180, child: _buildCumulative(context, sym)),
            ] else
              _buildTable(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCumulative(BuildContext context, String sym) {
    final sessions = _lookbackSessions;
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
    const ms = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
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
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (_) => Colors.black87,
          getTooltipItems: (spots) => spots.map((spot) {
            final idx = spot.x.toInt().clamp(0, sessions.length - 1);
            final date = DateTime.parse(sessions[idx].date);
            final label = '${ms[date.month - 1]} ${date.day}, ${date.year}';
            final sign = spot.y >= 0 ? '+' : '-';
            return LineTooltipItem(
              '$label\n$sign$sym${spot.y.abs().toStringAsFixed(0)}',
              const TextStyle(color: Colors.white, fontSize: 11, height: 1.4),
            );
          }).toList(),
        ),
      ),
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

  Widget _buildTable(BuildContext context) {
    final sym = currencySymbol(widget.displayCurrency);
    final theme = Theme.of(context);
    final headerStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.outline,
      fontWeight: FontWeight.bold,
    );

    final header = Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text('Period', style: headerStyle)),
          Expanded(
              flex: 2,
              child: Text('P&L ($sym)',
                  style: headerStyle, textAlign: TextAlign.right)),
          Expanded(
              flex: 1,
              child: Text('#',
                  style: headerStyle, textAlign: TextAlign.right)),
          Expanded(
              flex: 2,
              child: Text('$sym/hr',
                  style: headerStyle, textAlign: TextAlign.right)),
          Expanded(
              flex: 2,
              child: Text('Hrs',
                  style: headerStyle, textAlign: TextAlign.right)),
        ],
      ),
    );

    if (_mode == _PLMode.yearly) {
      return _buildFlatTable(context, header, theme);
    }
    return _buildNestedTable(context, header, theme);
  }

  Widget _buildFlatTable(
      BuildContext context, Widget header, ThemeData theme) {
    final periodMap = <String, ({double pl, int count, double hours})>{};
    for (final s in widget.sessions) {
      final key = _periodKey(s.date);
      final pl = _toD(s.profitLoss, s.currency);
      final hours = s.durationMinutes / 60.0;
      final existing = periodMap[key];
      if (existing == null) {
        periodMap[key] = (pl: pl, count: 1, hours: hours);
      } else {
        periodMap[key] = (
          pl: existing.pl + pl,
          count: existing.count + 1,
          hours: existing.hours + hours,
        );
      }
    }
    final entries = periodMap.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));
    if (entries.isEmpty) {
      return const Center(
          child: Text('No data', style: TextStyle(color: Colors.white38)));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header,
        const Divider(height: 1),
        for (final e in entries) ...[
          _tableDataRow(context, _periodLabel(e.key), e.value, theme),
          const Divider(height: 1, color: Colors.white10),
        ],
      ],
    );
  }

  Widget _buildNestedTable(
      BuildContext context, Widget header, ThemeData theme) {
    final byYear =
        <String, Map<String, ({double pl, int count, double hours})>>{};
    for (final s in widget.sessions) {
      final year = s.date.substring(0, 4);
      final key = _periodKey(s.date);
      final pl = _toD(s.profitLoss, s.currency);
      final hours = s.durationMinutes / 60.0;
      byYear.putIfAbsent(year, () => {});
      final existing = byYear[year]![key];
      if (existing == null) {
        byYear[year]![key] = (pl: pl, count: 1, hours: hours);
      } else {
        byYear[year]![key] = (
          pl: existing.pl + pl,
          count: existing.count + 1,
          hours: existing.hours + hours,
        );
      }
    }
    final years = byYear.keys.toList()..sort((a, b) => b.compareTo(a));
    if (years.isEmpty) {
      return const Center(
          child: Text('No data', style: TextStyle(color: Colors.white38)));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header,
        const Divider(height: 1),
        for (final year in years)
          _buildYearSection(context, year, byYear[year]!, theme),
      ],
    );
  }

  Widget _buildYearSection(
    BuildContext context,
    String year,
    Map<String, ({double pl, int count, double hours})> periods,
    ThemeData theme,
  ) {
    double yearPL = 0;
    int yearCount = 0;
    double yearHours = 0;
    for (final p in periods.values) {
      yearPL += p.pl;
      yearCount += p.count;
      yearHours += p.hours;
    }
    final yearRate = yearHours > 0 ? yearPL / yearHours : 0.0;
    final plColor = yearPL >= 0 ? Colors.green : Colors.red;
    final rateColor = yearRate >= 0 ? Colors.green : Colors.red;
    final isExpanded = _expandedYears.contains(year);

    final sortedPeriods = periods.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() {
            if (isExpanded) {
              _expandedYears.remove(year);
            } else {
              _expandedYears.add(year);
            }
          }),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: theme.colorScheme.surfaceContainerHighest.withAlpha(60),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        size: 16,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(width: 4),
                      Text(year,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(_fmtNum(yearPL),
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: plColor, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.right),
                ),
                Expanded(
                  flex: 1,
                  child: Text('$yearCount',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.outline),
                      textAlign: TextAlign.right),
                ),
                Expanded(
                  flex: 2,
                  child: Text(_fmtNum(yearRate),
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: rateColor, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.right),
                ),
                Expanded(
                  flex: 2,
                  child: Text(yearHours.toStringAsFixed(0),
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.outline),
                      textAlign: TextAlign.right),
                ),
              ],
            ),
          ),
        ),
        if (isExpanded)
          for (final e in sortedPeriods) ...[
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: _tableDataRow(context, _periodLabel(e.key), e.value, theme),
            ),
            const Divider(height: 1, color: Colors.white10),
          ],
      ],
    );
  }

  Widget _tableDataRow(
    BuildContext context,
    String label,
    ({double pl, int count, double hours}) data,
    ThemeData theme,
  ) {
    final plColor = data.pl >= 0 ? Colors.green : Colors.red;
    final hourlyRate = data.hours > 0 ? data.pl / data.hours : 0.0;
    final rateColor = hourlyRate >= 0 ? Colors.green : Colors.red;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(label, style: theme.textTheme.bodySmall),
          ),
          Expanded(
            flex: 2,
            child: Text(_fmtNum(data.pl),
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: plColor, fontWeight: FontWeight.bold),
                textAlign: TextAlign.right),
          ),
          Expanded(
            flex: 1,
            child: Text('${data.count}',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.outline),
                textAlign: TextAlign.right),
          ),
          Expanded(
            flex: 2,
            child: Text(_fmtNum(hourlyRate),
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: rateColor, fontWeight: FontWeight.bold),
                textAlign: TextAlign.right),
          ),
          Expanded(
            flex: 2,
            child: Text(data.hours.toStringAsFixed(0),
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.outline),
                textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }

  String _fmtNum(double v) {
    final sign = v >= 0 ? '+' : '-';
    final str = v.abs().round().toString();
    final buf = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buf.write(',');
      buf.write(str[i]);
    }
    return '$sign$buf';
  }

  String _periodKey(String dateStr) {
    return switch (_mode) {
      _PLMode.weekly => _weekKey(dateStr),
      _PLMode.monthly => dateStr.substring(0, 7),
      _PLMode.yearly => dateStr.substring(0, 4),
      _PLMode.cumulative => dateStr,
    };
  }

  String _weekKey(String dateStr) {
    final date = DateTime.parse(dateStr);
    final monday = date.subtract(Duration(days: date.weekday - 1));
    return '${monday.year}-${monday.month.toString().padLeft(2, '0')}-${monday.day.toString().padLeft(2, '0')}';
  }

  String _periodLabel(String key) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    switch (_mode) {
      case _PLMode.weekly:
        final date = DateTime.parse(key);
        return 'Wk ${months[date.month - 1]} ${date.day}';
      case _PLMode.monthly:
        final parts = key.split('-');
        return "${months[int.parse(parts[1]) - 1]} '${parts[0].substring(2)}";
      case _PLMode.yearly:
        return key;
      default:
        return key;
    }
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

// ─── Shared ───────────────────────────────────────────────────────────────────

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

// ─── Analytics filter bottom sheet ───────────────────────────────────────────

class AnalyticsFilterSheet extends StatefulWidget {
  final String displayCurrency;
  final String? countryFilter;
  final String? venueFilter;
  final String? locationFilter;
  final String? dateFilter;
  final List<String> allCountries;
  final bool hasMultipleCountries;
  final bool hasOnline;
  final bool hasLive;
  final List<String> allLocations;
  final void Function(String? currency, String? country, String? venue,
      String? location, String? date) onApply;
  final VoidCallback onReset;

  const AnalyticsFilterSheet({
    super.key,
    required this.displayCurrency,
    required this.countryFilter,
    required this.venueFilter,
    required this.locationFilter,
    required this.dateFilter,
    required this.allCountries,
    required this.hasMultipleCountries,
    required this.hasOnline,
    required this.hasLive,
    required this.allLocations,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<AnalyticsFilterSheet> createState() => _AnalyticsFilterSheetState();
}

class _AnalyticsFilterSheetState extends State<AnalyticsFilterSheet> {
  late String _currency;
  late String? _country;
  late String? _venue;
  late String? _location;
  late String? _date;

  @override
  void initState() {
    super.initState();
    _currency = widget.displayCurrency;
    _country = widget.countryFilter;
    _venue = widget.venueFilter;
    _location = widget.locationFilter;
    _date = widget.dateFilter;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      maxChildSize: 0.9,
      builder: (context, scroll) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: ListView(
          controller: scroll,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text('Display Options', style: theme.textTheme.titleLarge),
            const SizedBox(height: 20),

            // Date Range
            Text('Date Range', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final entry in [
                  (null, 'All Time'),
                  ('1Y', '1 Year'),
                  ('6M', '6 Months'),
                  ('3M', '3 Months'),
                  ('1M', '1 Month'),
                ])
                  ChoiceChip(
                    label: Text(entry.$2),
                    selected: _date == entry.$1,
                    onSelected: (_) => setState(() => _date = entry.$1),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // Currency
            Text('Currency', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: supportedDisplayCurrencies
                  .map((c) => ChoiceChip(
                        label: Text('$c ${currencySymbol(c)}'),
                        selected: _currency == c,
                        onSelected: (_) => setState(() => _currency = c),
                      ))
                  .toList(),
            ),

            // Country (only if multiple)
            if (widget.hasMultipleCountries) ...[
              const SizedBox(height: 20),
              Text('Country', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilterChip(
                    label: const Text('All Countries'),
                    selected: _country == null,
                    onSelected: (_) => setState(() => _country = null),
                  ),
                  ...widget.allCountries.map((c) => FilterChip(
                        label: Text(c),
                        selected: _country == c,
                        onSelected: (on) =>
                            setState(() => _country = on ? c : null),
                      )),
                ],
              ),
            ],

            // Venue (only if both live and online exist)
            if (widget.hasLive && widget.hasOnline) ...[
              const SizedBox(height: 20),
              Text('Venue', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final entry in [
                    (null, 'All Venues'),
                    ('live', 'Live'),
                    ('online', 'Online'),
                  ])
                    ChoiceChip(
                      label: Text(entry.$2),
                      selected: _venue == entry.$1,
                      onSelected: (_) => setState(() => _venue = entry.$1),
                    ),
                ],
              ),
            ],

            // Location (only if multiple locations exist)
            if (widget.allLocations.length > 1) ...[
              const SizedBox(height: 20),
              Text('Location', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilterChip(
                    label: const Text('All Locations'),
                    selected: _location == null,
                    onSelected: (_) => setState(() => _location = null),
                  ),
                  ...widget.allLocations.map((l) => FilterChip(
                        label: Text(l),
                        selected: _location == l,
                        onSelected: (on) =>
                            setState(() => _location = on ? l : null),
                      )),
                ],
              ),
            ],

            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      widget.onReset();
                      Navigator.pop(context);
                    },
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      widget.onApply(_currency, _country, _venue, _location, _date);
                      Navigator.pop(context);
                    },
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Recommendation rows ──────────────────────────────────────────────────────

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
