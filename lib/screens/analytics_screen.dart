import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/poker_rooms.dart';
import '../database/database.dart';
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
  final List<Session> sessions;

  const _AnalyticsBody({required this.sessions});

  @override
  State<_AnalyticsBody> createState() => _AnalyticsBodyState();
}

class _AnalyticsBodyState extends State<_AnalyticsBody> {
  String? _gameFilter;     // null | 'cash' | 'tournament'
  String? _venueFilter;    // null | 'live' | 'online'
  String? _currencyFilter; // null | 'CAD' | 'USD' | ...

  List<Session> get _filtered {
    var result = widget.sessions;
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
    if (_currencyFilter != null) {
      result = result.where((s) => s.currency == _currencyFilter).toList();
    }
    return result;
  }

  List<Session> get _sorted =>
      [..._filtered]..sort((a, b) => a.date.compareTo(b.date));

  bool get _hasCash => widget.sessions.any((s) => s.gameType == 'cash');
  bool get _hasTournament =>
      widget.sessions.any((s) => isTournamentType(s.gameType));
  bool get _hasOnline =>
      widget.sessions.any((s) => isOnlineSession(s.location));
  bool get _hasLive =>
      widget.sessions.any((s) => !isOnlineSession(s.location));
  Set<String> get _allCurrencies =>
      widget.sessions.map((s) => s.currency).toSet();

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final sorted = _sorted;
    final showingTournaments =
        filtered.any((s) => isTournamentType(s.gameType));
    final showingCash = filtered.any((s) => s.gameType == 'cash');

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
      children: [
        // Game type filter chips
        _GameTypeFilterChips(
          value: _gameFilter,
          hasCash: _hasCash,
          hasTournament: _hasTournament,
          onChanged: (v) => setState(() => _gameFilter = v),
        ),

        // Venue filter chips (only if both live and online sessions exist)
        if (_hasOnline && _hasLive) ...[
          const SizedBox(height: 6),
          _VenueFilterChips(
            value: _venueFilter,
            onChanged: (v) => setState(() => _venueFilter = v),
          ),
        ],

        // Currency filter chips (only if multiple currencies in data)
        if (_allCurrencies.length > 1) ...[
          const SizedBox(height: 6),
          _CurrencyFilterChips(
            currencies: _allCurrencies,
            value: _currencyFilter,
            onChanged: (v) => setState(() => _currencyFilter = v),
          ),
        ],
        const SizedBox(height: 12),

        if (filtered.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: Text('No sessions match this filter.')),
          )
        else ...[
          // Summary stats card
          _StatsCard(sessions: filtered),
          const SizedBox(height: 16),

          // Recommendations — separate cards per game type
          if (_gameFilter == null && showingCash && showingTournaments) ...[
            _sectionHeader(context, 'Cash Game Recommendations'),
            const SizedBox(height: 8),
            _RecommendationsCard(
              sessions: filtered.where((s) => s.gameType == 'cash').toList(),
              gameTypeLabel: 'cash',
            ),
            const SizedBox(height: 16),
            _sectionHeader(context, 'Tournament Recommendations'),
            const SizedBox(height: 8),
            _RecommendationsCard(
              sessions: filtered
                  .where((s) => isTournamentType(s.gameType))
                  .toList(),
              gameTypeLabel: 'tournament',
            ),
          ] else if (showingCash) ...[
            _sectionHeader(context, 'Recommendations'),
            const SizedBox(height: 8),
            _RecommendationsCard(
              sessions: filtered.where((s) => s.gameType == 'cash').toList(),
              gameTypeLabel: 'cash',
            ),
          ] else if (showingTournaments) ...[
            _sectionHeader(context, 'Recommendations'),
            const SizedBox(height: 8),
            _RecommendationsCard(
              sessions: filtered
                  .where((s) => isTournamentType(s.gameType))
                  .toList(),
              gameTypeLabel: 'tournament',
            ),
          ],
          const SizedBox(height: 20),

          _sectionHeader(context, 'Charts'),
          const SizedBox(height: 8),

          // P&L chart with cumulative/monthly/yearly toggle
          _PLChart(sessions: sorted, currencyFilter: _currencyFilter),
          const SizedBox(height: 12),

          // Win rate by attribute (interactive)
          _WinRateByAttributeChart(
            sessions: filtered,
            hasLiveAndOnline: _hasLive && _hasOnline,
          ),
          const SizedBox(height: 20),

          _sectionHeader(context, "What's Affecting Your Win Rate"),
          Text(
            'hrs  ·  \$/hr  ·  P&L',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: 8),

          // By Stakes — cash only
          if (showingCash) ...[
            _InsightCard(
              title: 'By Stakes',
              sessions: filtered.where((s) => s.gameType == 'cash').toList(),
              keyFn: (s) => s.stakes,
            ),
            const SizedBox(height: 8),
          ],

          // By Buy-in Level — tournaments only
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
            ),
            const SizedBox(height: 8),
          ],

          // By Game Type — only when showing both
          if (_gameFilter == null && _hasCash && _hasTournament) ...[
            _InsightCard(
              title: 'By Game Type',
              sessions: filtered,
              keyFn: (s) => gameTypeLabel(s.gameType),
            ),
            const SizedBox(height: 8),
          ],

          _InsightCard(
            title: 'By Day of Week',
            sessions: filtered,
            keyFn: (s) => dayOfWeekLabel(s.date),
            orderedKeys: const [
              'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
            ],
          ),
          const SizedBox(height: 8),
          _InsightCard(
            title: 'By Time of Day',
            sessions: filtered,
            keyFn: (s) => timeOfDayBucket(s.startTime),
          ),
          const SizedBox(height: 8),
          _InsightCard(
            title: 'By Session Length',
            sessions: filtered,
            keyFn: (s) => sessionLengthBucket(s.durationMinutes),
            orderedKeys: const [
              '< 2 hours', '2–4 hours', '4–6 hours', '> 6 hours'
            ],
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
            ),
          ],
          if (_hasMultipleLocations(filtered)) ...[
            const SizedBox(height: 8),
            _InsightCard(
              title: 'By Location',
              sessions:
                  filtered.where((s) => s.location?.isNotEmpty == true).toList(),
              keyFn: (s) => s.location!,
            ),
          ],
          if (_hasLive && _hasOnline) ...[
            const SizedBox(height: 8),
            _InsightCard(
              title: 'Live vs Online',
              sessions: filtered,
              keyFn: (s) => isOnlineSession(s.location) ? 'Online' : 'Live',
              orderedKeys: const ['Live', 'Online'],
            ),
          ],
          const SizedBox(height: 8),
          _InsightCard(
            title: 'By Month',
            sessions: filtered,
            keyFn: (s) => monthLabel(s.date),
          ),
        ],
      ],
    );
  }

  bool _hasMultipleLocations(List<Session> sessions) {
    final locs = sessions
        .map((s) => s.location)
        .whereType<String>()
        .where((l) => l.isNotEmpty)
        .toSet();
    return locs.length > 1;
  }

  Widget _sectionHeader(BuildContext context, String title) => Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      );
}

