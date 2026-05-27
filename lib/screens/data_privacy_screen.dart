import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DataPrivacyScreen extends StatelessWidget {
  const DataPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Data & Privacy')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 48),
        children: [
          _Section(
            icon: Icons.storage_outlined,
            title: 'What we collect',
            body:
                'TableLab stores the data you enter: session records (stakes, '
                'buy-ins, results, notes), hand histories you record, player '
                'reads, and your account profile. Nothing is collected '
                'automatically — every record exists because you created it.',
          ),
          _Section(
            icon: Icons.cloud_outlined,
            title: 'Where it\'s stored',
            body:
                'Your data lives in a Supabase-managed Postgres database hosted '
                'on AWS. Row-Level Security (RLS) policies ensure that only your '
                'authenticated account can read or modify your records. '
                'TableLab staff cannot query individual user data.',
          ),
          _Section(
            icon: Icons.auto_awesome_outlined,
            title: 'AI features',
            body:
                'When you use Analyze Hand or Analyze Session, the relevant '
                'hand history or session details are sent to Anthropic\'s '
                'Claude API to generate the coaching analysis. Anthropic\'s '
                'data usage policy applies to this data in transit. '
                'Analysis results are cached in your account so repeat '
                'requests don\'t re-send your data. AI features are '
                'opt-in — your data is never sent unless you tap "Analyse".',
          ),
          _Section(
            icon: Icons.block_outlined,
            title: 'No tracking, no ads',
            body:
                'TableLab does not use advertising SDKs, analytics trackers, '
                'or third-party data brokers. Your poker data is yours. '
                'We do not sell, rent, or share your personal information '
                'with any third party.',
          ),
          _Section(
            icon: Icons.manage_accounts_outlined,
            title: 'Your rights',
            body:
                'You can export all your session data at any time via the '
                'Import/Export screen. To request deletion of your account '
                'and all associated data, contact us using the link below — '
                'we will action it within 30 days.',
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.mail_outline, size: 18),
            label: const Text('Contact for data requests'),
            onPressed: () => launchUrl(Uri(
              scheme: 'mailto',
              path: 'rhtk.1234@gmail.com',
              queryParameters: {'subject': 'TableLab Data Request'},
            )),
          ),
          const SizedBox(height: 32),
          Text(
            'Last updated: May 2026',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.outline),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _Section({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2, right: 16),
            child: Icon(icon, size: 22, color: theme.colorScheme.primary),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(200),
                    height: 1.55,
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
