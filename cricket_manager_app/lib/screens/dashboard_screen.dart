import 'package:flutter/material.dart';

import '../game/game_scope.dart';
import '../game/models.dart';
import '../widgets/stat_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final sortedTable = List<TeamStanding>.of(controller.standings)
      ..sort((a, b) {
        final byPoints = b.points.compareTo(a.points);
        if (byPoints != 0) return byPoints;
        return b.netRunRate.compareTo(a.netRunRate);
      });

    final fixture = controller.nextFixture;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Season ${controller.seasonYear} Command Center',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          controller.statusBanner,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: 170,
              child: StatCard(
                title: 'Purse',
                value: '₹${controller.userTeam.cashCr.toStringAsFixed(1)} Cr',
                subtitle: 'Sponsor Tier ${controller.userTeam.sponsorLevel}',
              ),
            ),
            SizedBox(
              width: 170,
              child: StatCard(
                title: 'Fanbase',
                value: controller.userTeam.fans.toString(),
                subtitle: 'Morale ${controller.userTeam.morale}',
              ),
            ),
            SizedBox(
              width: 170,
              child: StatCard(
                title: 'Record',
                value:
                    '${controller.userTeam.wins}-${controller.userTeam.losses}',
                subtitle: '${controller.userTeam.points} pts',
              ),
            ),
            SizedBox(
              width: 170,
              child: StatCard(
                title: 'Season',
                value:
                    '${controller.matchesPlayed}/${controller.fixtures.length} played',
                subtitle: '${controller.matchesRemaining} left',
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Next Fixture',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                if (fixture != null)
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Round ${fixture.round}: ${fixture.home ? 'Home' : 'Away'} vs ${fixture.opponent}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      FilledButton.icon(
                        onPressed:
                            controller.liveMatch != null &&
                                !controller.liveMatch!.completed
                            ? null
                            : controller.startNextMatch,
                        icon: const Icon(Icons.sports_cricket),
                        label: Text(
                          controller.liveMatch == null
                              ? 'Start Match'
                              : 'Match Active',
                        ),
                      ),
                    ],
                  )
                else
                  const Text(
                    'All fixtures completed. Advance season from Career tab.',
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'League',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      _LeagueTabChip(
                        label: 'Standings',
                        selected: tabIndex == 0,
                        onTap: () => setState(() => tabIndex = 0),
                      ),
                      _LeagueTabChip(
                        label: 'Fixtures',
                        selected: tabIndex == 1,
                        onTap: () => setState(() => tabIndex = 1),
                      ),
                      _LeagueTabChip(
                        label: 'Top Players',
                        selected: tabIndex == 2,
                        onTap: () => setState(() => tabIndex = 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (tabIndex == 0)
                  _StandingsList(
                    sortedTable: sortedTable,
                    userTeamName: controller.userTeam.name,
                  ),
                if (tabIndex == 1) _FixturesList(fixtures: controller.fixtures),
                if (tabIndex == 2)
                  _TopPlayersList(cards: controller.leagueTopCards),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LeagueTabChip extends StatelessWidget {
  const _LeagueTabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: selected
                ? Theme.of(context).colorScheme.surface
                : Colors.transparent,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: selected
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _StandingsList extends StatelessWidget {
  const _StandingsList({required this.sortedTable, required this.userTeamName});

  final List<TeamStanding> sortedTable;
  final String userTeamName;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < sortedTable.length; i++)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: i < 4
                  ? Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withValues(alpha: 0.35)
                  : Theme.of(context).colorScheme.surfaceContainerLow,
              border: Border.all(
                color: sortedTable[i].name == userTeamName
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
              ),
            ),
            child: ListTile(
              dense: true,
              leading: Text(
                '${i + 1}',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              title: Text(sortedTable[i].name),
              subtitle: Text(
                'P ${sortedTable[i].played}  W ${sortedTable[i].wins}  Pts ${sortedTable[i].points}',
              ),
              trailing: Text(
                sortedTable[i].netRunRate >= 0
                    ? '+${sortedTable[i].netRunRate.toStringAsFixed(2)}'
                    : sortedTable[i].netRunRate.toStringAsFixed(2),
                style: TextStyle(
                  color: sortedTable[i].netRunRate >= 0
                      ? Colors.green
                      : Colors.red,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        const SizedBox(height: 4),
        Text(
          '--------- Playoff Cutoff ---------',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _FixturesList extends StatelessWidget {
  const _FixturesList({required this.fixtures});

  final List<Fixture> fixtures;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final fixture in fixtures)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: fixture.played
                  ? Theme.of(context).colorScheme.surfaceContainerLow
                  : Theme.of(
                      context,
                    ).colorScheme.secondaryContainer.withValues(alpha: 0.35),
            ),
            child: ListTile(
              title: Text(
                'Round ${fixture.round}: ${fixture.home ? 'Home' : 'Away'} vs ${fixture.opponent}',
              ),
              subtitle: Text(fixture.resultSummary ?? 'Upcoming'),
              trailing: Icon(
                fixture.played
                    ? (fixture.won == true ? Icons.check_circle : Icons.cancel)
                    : Icons.schedule,
                color: fixture.played
                    ? (fixture.won == true ? Colors.green : Colors.red)
                    : Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
      ],
    );
  }
}

class _TopPlayersList extends StatelessWidget {
  const _TopPlayersList({required this.cards});

  final List<Map<String, Object>> cards;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final card in cards)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.surfaceContainerLow,
            ),
            child: ListTile(
              title: Text(
                card['title'] as String,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text('${card['badge']} • ${card['player']}'),
              trailing: Text(
                card['value'] as String,
                style: TextStyle(
                  color: Color(card['color'] as int),
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
