import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';
import '../providers/providers.dart';
import '../utils/helpers.dart';
import '../widgets/stat_card.dart';
import '../widgets/session_tile.dart';
import 'log_session_screen.dart';
import 'session_detail_screen.dart';
import 'analytics_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showFab = _tabController.index == 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Analytics'),
          ],
        ),
      ),
      floatingActionButton: showFab
          ? FloatingActionButton.extended(
              heroTag: 'fab_dashboard',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LogSessionScreen()),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Log Session'),
            )
          : null,
      body: TabBarView(
        controller: _tabController,
        children: const [
          _OverviewTab(),
          AnalyticsScreen(),
        ],
      ),
    );
  }
}

class _OverviewTab extends ConsumerWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(sessionsProvider);
    return sessionsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (sessions) => _OverviewBody(sessions: sessions),
    );
  }
}

class _OverviewBody extends StatefulWidget {
  final List<Session> sessions;

  const _OverviewBody({required this.sessions});

  @override
  State<_OverviewBody> createState() => _OverviewBodyState();
}

class _OverviewBodyState extends State<_OverviewBody> {
  String? _gameFilter;
  String? _currencyFilter; // null = auto (most frequent)

  // Currencies ordered by session count descending.
  List<String> get _allCurrencies {
    final counts = <String, int>{};
    for (final s in widget.sessions) {
      counts[s.currency] = (counts[s.currency] ?? 0) + 1;
    }
    return (counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value)))
        .map((e) => e.key)
        .toList();
  }

  String get _effectiveCurrency =>
      _currencyFilter ??
      (_allCurrencies.isNotEmpty ? _allCurrencies.first : 'USD');

  List<Session> get _byCurrency =>
      widget.sessions.where((s) => s.currency == _effectiveCurrency).toList();

  bool get _hasCash => _byCurrency.any((s) => s.gameType == 'cash');
  bool get _hasTournament =>
      widget.sessions.any((s) => isTournamentType(s.gameType));
  bool get _showGameFilter => _hasCash && _hasTournament;

  List<Session> get _filtered {
    if (_gameFilter == null) return _byCurrency;
    if (_gameFilter == 'tournament') {
      return _byCurrency.where((s) => isTournamentType(s.gameType)).toList();
    }
    return _byCurrency.where((s) => s.gameType == 'cash').toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final stats = _Stats.from(filtered, _effectiveCurrency);
    final recent = _byCurrency.take(5).toList();
    final currencies = _allCurrencies;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        // Currency filter chips (only when multiple currencies exist)
        if (currencies.length > 1) ...[
          _CurrencyFilterChips(
            currencies: currencies,
            selected: _effectiveCurrency,
            onChanged: (c) => setState(() {
              _currencyFilter = c;
              _gameFilter = null; // reset game filter when switching currency
            }),
          ),
          const SizedBox(height: 8),
        ],

        // Game type filter chips
        if (_showGameFilter) ...[
          _GameTypeFilterChips(
            value: _gameFilter,
            hasCash: _hasCash,
            hasTournament: _hasTournament,
            onChanged: (v) => setState(() => _gameFilter = v),
          ),
          const SizedBox(height: 12),
        ],

        // Total P&L hero card
        Card(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              children: [
                Text(
                  _gameFilter == null
                      ? 'Total P&L'
                      : '${_gameFilter == 'cash' ? 'Cash' : 'Tournament'} P&L',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  formatPLWithCurrency(stats.totalPL, _effectiveCurrency),
                  style: Theme.of(context)
                      .textTheme
                      .displayMedium
                      ?.copyWith(
                    color: stats.totalPL >= 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Stat cards grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 2.4,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: _gameFilter == 'tournament'
              ? [
                  StatCard(
                    label: 'Sessions',
                    value: '${stats.sessionCount}',
                  ),
                  StatCard(
                    label: 'ITM',
                    value: '${stats.itm}',
                  ),
                  StatCard(
                    label: 'ITM %',
                    value: '${stats.itmPct.toStringAsFixed(0)}%',
                  ),
                  StatCard(
                    label: 'ROI',
                    value: formatROI(stats.roi),
                    valueColor: stats.roi >= 0 ? Colors.green : Colors.red,
                  ),
                ]
              : [
                  StatCard(
                    label: 'Hours Played',
                    value: '${stats.totalHours.toStringAsFixed(1)}h',
                  ),
                  StatCard(
                    label: 'Win Rate',
                    value: '${formatPLWithCurrency(stats.hourlyRate, _effectiveCurrency)}/hr',
                    valueColor:
                        stats.hourlyRate >= 0 ? Colors.green : Colors.red,
                  ),
                  StatCard(
                    label: 'Sessions',
                    value: '${stats.sessionCount}',
                  ),
                  StatCard(
                    label: 'W / L',
                    value: '${stats.wins}W  ${stats.losses}L',
                    valueColor: stats.wins > stats.losses
                        ? Colors.green
                        : stats.losses > stats.wins
                            ? Colors.red
                            : null,
                  ),
                ],
        ),
        const SizedBox(height: 20),

        // Recent sessions
        if (recent.isNotEmpty) ...[
          Text('Recent Sessions',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          ...recent.map(
            (s) => SessionTile(
              session: s,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => SessionDetailScreen(session: s)),
              ),
            ),
          ),
        ] else
          const Padding(
            padding: EdgeInsets.only(top: 48),
            child: Center(
              child: Text(
                  'No sessions yet.\nTap + to log your first session!'),
            ),
          ),
      ],
    );
  }
}

