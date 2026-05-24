import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onSurface = theme.colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(title: const Text('About TableLab')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Logo + name ─────────────────────────────────────────────────
            Image.asset('assets/icon/app_icon.png', width: 88, height: 88),
            const SizedBox(height: 14),
            Text(
              'TableLab',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Your edge, quantified.',
              style: theme.textTheme.titleSmall?.copyWith(
                color: primary,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 32),

            // ── What is it ──────────────────────────────────────────────────
            _Prose(
              "Poker is a game of information. TableLab makes sure you have yours.",
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: onSurface,
              ),
            ),
            const SizedBox(height: 12),
            _Prose(
              "Every session you log is a data point. Enough data points and patterns "
              "emerge — maybe your best game is Live \$2/\$5 on Saturday nights, maybe "
              "your worst is any online session after midnight. TableLab surfaces those "
              "patterns so you can stop guessing and start winning.",
            ),
            const SizedBox(height: 28),

            // ── Feature list ────────────────────────────────────────────────
            _FeatureTile(
              icon: Icons.receipt_long_outlined,
              color: Colors.teal,
              title: 'Session Tracker',
              body:
                  'Log every cash game and tournament — buy-ins, rake, duration, location, table quality, and more. Your history, always at hand.',
            ),
            _FeatureTile(
              icon: Icons.bar_chart_rounded,
              color: Colors.indigo,
              title: 'Deep Analytics',
              body:
                  'P&L over time, win rates by stakes, location, game type, time of day, session length — the metrics that actually matter.',
            ),
            _FeatureTile(
              icon: Icons.play_circle_outline_rounded,
              color: Colors.orange,
              title: 'Hand Replayer',
              body:
                  'Record hands from memory and replay them frame-by-frame. Study your decisions, share lines with friends, and plug the leaks.',
            ),
            _FeatureTile(
              icon: Icons.psychology_outlined,
              color: Colors.purple,
              title: 'Player Reads',
              body:
                  'Build a private database of tells, tendencies, and notes on opponents. The felt has a memory — now so do you.',
            ),
            _FeatureTile(
              icon: Icons.currency_exchange_rounded,
              color: Colors.green,
              title: 'Multi-Currency Bankroll',
              body:
                  'CAD, USD, GBP, EUR — play anywhere in the world and your bankroll stays accurate across every currency.',
            ),
            _FeatureTile(
              icon: Icons.import_export_rounded,
              color: Colors.blueGrey,
              title: 'Import & Export',
              body:
                  'Your data, your way. Export to CSV or Excel, import from existing spreadsheets. No lock-in, ever.',
            ),
            const SizedBox(height: 28),

            // ── Vision ──────────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primary.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primary.withAlpha(60)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.rocket_launch_outlined, color: primary, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'The Vision',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "A full-stack poker intelligence platform — tracking, analysis, "
                    "study, and eventually, community — for every player who takes "
                    "the game seriously. Built by a player, for players.",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: onSurface.withAlpha(220),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),

            // ── Version ──────────────────────────────────────────────────────
            Text(
              'TableLab v1.0',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Prose extends StatelessWidget {
  const _Prose(this.text, {this.style});
  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style ??
          Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(200),
                height: 1.55,
              ),
      textAlign: TextAlign.left,
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  body,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(180),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
