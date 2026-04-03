import 'package:flutter/material.dart';

import '../game/game_scope.dart';
import '../game/models.dart';
import '../widgets/team_badge.dart';

class LeagueScreen extends StatelessWidget {
  const LeagueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final sorted = List<TeamStanding>.of(controller.standings)
      ..sort((a, b) {
        final byPoints = b.points.compareTo(a.points);
        if (byPoints != 0) return byPoints;
        return b.netRunRate.compareTo(a.netRunRate);
      });

    final upcoming = controller.fixtures
        .where((f) => !f.played)
        .take(4)
        .toList();
    final topCards = controller.leagueTopCards.take(4).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'League',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: Colors.white,
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
              Row(
                children: [
                  const Text(
                    'STANDINGS',
                    style: TextStyle(
                      color: Color(0xFFD0D5DD),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Top 4 qualify',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFFFB8B5E),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              for (int i = 0; i < sorted.length; i++)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: sorted[i].name == controller.userTeam.name
                        ? const Color(0xFF2B221F)
                        : const Color(0xFF101418),
                    border: Border.all(
                      color: i < 4
                          ? const Color(0xFF2B3B2F)
                          : const Color(0xFF1E232C),
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 22,
                        child: Text(
                          '${i + 1}',
                          style: TextStyle(
                            color: i < 4
                                ? const Color(0xFF57D986)
                                : const Color(0xFF9AA4B2),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      TeamBadge(
                        branding: controller.teamBrandingFor(sorted[i].name),
                        size: 28,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          sorted[i].name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        '${sorted[i].points}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        sorted[i].netRunRate >= 0
                            ? '+${sorted[i].netRunRate.toStringAsFixed(2)}'
                            : sorted[i].netRunRate.toStringAsFixed(2),
                        style: TextStyle(
                          color: sorted[i].netRunRate >= 0
                              ? const Color(0xFF57D986)
                              : const Color(0xFFFF7272),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'TOP PERFORMERS',
          style: TextStyle(
            color: Color(0xFFD0D5DD),
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          itemCount: topCards.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.28,
          ),
          itemBuilder: (context, index) {
            final card = topCards[index];
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF171A1F),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF252B33)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card['title'] as String,
                    style: const TextStyle(
                      color: Color(0xFFBDC6D1),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    card['badge'] as String,
                    style: TextStyle(
                      color: Color(card['color'] as int),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    card['value'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    card['player'] as String,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Color(0xFF9AA4B2)),
                  ),
                ],
              ),
            );
          },
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
                'MATCH DAY',
                style: TextStyle(
                  color: Color(0xFFD0D5DD),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 10),
              if (upcoming.isEmpty)
                const Text(
                  'No upcoming fixtures. Advance season from Club > Career.',
                  style: TextStyle(color: Color(0xFF9AA4B2)),
                )
              else
                for (final fixture in upcoming)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF101418),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF202833)),
                    ),
                    child: Row(
                      children: [
                        TeamBadge(
                          branding: controller.teamBrandingFor(
                            controller.userTeam.name,
                          ),
                          size: 26,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'vs',
                          style: TextStyle(color: Color(0xFF9AA4B2)),
                        ),
                        const SizedBox(width: 8),
                        TeamBadge(
                          branding: controller.teamBrandingFor(
                            fixture.opponent,
                          ),
                          size: 26,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${fixture.home ? 'Home' : 'Away'} • ${fixture.opponent}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          'R${fixture.round}',
                          style: const TextStyle(color: Color(0xFFFB8B5E)),
                        ),
                      ],
                    ),
                  ),
            ],
          ),
        ),
      ],
    );
  }
}
