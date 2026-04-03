import 'package:flutter/material.dart';

import '../game/game_scope.dart';
import '../game/models.dart';

class AuctionScreen extends StatefulWidget {
  const AuctionScreen({super.key});

  @override
  State<AuctionScreen> createState() => _AuctionScreenState();
}

class _AuctionScreenState extends State<AuctionScreen> {
  String? selectedLotId;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final titleSize = width < 420 ? 28.0 : (width < 900 ? 34.0 : 38.0);
    final sectionSize = width < 420 ? 20.0 : 24.0;
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
          style: TextStyle(
            color: Colors.white,
            fontSize: titleSize,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Compete against AI clubs and build your squad depth.',
          style: TextStyle(color: Color(0xFF9AA4B2)),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _stat(
              'Remaining Purse',
              '₹${controller.userTeam.cashCr.toStringAsFixed(1)} Cr',
              null,
            ),
            _stat(
              'Squad Size',
              '${controller.userTeam.squad.length}/22',
              '${controller.userTeam.squad.where((p) => p.inPlayingXI).length} in XI',
            ),
            _stat(
              'Youth Signings',
              '${controller.youthSignings}',
              'Board target progress',
            ),
          ],
        ),
        const SizedBox(height: 12),
        _panel(
          child: Row(
            children: [
              Expanded(
                child: Text(
                  selected == null
                      ? 'Select a lot to bid.'
                      : 'Selected: ${selected.player.name} (${selected.player.role.label})',
                  style: const TextStyle(color: Color(0xFFD4DCE7)),
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
        const SizedBox(height: 12),
        _panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Auction Lots',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: sectionSize,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 420,
                child: ListView.builder(
                  itemCount: lots.length,
                  itemBuilder: (context, index) {
                    final lot = lots[index];
                    final selectedStyle = lot.id == selectedLotId;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: selectedStyle
                            ? const Color(0xFF2A221F)
                            : const Color(0xFF101418),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selectedStyle
                              ? const Color(0xFFFB8B5E)
                              : const Color(0xFF202833),
                        ),
                      ),
                      child: ListTile(
                        onTap: () => setState(() => selectedLotId = lot.id),
                        title: Text(
                          '${lot.player.name} (${lot.player.role.label})',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          'Base ₹${lot.basePriceCr.toStringAsFixed(1)} Cr • Current ₹${lot.currentBidCr.toStringAsFixed(1)} Cr\n'
                          'OVR ${lot.player.overall} • Age ${lot.player.age} • Top bid ${lot.highestBidder}',
                          style: const TextStyle(color: Color(0xFF9AA4B2)),
                        ),
                        trailing: lot.closed
                            ? Chip(
                                label: Text(lot.soldToUser ? 'Signed' : 'Sold'),
                                backgroundColor: lot.soldToUser
                                    ? const Color(0xFF1E4632)
                                    : const Color(0xFF2C333D),
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
        const SizedBox(height: 12),
        if (selected != null)
          _panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bid Console',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: sectionSize,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  selected.player.traits.map((t) => t.name).join(', '),
                  style: const TextStyle(color: Color(0xFF9AA4B2)),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    Builder(
                      builder: (_) {
                        final lot = selected!;
                        return FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFF46A2F),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: lot.closed
                              ? null
                              : () => controller.placeBid(lot.id),
                          icon: const Icon(Icons.gavel),
                          label: const Text('Bid +0.2 Cr'),
                        );
                      },
                    ),
                    Builder(
                      builder: (_) {
                        final lot = selected!;
                        return FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF2B333E),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: lot.closed
                              ? null
                              : () => controller.finalizeLot(lot.id),
                          icon: const Icon(Icons.done_all),
                          label: const Text('Close Lot'),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _panel({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF151A22),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF252B33)),
      ),
      child: child,
    );
  }

  Widget _stat(String title, String value, String? subtitle) {
    return Container(
      width: 215,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF151A22),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF252B33)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Color(0xFF9AA4B2))),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 28,
            ),
          ),
          if (subtitle != null)
            Text(subtitle, style: const TextStyle(color: Color(0xFF8993A0))),
        ],
      ),
    );
  }
}