// ─── Game Type Filter Chips ───────────────────────────────────────────────────

class _GameTypeFilterChips extends StatelessWidget {
  final String? value;
  final bool hasCash;
  final bool hasTournament;
  final ValueChanged<String?> onChanged;

  const _GameTypeFilterChips({
    required this.value,
    required this.hasCash,
    required this.hasTournament,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        FilterChip(
          label: const Text('All'),
          selected: value == null,
          onSelected: (_) => onChanged(null),
        ),
        if (hasCash)
          FilterChip(
            label: const Text('Cash'),
            selected: value == 'cash',
            onSelected: (_) => onChanged(value == 'cash' ? null : 'cash'),
          ),
        if (hasTournament)
          FilterChip(
            label: const Text('Tournament'),
            selected: value == 'tournament',
            onSelected: (_) =>
                onChanged(value == 'tournament' ? null : 'tournament'),
          ),
      ],
    );
  }
}

// ─── Venue Filter Chips ───────────────────────────────────────────────────────

class _VenueFilterChips extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;

  const _VenueFilterChips({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        FilterChip(
          label: const Text('All Venues'),
          selected: value == null,
          onSelected: (_) => onChanged(null),
        ),
        FilterChip(
          label: const Text('Live'),
          selected: value == 'live',
          onSelected: (_) => onChanged(value == 'live' ? null : 'live'),
        ),
        FilterChip(
          label: const Text('Online'),
          selected: value == 'online',
          onSelected: (_) => onChanged(value == 'online' ? null : 'online'),
        ),
      ],
    );
  }
}

