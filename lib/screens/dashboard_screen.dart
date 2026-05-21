import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/session_model.dart';
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
  final List<SessionModel> sessions;

  const _OverviewBody({required this.sessions});

  @override
  State<_OverviewBody> createState() => _OverviewBodyState();
}

class _OverviewBodyState extends State<_OverviewBody> {
  String? _gameFilter;       // null | 'cash' | 'tournament'
  String? _displayCurrency;  // null = auto (latest session's currency)

  String get _effectiveCurrency {
    if (_displayCurrency != null) return _displayCurrency!;
    if (widget.sessions.isEmpty) return 'CAD';
    final sorted = [...widget.sessions]
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.first.currency;
  }

  bool get _hasCash => widget.sessions.any((s) => s.gameType == 'cash');
  bool get _hasTournament =>
      widget.sessions.any((s) => isTournamentType(s.gameType));
  bool get _showGameFilter => _hasCash && _hasTournament;

  List<SessionModel> get _filtered {
    if (_gameFilter == null) return widget.sessions;
    if (_gameFilter == 'tournament') {
      return widget.sessions.where((s) => isTournamentType(s.gameType)).toList();
    }
    return widget.sessions.where((s) => s.gameType == 'cash').toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final displayCurrency = _effectiveCurrency;
    final stats = _Stats.from(filtered, displayCurrency);
    final recent = ([...widget.sessions]
          ..sort((a, b) => b.date.compareTo(a.date)))
        .take(5)
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        _FilterRow(
          gameFilter: _showGameFilter ? (_gameFilter ?? 'all') : null,
          hasCash: _hasCash,
          hasTournament: _hasTournament,
          displayCurrency: displayCurrency,
          onGameFilterChanged: (v) =>
              setState(() => _gameFilter = v == 'all' ? null : v),
          onCurrencyChanged: (c) => setState(() => _displayCurrency = c),
        ),
        const SizedBox(height: 12),

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
                  formatPLWithCurrency(stats.totalPL, displayCurrency),
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
          childAspectRatio: 2.0,
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
                    value:
                        '${formatPLWithCurrency(stats.hourlyRate, displayCurrency)}/hr',
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

// ─── Filter Row ───────────────────────────────────────────────────────────────

class _FilterRow extends StatelessWidget {
  final String? gameFilter; // null = hide segment, else 'all'|'cash'|'tournament'
  final bool hasCash;
  final bool hasTournament;
  final String displayCurrency;
  final ValueChanged<String> onGameFilterChanged;
  final ValueChanged<String> onCurrencyChanged;

  const _FilterRow({
    required this.gameFilter,
    required this.hasCash,
    required this.hasTournament,
    required this.displayCurrency,
    required this.onGameFilterChanged,
    required this.onCurrencyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (gameFilter != null) ...[
          _GameTypeDropdown(
            value: gameFilter!,
            hasCash: hasCash,
            hasTournament: hasTournament,
            onChanged: onGameFilterChanged,
          ),
          const SizedBox(width: 8),
        ],
        _CurrencyDropdown(
          value: displayCurrency,
          onChanged: onCurrencyChanged,
        ),
      ],
    );
  }
}

class _GameTypeDropdown extends StatelessWidget {
  final String value; // 'all' | 'cash' | 'tournament'
  final bool hasCash;
  final bool hasTournament;
  final ValueChanged<String> onChanged;

  const _GameTypeDropdown({
    required this.value,
    required this.hasCash,
    required this.hasTournament,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(
            color: Theme.of(context).colorScheme.outline.withAlpha(80)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          items: [
            const DropdownMenuItem(
                value: 'all',
                child: Text('All Games', style: TextStyle(fontSize: 13))),
            if (hasCash)
              const DropdownMenuItem(
                  value: 'cash',
                  child: Text('Cash', style: TextStyle(fontSize: 13))),
            if (hasTournament)
              const DropdownMenuItem(
                  value: 'tournament',
                  child:
                      Text('Tournament', style: TextStyle(fontSize: 13))),
          ],
          onChanged: (v) => onChanged(v!),
        ),
      ),
    );
  }
}

class _CurrencyDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _CurrencyDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(
            color: Theme.of(context).colorScheme.outline.withAlpha(80)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          items: supportedDisplayCurrencies
              .map((c) => DropdownMenuItem(
                    value: c,
                    child: Text('$c ${currencySymbol(c)}',
                        style: const TextStyle(fontSize: 13)),
                  ))
              .toList(),
          onChanged: (c) => onChanged(c!),
        ),
      ),
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

  factory _Stats.from(List<SessionModel> sessions, String displayCurrency) {
    if (sessions.isEmpty) {
      return _Stats(
        totalPL: 0, totalHours: 0, hourlyRate: 0, sessionCount: 0,
        wins: 0, losses: 0, itm: 0, itmPct: 0, roi: 0,
      );
    }

    double toDisplay(double amount, String from) =>
        convertCurrency(amount, from, displayCurrency);

    final totalPL = sessions.fold(
        0.0, (sum, s) => sum + toDisplay(s.profitLoss, s.currency));
    final totalMinutes = sessions.fold(0, (s, e) => s + e.durationMinutes);
    final totalHours = totalMinutes / 60.0;
    final hourlyRate = totalHours > 0 ? totalPL / totalHours : 0.0;
    final wins = sessions.where((s) => s.profitLoss > 0).length;
    final losses = sessions.where((s) => s.profitLoss <= 0).length;
    final totalBuyIn = sessions.fold(
        0.0, (sum, s) => sum + toDisplay(s.buyIn, s.currency));
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
