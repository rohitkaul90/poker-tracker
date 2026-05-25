import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('Help & FAQ')),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              _SectionHeader('Getting Started', Icons.flag_outlined, primary),
              ..._gettingStarted.map((faq) => _FaqTile(faq)),

              _SectionHeader('Sessions', Icons.receipt_long_outlined, primary),
              ..._sessions.map((faq) => _FaqTile(faq)),

              _SectionHeader('Analytics', Icons.bar_chart_rounded, primary),
              ..._analytics.map((faq) => _FaqTile(faq)),

              _SectionHeader('Hand Replayer', Icons.play_circle_outline_rounded, primary),
              ..._hands.map((faq) => _FaqTile(faq)),

              _SectionHeader('Player Reads', Icons.psychology_outlined, primary),
              ..._reads.map((faq) => _FaqTile(faq)),

              _SectionHeader('Import & Export', Icons.import_export_rounded, primary),
              ..._importExport.map((faq) => _FaqTile(faq)),

              _SectionHeader('Account & Data', Icons.security_outlined, primary),
              ..._account.map((faq) => _FaqTile(faq)),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ── FAQ data ─────────────────────────────────────────────────────────────────

const _gettingStarted = [
  _Faq(
    q: 'What is TableLab?',
    a: 'TableLab is a poker tracking and analysis app for serious players. '
        'Log every session you play, review performance trends, record and replay hands for study, '
        'and build a personal database of opponent reads — all synced to the cloud across devices.',
  ),
  _Faq(
    q: 'Do I need an account to use the app?',
    a: 'Yes. TableLab uses a secure cloud backend so your data is always backed up and accessible from any device. '
        'You can sign in with Google (one tap) or create a traditional email/password account.',
  ),
  _Faq(
    q: 'How do I navigate the app?',
    a: 'The bottom navigation bar has five tabs: Dashboard, Sessions, Hands, Equity Calculator, and Reads. '
        'Tap the menu icon (☰) in the top-left to open the side panel for your profile, settings, help, and more.',
  ),
  _Faq(
    q: 'Is my data private?',
    a: 'Yes. Every query to the database enforces Row-Level Security — meaning you can only ever read or write '
        'your own data. No other user can see your sessions, hands, or reads.',
  ),
];

const _sessions = [
  _Faq(
    q: 'How do I log a session?',
    a: 'Go to the Sessions tab and tap the + button in the bottom-right. '
        'Select Cash Game or Tournament, fill in the details, and tap Save. '
        'Required fields are marked — everything else is optional but improves your analytics.',
  ),
  _Faq(
    q: 'What\'s the difference between Cash and Tournament logging?',
    a: 'Cash Games track profit/loss as cash-out minus buy-in. '
        'Tournaments track profit/loss as prize won minus buy-in, and display your ROI (return on investment) '
        'as a percentage. The log form adapts based on which type you select, showing only relevant fields.',
  ),
  _Faq(
    q: 'What is Rake and why should I track it?',
    a: 'Rake is the fee the house takes for running the game. '
        'It\'s recorded for informational purposes only — it doesn\'t change your P&L, but it '
        'helps you understand the true cost of play at different venues. '
        'You can save rake presets per location so you never have to re-enter the same value.',
  ),
  _Faq(
    q: 'What is Table Quality?',
    a: 'Table Quality is your subjective 1–5 star rating of how good the game was — '
        'factoring in opponent skill level, game dynamics, or how soft the table felt. '
        'Analytics uses this to help you identify which games are most worth playing.',
  ),
  _Faq(
    q: 'What does "Hands/Hour" mean?',
    a: 'Hands per hour is the pace of the game — how many hands were dealt each hour. '
        'Cash game players often track this to compare speed across venues. '
        'A faster game means more decisions per hour, which amplifies both edges and leaks.',
  ),
  _Faq(
    q: 'Can I edit or delete a session?',
    a: 'Yes. In the Sessions tab, tap any session to open its detail view. '
        'Use the pencil icon in the top-right to edit, or the trash icon to delete. '
        'Deleted sessions are removed permanently.',
  ),
  _Faq(
    q: 'What currencies are supported?',
    a: 'CAD, USD, GBP, and EUR. The currency defaults to the same as your last logged session. '
        'When viewing analytics, all amounts are converted to your selected display currency '
        'at approximate exchange rates.',
  ),
];

const _analytics = [
  _Faq(
    q: 'Where do I find Analytics?',
    a: 'Go to the Dashboard tab and tap the "Analytics" chip at the top. '
        'The Analytics view lives alongside the Overview tab on the same screen.',
  ),
  _Faq(
    q: 'What is the P&L Over Time chart?',
    a: 'This chart tracks your cumulative profit and loss over time. '
        'A line trending upward means you\'re profitable — every session adds (or subtracts) from your running total. '
        'Switch between Cumulative, Weekly, Monthly, and Yearly views using the chips above the chart.',
  ),
  _Faq(
    q: 'How do Analytics filters work?',
    a: 'Tap the filter icon (sliders) in the top-right of the screen when on the Analytics tab. '
        'You can filter by date range, display currency, country, venue type (Live/Online), '
        'and specific location. All charts and insight cards update to reflect the filtered data.',
  ),
  _Faq(
    q: 'What are the Insight Cards?',
    a: 'Insight Cards break down your performance by different dimensions: stakes, buy-in level, '
        'game type, day of week, time of day, session length, table quality, and location. '
        'Each card shows your P&L and win rate for that segment so you can see exactly where you perform best.',
  ),
  _Faq(
    q: 'What are Recommendations?',
    a: 'Recommendations uses Welch\'s t-test — a statistical method — to detect meaningful differences '
        'in your performance across conditions. For example, if your live results are significantly '
        'stronger than online, it flags that. Expand the section to see actionable suggestions.',
  ),
  _Faq(
    q: 'What is Hourly Rate?',
    a: 'Hourly rate is your average profit per hour of play, calculated from sessions where you logged '
        'both a start and end time (or a duration). It\'s one of the most useful metrics for '
        'cash game players to compare across stakes and locations.',
  ),
];