// ─── Currency Filter Chips ────────────────────────────────────────────────────

class _CurrencyFilterChips extends StatelessWidget {
  final Set<String> currencies;
  final String? value;
  final ValueChanged<String?> onChanged;

  const _CurrencyFilterChips({
    required this.currencies,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final sorted = currencies.toList()..sort();
    return Wrap(
      spacing: 8,
      children: [
        FilterChip(
          label: const Text('All Currencies'),
          selected: value == null,
          onSelected: (_) => onChanged(null),
        ),
        for (final c in sorted)
          FilterChip(
            label: Text('$c (${currencySymbol(c)})'),
            selected: value == c,
            onSelected: (_) => onChanged(value == c ? null : c),
          ),
      ],
    );
  }
}

// ─── Summary Stats Card ───────────────────────────────────────────────────────

class _StatsCard extends StatelessWidget {
  final List<Session> sessions;

  const _StatsCard({required this.sessions});

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) return const SizedBox.shrink();

    final currencies = sessions.map((s) => s.currency).toSet();
    final isMultiCurrency = currencies.length > 1;

    final count = sessions.length;
    final totalHours =
        sessions.fold(0, (s, e) => s + e.durationMinutes) / 60.0;

    final tSessions =
        sessions.where((s) => isTournamentType(s.gameType)).toList();
    final hasTournaments = tSessions.isNotEmpty;
    final avgROI = hasTournaments
        ? tSessions.fold(
                0.0,
                (sum, s) =>
                    sum +
                    (s.buyIn > 0 ? s.profitLoss / s.buyIn * 100 : 0.0)) /
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
            Text(
              'Summary',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (isMultiCurrency) ...[
              // Multi-currency: show sessions + hours, then per-currency P&L
              Wrap(
                spacing: 24,
                runSpacing: 12,
                children: [
                  _StatItem(label: 'Sessions', value: '$count'),
                  _StatItem(
                      label: 'Hours',
                      value: '${totalHours.toStringAsFixed(1)}h'),
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
              const SizedBox(height: 12),
              Text(
                'P&L by currency',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
              const SizedBox(height: 6),
              // Per-currency P&L rows
              ...(() {
                final byCurrency = <String, ({double pl, double hours})>{};
                for (final s in sessions) {
                  final cur = s.currency;
                  final existing = byCurrency[cur];
                  byCurrency[cur] = (
                    pl: (existing?.pl ?? 0) + s.profitLoss,
                    hours: (existing?.hours ?? 0) + s.durationMinutes / 60.0,
                  );
                }
                final sorted = byCurrency.entries.toList()
                  ..sort((a, b) => a.key.compareTo(b.key));
                return sorted.map((e) {
                  final sym = currencySymbol(e.key);
                  final pl = e.value.pl;
                  final hrs = e.value.hours;
                  final rate = hrs > 0 ? pl / hrs : 0.0;
                  final color = pl >= 0 ? Colors.green : Colors.red;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 44,
                          child: Text(e.key,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline)),
                        ),
                        Text(
                          pl >= 0
                              ? '+$sym${pl.toStringAsFixed(0)}'
                              : '-$sym${pl.abs().toStringAsFixed(0)}',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                  fontWeight: FontWeight.bold, color: color),
                        ),
                        if (hrs > 0) ...[
                          const SizedBox(width: 8),
                          Text(
                            '(${formatPL(rate)}/hr)',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: color),
                          ),
                        ],
                      ],
                    ),
                  );
                });
              })(),
              const SizedBox(height: 4),
              Text(
                'Select a currency above to see combined stats.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                      fontSize: 10,
                    ),
              ),
            ] else ...[
              // Single currency: current full summary
              Builder(builder: (context) {
                final totalPL =
                    sessions.fold(0.0, (s, e) => s + e.profitLoss);
                final hourlyRate =
                    totalHours > 0 ? totalPL / totalHours : 0.0;
                final sym = currencySymbol(currencies.first);
                return Wrap(
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
                      valueColor:
                          hourlyRate >= 0 ? Colors.green : Colors.red,
                      prefix: hourlyRate >= 0 ? '+' : '-',
                    ),
                    _StatItem(
                      label: 'Total P&L',
                      value: totalPL >= 0
                          ? '+$sym${totalPL.toStringAsFixed(0)}'
                          : '-$sym${totalPL.abs().toStringAsFixed(0)}',
                      valueColor: totalPL >= 0 ? Colors.green : Colors.red,
                    ),
                    if (avgROI != null)
                      _StatItem(
                        label: 'Avg ROI',
                        value: formatROI(avgROI),
                        valueColor:
                            avgROI >= 0 ? Colors.green : Colors.red,
                      ),
                    if (itm != null && tSessions.isNotEmpty)
                      _StatItem(
                        label: 'ITM',
                        value:
                            '${(itm / tSessions.length * 100).toStringAsFixed(0)}%',
                      ),
                  ],
                );
              }),
            ],
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
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
        ),
      ],
    );
  }
}

