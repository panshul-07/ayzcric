import 'package:flutter/material.dart';

import '../game/game_controller.dart';
import '../game/game_scope.dart';
import '../screens/auction_screen.dart';
import '../screens/career_screen.dart';
import '../screens/match_center_screen.dart';
import '../widgets/team_badge.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final fixture = controller.nextFixture;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Command Center',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Season ${controller.seasonYear} • MD ${controller.matchesPlayed + 1}',
          style: const TextStyle(color: Color(0xFF9AA4B2)),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFF274E3D), Color(0xFF21382E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: const Color(0xFF2F6954)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  TeamBadge(branding: controller.userTeam.branding, size: 52),
                  const SizedBox(width: 12),
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
                          'League pos: ${_rankOf(controller)}/${controller.standings.length}',
                          style: const TextStyle(color: Color(0xFFCBE8DA)),
                        ),
                      ],
                    ),
                  ),
                  if (!controller.adsRemoved)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1F26),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'Owner\'s Pack',
                        style: TextStyle(color: Color(0xFF7DEAB6)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _metric(
                    'Cash',
                    '₹${controller.userTeam.cashCr.toStringAsFixed(1)} Cr',
                  ),
                  const SizedBox(width: 8),
                  _metric(
                    'Fans',
                    '${(controller.userTeam.fans / 1000).toStringAsFixed(1)}K',
                  ),
                  const SizedBox(width: 8),
                  _metric(
                    'Record',
                    '${controller.userTeam.wins}-${controller.userTeam.losses}',
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                controller.statusBanner,
                style: const TextStyle(color: Color(0xFFD3EFE2)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF171A1F),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF252B33)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'NEXT FIXTURE',
                style: TextStyle(
                  color: Color(0xFFD0D5DD),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              if (fixture == null)
                const Text(
                  'Season complete. Open Club tab and advance season.',
                  style: TextStyle(color: Color(0xFF9AA4B2)),
                )
              else
                Row(
                  children: [
                    TeamBadge(
                      branding: controller.teamBrandingFor(
                        controller.userTeam.name,
                      ),
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'vs',
                      style: TextStyle(color: Color(0xFF9AA4B2)),
                    ),
                    const SizedBox(width: 8),
                    TeamBadge(
                      branding: controller.teamBrandingFor(fixture.opponent),
                      size: 28,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${fixture.opponent} • ${fixture.home ? 'Home' : 'Away'}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFF46A2F),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        if (controller.liveMatch == null ||
                            controller.liveMatch!.completed) {
                          controller.startNextMatch();
                        }
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const MatchCenterScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.play_circle_fill),
                      label: Text(
                        controller.liveMatch == null ? 'Play' : 'Open',
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _actionCard(
                context,
                icon: Icons.gavel,
                title: 'Auction Room',
                subtitle: 'Bid and reshape squad',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AuctionScreen()),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _actionCard(
                context,
                icon: Icons.workspace_premium,
                title: 'Career Board',
                subtitle: 'Objectives and progression',
                onTap: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const CareerScreen())),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF171A1F),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF252B33)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ACHIEVEMENTS',
                style: TextStyle(
                  color: Color(0xFFD0D5DD),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${controller.unlockedAchievementCount} unlocked',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              if (controller.unlockedAchievements.isEmpty)
                const Text(
                  'Win matches, build academy, and hit milestones to unlock medals.',
                  style: TextStyle(color: Color(0xFF9AA4B2)),
                )
              else
                for (final achievement in controller.unlockedAchievements.take(
                  3,
                ))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      '• ${achievement.title}: ${achievement.description}',
                      style: const TextStyle(color: Color(0xFFBFD5CA)),
                    ),
                  ),
            ],
          ),
        ),
      ],
    );
  }

  static int _rankOf(GameController controller) {
    final sorted = [...controller.standings]
      ..sort((a, b) {
        final byPoints = b.points.compareTo(a.points);
        if (byPoints != 0) return byPoints;
        return b.netRunRate.compareTo(a.netRunRate);
      });
    return sorted.indexWhere((row) => row.name == controller.userTeam.name) + 1;
  }

  static Widget _metric(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF172B22),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Color(0xFF98B5A8))),
            const SizedBox(height: 3),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _actionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFF171A1F),
          border: Border.all(color: const Color(0xFF252B33)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFFFB8B5E)),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(color: Color(0xFF9AA4B2))),
          ],
        ),
      ),
    );
  }
}
