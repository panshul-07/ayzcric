import 'package:flutter/material.dart';

import '../game/game_scope.dart';
import '../game/models.dart';
import '../widgets/stat_card.dart';

class AuctionScreen extends StatefulWidget {
  const AuctionScreen({super.key});

  @override
  State<AuctionScreen> createState() => _AuctionScreenState();
}

class _AuctionScreenState extends State<AuctionScreen> {
  String? selectedLotId;

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final lots = controller.auctionLots;
    AuctionLot? selected;
    if (selectedLotId != null) {
      for (final lot in lots) {
        if (lot.id == selectedLotId) {
          selected = lot;
          break;
        }
      }
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Auction Room',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text('Compete against AI clubs and build your squad depth.'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: 180,
              child: StatCard(
                title: 'Remaining Purse',
                value: '₹${controller.userTeam.cashCr.toStringAsFixed(1)} Cr',
              ),
            ),
            SizedBox(
              width: 180,
              child: StatCard(
                title: 'Squad Size',
                value: '${controller.userTeam.squad.length}/22',
                subtitle:
                    '${controller.userTeam.squad.where((p) => p.inPlayingXI).length} in XI',
              ),
            ),
            SizedBox(
              width: 180,
              child: StatCard(
                title: 'Youth Signings',
                value: '${controller.youthSignings}',
                subtitle: 'Board target progress',
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selected == null
                        ? 'Select a lot to bid.'
                        : 'Selected: ${selected.player.name} (${selected.player.role.label})',
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: controller.refreshAuctionRoom,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh Lots'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Auction Lots',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 380,
                  child: ListView.builder(
                    itemCount: lots.length,
                    itemBuilder: (context, index) {
                      final lot = lots[index];
                      final selectedStyle = lot.id == selectedLotId;
                      return Card(
                        color: selectedStyle
                            ? Theme.of(context).colorScheme.primaryContainer
                                  .withValues(alpha: 0.55)
                            : null,
                        child: ListTile(
                          onTap: () => setState(() => selectedLotId = lot.id),
                          title: Text(
                            '${lot.player.name} (${lot.player.role.label})',
                          ),
                          subtitle: Text(
                            'Base ₹${lot.basePriceCr.toStringAsFixed(1)} Cr | Current ₹${lot.currentBidCr.toStringAsFixed(1)} Cr\n'
                            'Overall ${lot.player.overall} | Age ${lot.player.age} | Top bid: ${lot.highestBidder}',
                          ),
                          trailing: lot.closed
                              ? Chip(
                                  label: Text(
                                    lot.soldToUser ? 'Signed' : 'Sold',
                                  ),
                                  backgroundColor: lot.soldToUser
                                      ? Theme.of(
                                          context,
                                        ).colorScheme.secondaryContainer
                                      : Theme.of(
                                          context,
                                        ).colorScheme.surfaceContainerHighest,
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (selected != null)
          Builder(
            builder: (context) {
              final lot = selected;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bid Console',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(lot!.player.traits.map((t) => t.name).join(', ')),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          FilledButton.icon(
                            onPressed: lot.closed
                                ? null
                                : () => controller.placeBid(lot.id),
                            icon: const Icon(Icons.gavel),
                            label: const Text('Bid +0.2 Cr'),
                          ),
                          FilledButton.icon(
                            onPressed: lot.closed
                                ? null
                                : () => controller.finalizeLot(lot.id),
                            icon: const Icon(Icons.done_all),
                            label: const Text('Close Lot'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