// ─── P&L Chart with Toggle ────────────────────────────────────────────────────

enum _PLMode { cumulative, monthly, yearly }

class _PLChart extends StatefulWidget {
  final List<Session> sessions;
  final String? currencyFilter;

  const _PLChart({required this.sessions, this.currencyFilter});

  @override
  State<_PLChart> createState() => _PLChartState();
}

class _PLChartState extends State<_PLChart> {
  _PLMode _mode = _PLMode.cumulative;

  @override
  Widget build(BuildContext context) {
    final currencies = widget.sessions.map((s) => s.currency).toSet();
    final isMultiCurrency =
        widget.currencyFilter == null && currencies.length > 1;
    final sym = isMultiCurrency
        ? ''
        : currencySymbol(
            widget.currencyFilter ?? currencies.firstOrNull ?? 'CAD');

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
              children: [
                Expanded(
                  child: Text(
                    'P&L Over Time',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                for (final mode in _PLMode.values)
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: ChoiceChip(
                      label: Text(
                        modeLabels[mode]!,
                        style: const TextStyle(fontSize: 11),
                      ),
                      selected: _mode == mode,
                      onSelected: (_) => setState(() => _mode = mode),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (isMultiCurrency && _mode != _PLMode.yearly)
              SizedBox(
                height: 180,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.currency_exchange,
                          color: Theme.of(context).colorScheme.outline,
                          size: 32),
                      const SizedBox(height: 8),
                      Text(
                        'Sessions use multiple currencies.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                      ),
                      Text(
                        'Select a currency filter to see this chart.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SizedBox(
                height: 180,
                child: _mode == _PLMode.cumulative
                    ? _buildCumulative(context, sym)
                    : _mode == _PLMode.monthly
                        ? _buildMonthly(context, sym)
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
      cum += e.value.profitLoss;
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

  Widget _buildMonthly(BuildContext context, String sym) {
    final sessions = widget.sessions;
    final monthMap = <String, double>{};
    for (final s in sessions) {
      // Key is "yyyy-MM" — preserves year so Jan 2024 ≠ Jan 2025
      final key = s.date.substring(0, 7);
      monthMap[key] = (monthMap[key] ?? 0) + s.profitLoss;
    }
    final entries = monthMap.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    if (entries.isEmpty) return _emptyChart('No data');

    final maxAbs = entries
        .map((e) => e.value.abs())
        .reduce((a, b) => a > b ? a : b);
    final effectiveMax = maxAbs < 1 ? 50.0 : maxAbs;

    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    // Adaptive bar width
    final barW = entries.length <= 6
        ? 20.0
        : entries.length <= 12
            ? 14.0
            : 8.0;

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

    // Labels: "Jan\n'24" — two lines so year is always visible
    final labels = entries.map((e) {
      final parts = e.key.split('-');
      final month = monthNames[int.parse(parts[1]) - 1];
      final year = parts[0].substring(2); // "24" from "2024"
      return "$month\n'$year";
    }).toList();

    return BarChart(BarChartData(
      barGroups: groups,
      minY: -(effectiveMax * 1.2),
      maxY: effectiveMax * 1.2,
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
            reservedSize: 60,
            getTitlesWidget: (v, _) => Text(
              '$sym${v.abs().toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 9),
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 36,
            getTitlesWidget: (v, meta) {
              final i = v.toInt();
              if (i < 0 || i >= labels.length) return const SizedBox();
              return Text(labels[i],
                  style: const TextStyle(fontSize: 9),
                  textAlign: TextAlign.center);
            },
          ),
        ),
      ),
    ));
  }

  Widget _buildYearly(BuildContext context, String sym) {
    final sessions = widget.sessions;
    final yearMap = <String, double>{};
    for (final s in sessions) {
      final key = s.date.substring(0, 4); // "yyyy"
      yearMap[key] = (yearMap[key] ?? 0) + s.profitLoss;
    }
    final entries = yearMap.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    if (entries.isEmpty) return _emptyChart('No data');
    if (entries.length == 1) {
      // Single year — show with context label
    }

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
              '$sym${v.abs().toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 9),
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
                  style: const TextStyle(fontSize: 10));
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
              v >= 0 ? '+$sym${v.toStringAsFixed(0)}' : '-$sym${v.abs().toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 9),
            ),
          ),
        ),
      );
}

// ─── Win Rate by Attribute Chart ──────────────────────────────────────────────

enum _WRAttr { timeOfDay, dayOfWeek, sessionLength, tableQuality, location, liveVsOnline }

class _WinRateByAttributeChart extends StatefulWidget {
  final List<Session> sessions;
  final bool hasLiveAndOnline;

