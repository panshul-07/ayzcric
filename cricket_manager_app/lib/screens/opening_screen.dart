import 'package:flutter/material.dart';

import '../game/game_scope.dart';
import '../services/iap_scope.dart';
import '../services/iap_service.dart';

class OpeningScreen extends StatefulWidget {
  const OpeningScreen({
    super.key,
    required this.onContinue,
    required this.onNewGame,
  });

  final VoidCallback onContinue;
  final VoidCallback onNewGame;

  @override
  State<OpeningScreen> createState() => _OpeningScreenState();
}

class _OpeningScreenState extends State<OpeningScreen> {
  int _themeIndex = 1;

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final iap = IapScope.of(context);
    final hasSave =
        controller.matchesPlayed > 0 || controller.userTeam.wins > 0;

    return ListenableBuilder(
      listenable: iap,
      builder: (context, _) {
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          children: [
            const SizedBox(height: 18),
            const Text(
              'Cricket\nChairman',
              style: TextStyle(
                color: Colors.white,
                fontSize: 44,
                height: 0.94,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: const Color(0xFF1C2230),
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: Color(0xFFFD8C4D),
                  size: 32,
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (hasSave)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: const Color(0xFF151A22),
                  border: Border.all(color: const Color(0xFFFB8B5E)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF202834),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Icon(
                        Icons.shield_rounded,
                        color: Color(0xFF6CB5FF),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.userTeam.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '${controller.seasonYear} • MD ${controller.matchesPlayed + 1} • ${controller.matchesPlayed} matches played',
                            style: const TextStyle(color: Color(0xFF9AA4B2)),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: widget.onContinue,
                      icon: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Color(0xFFFB8B5E),
                      ),
                    ),
                  ],
                ),
              ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: const Color(0xFF151A22),
                border: Border.all(color: const Color(0xFF272D37)),
              ),
              child: Column(
                children: [
                  _menuTile(
                    icon: Icons.add_rounded,
                    title: 'New Game',
                    onTap: widget.onNewGame,
                  ),
                  _divider(),
                  _menuTile(
                    icon: Icons.folder_open_rounded,
                    title: 'Load Game',
                    onTap: widget.onContinue,
                  ),
                  _divider(),
                  _menuTile(
                    icon: Icons.grid_view_rounded,
                    title: 'Database',
                    onTap: () => _showInfoDialog(
                      title: 'Database',
                      message:
                          'Player pool, traits, and team metadata are generated fresh each career.',
                    ),
                  ),
                  _divider(),
                  _menuTile(
                    icon: Icons.campaign_outlined,
                    title: 'What\'s New',
                    onTap: () => _showInfoDialog(
                      title: 'What\'s New',
                      message:
                          'New opening UI, academy tiers, achievements popups, club action shortcuts, and updated league flow.',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(58),
                backgroundColor: const Color(0xFFF1BF15),
                foregroundColor: const Color(0xFF1C1605),
              ),
              onPressed: iap.storeAvailable && !iap.loading
                  ? () => iap.buyProduct(IapService.ownersPackId)
                  : null,
              icon: const Icon(Icons.workspace_premium_rounded),
              label: Text(
                'Buy Owner\'s Pack • ${iap.displayPrice(IapService.ownersPackId)}',
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton.icon(
                onPressed: null,
                icon: const Icon(Icons.discord, color: Color(0xFF9AA4B2)),
                label: const Text(
                  'Join the Discord',
                  style: TextStyle(color: Color(0xFF9AA4B2)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: const Color(0xFF131821),
                  border: Border.all(color: const Color(0xFF2A3039)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _themeButton(0, Icons.light_mode_outlined),
                    _themeButton(1, Icons.phone_android_rounded),
                    _themeButton(2, Icons.dark_mode_outlined),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 26),
            Center(
              child: Text(
                '${controller.matchesPlayed} matches played across 1 save',
                style: const TextStyle(color: Color(0xFF7F8793), fontSize: 20),
              ),
            ),
            const SizedBox(height: 6),
            const Center(
              child: Text(
                'Still figuring out which end to hold the bat',
                style: TextStyle(color: Color(0xFF7F8793), fontSize: 18),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _divider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFF232A34),
      indent: 14,
      endIndent: 14,
    );
  }

  Widget _menuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: const Color(0xFFE9EDF3)),
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFFE9EDF3),
          fontWeight: FontWeight.w700,
          fontSize: 24,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: Color(0xFF8F99A8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
    );
  }

  Widget _themeButton(int index, IconData icon) {
    final selected = _themeIndex == index;
    return InkWell(
      onTap: () => setState(() => _themeIndex = index),
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: 38,
        width: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: selected ? const Color(0xFF2B1E1A) : null,
        ),
        child: Icon(
          icon,
          color: selected ? const Color(0xFFFB8B5E) : const Color(0xFF9AA4B2),
        ),
      ),
    );
  }

  Future<void> _showInfoDialog({
    required String title,
    required String message,
  }) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF151A22),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(
          message,
          style: const TextStyle(color: Color(0xFFC8CFD8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
