import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/hand_model.dart';
import '../providers/providers.dart';
import '../widgets/playing_card_widget.dart';
import 'hand_input/hand_input_screen.dart';
import 'hand_replayer/hand_replayer_screen.dart';

class HandsScreen extends ConsumerWidget {
  const HandsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final handsAsync = ref.watch(handsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hands'),
        centerTitle: true,
      ),
      body: handsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Error loading hands: $e',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red)),
          ),
        ),
        data: (hands) {
          if (hands.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.style_outlined, size: 72, color: Colors.white12),
                  const SizedBox(height: 16),
                  Text(
                    'No hands recorded yet',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: Colors.white54),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tap + to record and replay a hand',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.white38),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: hands.length,
            itemBuilder: (ctx, i) => _HandTile(hand: hands[i]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_hands',
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HandInputScreen()),
          );
          ref.invalidate(handsProvider);
        },
        tooltip: 'Record hand',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _HandTile extends ConsumerWidget {
  final PokerHand hand;

  const _HandTile({required this.hand});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hero = hand.hero;
    final fmt = DateFormat('MMM d, y · h:mm a');
    final setup = hand.tableSetup;
    final stakes = '\$${setup.smallBlind}/\$${setup.bigBlind}'
        '${setup.straddle != null ? '/\$${setup.straddle}' : ''}';

    return Dismissible(
      key: ValueKey(hand.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red.shade900,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (_) => showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Delete hand?'),
          content: const Text('This hand record will be permanently deleted.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
              child: const Text('Delete'),
            ),
          ],
        ),
      ),
      onDismissed: (_) async {
        try {
          await ref.read(handServiceProvider).deleteHand(hand.id);
        } catch (_) {
          // refresh restores item if delete failed
        }
        ref.invalidate(handsProvider);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => HandReplayerScreen(hand: hand),
            ),
          ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // Hero hole cards
              Row(
                children: [
                  PlayingCard(
                    card: hero?.holeCards?.isNotEmpty == true
                        ? hero!.holeCards![0]
                        : null,
                    width: 30,
                    height: 42,
                  ),
                  const SizedBox(width: 3),
                  PlayingCard(
                    card: hero?.holeCards?.length == 2 ? hero!.holeCards![1] : null,
                    width: 30,
                    height: 42,
                  ),
                ],
              ),
              const SizedBox(width: 14),

              // Info column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$stakes · ${setup.numSeats}-max',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${hand.streetReached} · ${hand.players.length} players',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white60,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      fmt.format(hand.playedAt.toLocal()),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white38,
                      ),
                    ),
                  ],
                ),
              ),

              // Community cards preview (up to 3)
              if (hand.allCommunityCards.isNotEmpty) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: hand.allCommunityCards
                      .take(3)
                      .map(
                        (c) => Padding(
                          padding: const EdgeInsets.only(left: 2),
                          child: PlayingCard(card: c, width: 22, height: 30),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(width: 6),
              ],

              const Icon(Icons.chevron_right, color: Colors.white24, size: 20),
            ],
          ),
        ),
      ),
    ),
    );
  }
}