  const _WinRateByAttributeChart({
    required this.sessions,
    this.hasLiveAndOnline = false,
  });

  @override
  State<_WinRateByAttributeChart> createState() =>
      _WinRateByAttributeChartState();
}

class _WinRateByAttributeChartState
    extends State<_WinRateByAttributeChart> {
  _WRAttr _attr = _WRAttr.timeOfDay;

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

  // Returns (groupKey, orderedKeys, shortLabelFn)
  (String? Function(Session), List<String>?, String Function(String))
      _attrConfig() {
    switch (_attr) {
      case _WRAttr.timeOfDay:
        return (
          (s) => timeOfDayBucket(s.startTime),
          const [
            'Morning (6am–12pm)',
            'Afternoon (12pm–6pm)',
            'Evening (6pm–11pm)',
            'Late Night (11pm–6am)'
          ],
          (k) {
            if (k.startsWith('Morning')) return 'Morning';
            if (k.startsWith('Afternoon')) return 'Afternoon';
            if (k.startsWith('Evening')) return 'Evening';
            return 'Late Night';
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
          (k) => k.length > 14 ? '${k.substring(0, 12)}…' : k,
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

    // Detect mixed currencies for a contextual note
    final currencies = widget.sessions.map((s) => s.currency).toSet();
    final isMultiCurrency = currencies.length > 1;

    // If selected attr is no longer available, fall back to timeOfDay
    if (!availableAttrs.contains(_attr)) {
      WidgetsBinding.instance.addPostFrameCallback(
          (_) => setState(() => _attr = _WRAttr.timeOfDay));
    }

    final (keyFn, orderedKeys, shortLabel) = _attrConfig();

    // Build groups: totalPL / totalHours per attribute value
    final groups = <String, ({double totalPL, double totalHours, int count})>{};
    for (final s in widget.sessions) {
      final key = keyFn(s);
      if (key == null) continue;
      final existing = groups[key];
      if (existing == null) {
        groups[key] = (
          totalPL: s.profitLoss,
          totalHours: s.durationMinutes / 60.0,
          count: 1,
        );
      } else {
        groups[key] = (
          totalPL: existing.totalPL + s.profitLoss,
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

    final hourlyRates = groups.map((k, v) => MapEntry(
        k, v.totalHours > 0 ? v.totalPL / v.totalHours : v.totalPL));

    List<String> keys;
    if (orderedKeys != null) {
      keys = orderedKeys.where((k) => hourlyRates.containsKey(k)).toList();
      for (final k in hourlyRates.keys) {
        if (!keys.contains(k)) keys.add(k);
      }
    } else {
      keys = hourlyRates.keys.toList()
        ..sort((a, b) => hourlyRates[b]!.compareTo(hourlyRates[a]!));
    }

    // Ensure a non-zero Y range so fl_chart always renders bars
    final maxAbs = hourlyRates.values
        .map((v) => v.abs())
        .reduce((a, b) => a > b ? a : b);
    final effectiveMax = maxAbs < 1 ? 50.0 : maxAbs;
    final hasNeg = hourlyRates.values.any((v) => v < 0);
    final minY = hasNeg ? -(effectiveMax * 1.25) : -(effectiveMax * 0.1);
    final maxY = effectiveMax * 1.25;

    // Adaptive bar width so bars don't overlap on small charts
    final barWidth = keys.length <= 3
        ? 32.0
        : keys.length <= 5
            ? 24.0
            : keys.length <= 7
                ? 18.0
                : 12.0;

    final barGroups = keys.asMap().entries.map((e) {
      final rate = hourlyRates[e.value] ?? 0.0;
      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: rate,
            fromY: 0,
            color: rate >= 0 ? Colors.green : Colors.red,
            width: barWidth,
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      );
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Win Rate by Attribute',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                if (isMultiCurrency)
                  Tooltip(
                    message:
                        'Sessions use multiple currencies — \$/hr values are not directly comparable. Filter by currency for accurate comparison.',
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            size: 14,
                            color: Theme.of(context).colorScheme.outline),
                        const SizedBox(width: 3),
                        Text('Mixed currencies',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color:
                                          Theme.of(context).colorScheme.outline,
                                      fontSize: 10,
                                    )),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // Attribute selector chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: availableAttrs
                    .map((attr) => Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            label: Text(
                              attrLabels[attr]!,
                              style: const TextStyle(fontSize: 11),
                            ),
                            selected: _attr == attr,
                            onSelected: (_) =>
                                setState(() => _attr = attr),
                            visualDensity: VisualDensity.compact,
                          ),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: BarChart(BarChartData(
                barGroups: barGroups,
                minY: minY,
                maxY: maxY,
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
                      reservedSize: 60,
                      getTitlesWidget: (v, _) => Text(
                        formatPL(v),
                        style: const TextStyle(fontSize: 9),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (v, meta) {
                        final i = v.toInt();
                        if (i < 0 || i >= keys.length) {
                          return const SizedBox();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            shortLabel(keys[i]),
                            style: const TextStyle(fontSize: 9),
                            textAlign: TextAlign.center,
                          ),
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

  factory _GroupStats.from(List<Session> sessions) {
    final total = sessions.fold(0.0, (s, e) => s + e.profitLoss);
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
  final List<Session> sessions;
  final String Function(Session) keyFn;
  final List<String>? orderedKeys;

  const _InsightCard({
    required this.title,
    required this.sessions,
    required this.keyFn,
    this.orderedKeys,
  });

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<Session>>{};
    for (final s in sessions) {
      groups.putIfAbsent(keyFn(s), () => []).add(s);
    }

    if (groups.length < 2) return const SizedBox.shrink();

    final stats = groups.map((k, v) => MapEntry(k, _GroupStats.from(v)));

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
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
            const SizedBox(height: 12),
            for (final key in keys) ...[
              _InsightRow(
                label: key,
                stats: stats[key]!,
                maxAbsHourly: maxAbsHourly,
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

  const _InsightRow({
    required this.label,
    required this.stats,
    required this.maxAbsHourly,
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
            Text(
              '${stats.totalHours.toStringAsFixed(1)}h',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
            const SizedBox(width: 8),
            Text(
              '${formatPL(stats.hourlyRate)}/hr',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: barColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(width: 8),
            Text(
              formatPL(stats.totalPL),
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
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
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

// ─── Recommendations ──────────────────────────────────────────────────────────

class _Rec {
  final IconData icon;
  final String title;
  final String explanation;
  final double impact;

  _Rec({
    required this.icon,
    required this.title,
    required this.explanation,
    required this.impact,
  });
}

class _RecommendationsCard extends StatelessWidget {
  final List<Session> sessions;
  final String typeLabel;

  const _RecommendationsCard({
    required this.sessions,
    required String gameTypeLabel,
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

  List<_Rec> _buildRecommendations() {
    if (sessions.length < 5) return [];

    final recs = <_Rec>[];
    final overallHours =
        sessions.fold(0.0, (s, e) => s + e.durationMinutes / 60.0);
    final overallPL = sessions.fold(0.0, (s, e) => s + e.profitLoss);
    final overallRate = overallHours > 0 ? overallPL / overallHours : 0.0;

    void checkGroups({
      required String? Function(Session) keyFn,
      required IconData icon,
      required String dimension,
      bool cashOnly = false,
    }) {
      final src = cashOnly
          ? sessions.where((s) => s.gameType == 'cash').toList()
          : sessions;
      if (src.length < 4) return;

      final groups =
          <String, ({double totalPL, double totalHours, int count})>{};
      for (final s in src) {
        final k = keyFn(s);
        if (k == null || k.isEmpty) continue;
        final g = groups[k];
        if (g == null) {
          groups[k] = (
            totalPL: s.profitLoss,
            totalHours: s.durationMinutes / 60.0,
            count: 1
          );
        } else {
          groups[k] = (
            totalPL: g.totalPL + s.profitLoss,
            totalHours: g.totalHours + s.durationMinutes / 60.0,
            count: g.count + 1
          );
        }
      }

      final qualified = groups.entries
          .where((e) => e.value.count >= 2)
          .map((e) => (
                key: e.key,
                rate: e.value.totalHours > 0
                    ? e.value.totalPL / e.value.totalHours
                    : 0.0,
                count: e.value.count,
              ))
          .toList()
        ..sort((a, b) => b.rate.compareTo(a.rate));

      if (qualified.length < 2) return;

      final best = qualified.first;
      final worst = qualified.last;
      final impact = best.rate - overallRate;

      if (impact > 15) {
        final diff = best.rate - worst.rate;
        recs.add(_Rec(
          icon: icon,
          title: '${best.key} is your best $dimension',
          explanation: '${formatPL(best.rate)}/hr in ${best.key} sessions'
              '${diff > 40 ? ' — ${formatPL(diff)}/hr better than ${worst.key} (${formatPL(worst.rate)}/hr)' : ''}.'
              ' Your overall rate is ${formatPL(overallRate)}/hr.',
          impact: impact,
        ));
      }
    }

    checkGroups(
      keyFn: (s) => _shortTime(timeOfDayBucket(s.startTime)),
      icon: Icons.access_time,
      dimension: 'time slot',
    );
    checkGroups(
      keyFn: (s) => dayOfWeekLabel(s.date),
      icon: Icons.calendar_today,
      dimension: 'day',
    );
    checkGroups(
      keyFn: (s) => sessionLengthBucket(s.durationMinutes),
      icon: Icons.timer_outlined,
      dimension: 'session length',
    );
    checkGroups(
      keyFn: (s) => s.tableQuality != null ? '${s.tableQuality}★' : null,
      icon: Icons.star_border,
      dimension: 'table quality',
      cashOnly: true,
    );
    checkGroups(
      keyFn: (s) => s.location?.isNotEmpty == true ? s.location : null,
      icon: Icons.location_on_outlined,
      dimension: 'location',
    );
    if (sessions.any((s) => s.gameType == 'cash') &&
        sessions.any((s) => isTournamentType(s.gameType))) {
      checkGroups(
        keyFn: (s) => gameTypeLabel(s.gameType),
        icon: Icons.casino_outlined,
        dimension: 'game type',
      );
    }

    recs.sort((a, b) => b.impact.compareTo(a.impact));
    final top = recs.take(4).toList();

    if (sessions.length < 20) {
      top.add(_Rec(
        icon: Icons.trending_up,
        title: 'Build your sample size',
        explanation:
            'You have ${sessions.length} $typeLabel sessions. At 20+ your averages become more reliable and insights more actionable.',
        impact: 0,
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
    final impactColor = rec.impact > 80
        ? Colors.green
        : rec.impact > 30
            ? Colors.amber
            : Theme.of(context).colorScheme.onSurface;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(rec.icon, size: 20, color: impactColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                rec.title,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
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
              if (rec.impact > 0) ...[
                const SizedBox(height: 4),
                Text(
                  '+${formatPL(rec.impact)}/hr potential uplift',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: impactColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
