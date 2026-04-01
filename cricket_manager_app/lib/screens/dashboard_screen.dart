import 'package:flutter/material.dart';

import '../game/game_scope.dart';
import '../game/models.dart';
import '../widgets/stat_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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
                  'League Table',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('#')),
                      DataColumn(label: Text('Team')),
                      DataColumn(label: Text('P')),
                      DataColumn(label: Text('W')),
                      DataColumn(label: Text('L')),
                      DataColumn(label: Text('Pts')),
                      DataColumn(label: Text('NRR')),
                    ],
                    rows: [
                      for (int i = 0; i < sortedTable.length; i++)
                        DataRow(
                          color:
                              sortedTable[i].name == controller.userTeam.name ||
                                  sortedTable[i].name == 'My Franchise'
                              ? WidgetStatePropertyAll(
                                  Theme.of(context).colorScheme.primaryContainer
                                      .withValues(alpha: 0.6),
                                )
                              : null,
                          cells: [
                            DataCell(Text('${i + 1}')),
                            DataCell(Text(sortedTable[i].name)),
                            DataCell(Text('${sortedTable[i].played}')),
                            DataCell(Text('${sortedTable[i].wins}')),
                            DataCell(Text('${sortedTable[i].losses}')),
                            DataCell(Text('${sortedTable[i].points}')),
                            DataCell(
                              Text(
                                sortedTable[i].netRunRate.toStringAsFixed(2),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
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
                  'Board Objectives',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                for (final obj in controller.objectives)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          obj.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          obj.description,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 6),
                        LinearProgressIndicator(
                          value: (obj.current / obj.target).clamp(0, 1),
                          minHeight: 8,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${obj.current}/${obj.target} ${obj.completed ? 'Complete' : ''}',
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