// ─── Currency Filter Chips ────────────────────────────────────────────────────

class _CurrencyFilterChips extends StatelessWidget {
  final List<String> currencies;
  final String selected;
  final ValueChanged<String> onChanged;

  const _CurrencyFilterChips({
    required this.currencies,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: currencies
          .map((c) => FilterChip(
                label: Text(c),
                selected: c == selected,
                onSelected: (_) => onChanged(c),
              ))
          .toList(),
    );
  }
}

// ─── Game Type Filter Chips (shared) ─────────────────────────────────────────

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

// ─── Stats Model ─────────────────────────────────────────────────────────────

class _Stats {
  final double totalPL;
  final double totalHours;
  final double hourlyRate;
  final int sessionCount;
  final int wins;
  final int losses;
  final int itm;
  final double itmPct;
  final double roi;

  _Stats({
    required this.totalPL,
    required this.totalHours,
    required this.hourlyRate,
    required this.sessionCount,
    required this.wins,
    required this.losses,
    required this.itm,
    required this.itmPct,
    required this.roi,
  });

  factory _Stats.from(List<Session> sessions, String currency) {
    if (sessions.isEmpty) {
      return _Stats(
        totalPL: 0, totalHours: 0, hourlyRate: 0, sessionCount: 0,
        wins: 0, losses: 0, itm: 0, itmPct: 0, roi: 0,
      );
    }
    final totalPL = sessions.fold(0.0, (s, e) => s + e.profitLoss);
    final totalMinutes = sessions.fold(0, (s, e) => s + e.durationMinutes);
    final totalHours = totalMinutes / 60.0;
    final hourlyRate = totalHours > 0 ? totalPL / totalHours : 0.0;
    final wins = sessions.where((s) => s.profitLoss > 0).length;
    final losses = sessions.where((s) => s.profitLoss <= 0).length;
    final totalBuyIn = sessions.fold(0.0, (s, e) => s + e.buyIn);
    final roi = totalBuyIn > 0 ? totalPL / totalBuyIn * 100 : 0.0;
    final itm = sessions.where((s) => (s.prizeWon ?? 0) > 0).length;
    final itmPct = sessions.isNotEmpty ? itm / sessions.length * 100 : 0.0;
    return _Stats(
      totalPL: totalPL,
      totalHours: totalHours,
      hourlyRate: hourlyRate,
      sessionCount: sessions.length,
      wins: wins,
      losses: losses,
      itm: itm,
      itmPct: itmPct,
      roi: roi,
    );
  }
}