const _hands = [
  _Faq(
    q: 'How does the Hand Recorder work?',
    a: 'In the Hands tab, tap the + button. First set up the table: add player names, positions, '
        'stack sizes, and the blind levels. Then step through each street — Pre-flop, Flop, Turn, River — '
        'recording each player\'s action (fold, call, raise, all-in) and the community cards dealt.',
  ),
  _Faq(
    q: 'Do I have to record hands in real time?',
    a: 'No. The hand recorder is designed to be used from memory after a session. '
        'Record the key hands while they\'re fresh — what mattered was the decision-making, not the timing.',
  ),
  _Faq(
    q: 'What is the Hand Replayer?',
    a: 'Tap a recorded hand in the Hands list to open the replayer. '
        'It shows a top-down table view with player panels, chip counts, community cards, and action labels. '
        'Use the controls at the bottom to step forward/back through each action, '
        'or press Play to auto-advance. Speed can be adjusted with the speed chips.',
  ),
  _Faq(
    q: 'Can I share a hand?',
    a: 'Yes — in the Hand Replayer, tap the share icon in the top-right AppBar. '
        'This exports the hand as a formatted text hand history (street by street, pot sizes included) '
        'which you can share via any messaging or chat app.',
  ),
  _Faq(
    q: 'Can I delete a recorded hand?',
    a: 'Yes. In the Hands list, swipe left on any hand to reveal the delete action.',
  ),
];

const _reads = [
  _Faq(
    q: 'What is the Reads tab?',
    a: 'Reads is your private database of opponent notes. '
        'Add any player you\'ve encountered and record tells, tendencies, bet-sizing patterns, '
        'or any observations from your time at the table with them.',
  ),
  _Faq(
    q: 'How do I add a read?',
    a: 'Go to the Reads tab and tap the + button. Enter the player\'s name and your notes. '
        'You can add and edit notes over time as you encounter the player in future sessions.',
  ),
  _Faq(
    q: 'Can I use Reads with the Hand Recorder?',
    a: 'Yes. When recording a hand, player name fields autocomplete from your Reads database. '
        'This lets you build a connected record of hands involving players you\'ve profiled.',
  ),
  _Faq(
    q: 'Can I share a player read?',
    a: 'Yes. Open a read\'s detail view and tap the share icon. '
        'This exports the player name and your notes as plain text to share via any app.',
  ),
];

const _importExport = [
  _Faq(
    q: 'How do I export my sessions?',
    a: 'Go to the Sessions tab and tap the Import/Export button in the top-right. '
        'Choose Export, select CSV or Excel format, and the file will be generated and ready to save or share. '
        'CSV works with any spreadsheet app; Excel exports a formatted .xlsx file.',
  ),
  _Faq(
    q: 'How do I import sessions from a spreadsheet?',
    a: 'Tap Import on the Import/Export screen and pick a CSV or Excel file from your device. '
        'TableLab will show a column mapping UI — drag or assign your spreadsheet\'s columns to the '
        'correct session fields. Confirm the mapping and the sessions will be imported.',
  ),
  _Faq(
    q: 'What columns does the CSV export include?',
    a: 'The export includes all session fields: date, game type, stakes, location, buy-in, cash-out, '
        'profit/loss, duration, rake, table quality, hands/hour, notes, currency, and more.',
  ),
];

const _account = [
  _Faq(
    q: 'How do I reset my password?',
    a: 'On the login screen, tap "Forgot password?" below the password field and enter your email. '
        'A reset link will be sent to your inbox. You can also trigger a reset from the sidebar menu '
        'while logged in (tap the menu icon, then Reset Password under Settings).',
  ),
  _Faq(
    q: 'Where is my data stored?',
    a: 'Your data lives in Supabase — a secure, cloud-hosted PostgreSQL database. '
        'Row-Level Security policies are enforced at the database level, '
        'so your data is accessible only to you.',
  ),
  _Faq(
    q: 'Can I use TableLab on multiple devices?',
    a: 'Yes. Sign in with the same account on any device — web, Android, or desktop — '
        'and all your sessions, hands, and reads sync automatically.',
  ),
  _Faq(
    q: 'Can I delete my account?',
    a: 'In-app account deletion is not yet supported. '
        'To request full deletion of your data, contact support.',
  ),
];

// ── Data class ────────────────────────────────────────────────────────────────

class _Faq {
  const _Faq({required this.q, required this.a});
  final String q;
  final String a;
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label, this.icon, this.color);
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile(this.faq);
  final _Faq faq;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      title: Text(
        faq.q,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
      ),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          faq.a,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withAlpha(200),
            height: 1.6,
          ),
        ),
      ],
    );
  }
}
