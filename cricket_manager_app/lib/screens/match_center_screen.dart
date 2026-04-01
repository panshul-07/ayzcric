import 'package:flutter/material.dart';

import '../game/game_scope.dart';
import '../game/models.dart';
import '../widgets/wagon_wheel.dart';
import '../widgets/worm_chart.dart';
import '../widgets/stat_card.dart';

class MatchCenterScreen extends StatelessWidget {
  const MatchCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final match = controller.liveMatch;

    if (match == null) {
      return _NoMatchView(latestResult: controller.latestResult);
    }

    final innings = match.activeInnings;
    final first = match.firstInnings;
    final second = match.secondInnings;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Live Match Center',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(match.statusText),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: 170,
              child: StatCard(
                title: first.battingTeam,
                value: '${first.runs}/${first.wickets}',
                subtitle: '${first.overText} overs',
              ),
            ),
            SizedBox(
              width: 170,
              child: StatCard(
                title: second.battingTeam,
                value: '${second.runs}/${second.wickets}',
                subtitle: '${second.overText} overs',
              ),
            ),
            SizedBox(
              width: 170,
              child: StatCard(
                title: 'Active',
                value: '${innings.runs}/${innings.wickets}',
                subtitle: '${innings.overText} overs',
              ),
            ),
            SizedBox(
              width: 170,
              child: StatCard(
                title: 'Aggression',
                value: '${(match.aggression * 100).round()}%',
                subtitle: controller.autoPlay ? 'Autoplay ON' : 'Autoplay OFF',
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${innings.battingTeam} vs ${innings.bowlingTeam}',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  'Striker: ${innings.striker.name}   Non-striker: ${innings.nonStriker.name}',
                ),
                const SizedBox(height: 12),
                Text('Aggression'),
                Slider(
                  min: 0.15,
                  max: 0.92,
                  value: match.aggression,
                  onChanged: match.completed ? null : controller.setAggression,
                ),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton.icon(
                      onPressed: match.completed ? null : controller.stepBall,
                      icon: const Icon(Icons.skip_next),
                      label: const Text('Next Ball'),
                    ),
                    FilledButton.icon(
                      onPressed: match.completed
                          ? null
                          : controller.toggleAutoPlay,
                      icon: Icon(
                        controller.autoPlay
                            ? Icons.pause_circle
                            : Icons.play_circle,
                      ),
                      label: Text(
                        controller.autoPlay ? 'Stop Auto' : 'Auto Play',
                      ),
                    ),
                  ],
                ),
                if (match.completed) ...[
                  const SizedBox(height: 10),
                  Text(
                    match.statusText,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
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
                  'Live Charts (Worm + Wagon Wheel)',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                WormChart(
                  firstInningsRuns: first.runProgression,
                  secondInningsRuns: second.runProgression,
                  maxBalls: match.format.oversPerInnings * 6,
                  firstLabel: first.battingTeam,
                  secondLabel: second.battingTeam,
                ),
                const SizedBox(height: 12),
                Text(
                  'Wagon Wheel (${innings.battingTeam})',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                WagonWheel(shotZones: innings.shotZones),
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
                  'Ball-by-Ball',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                if (match.timeline.isEmpty)
                  const Text('No deliveries yet.')
                else
                  SizedBox(
                    height: 280,
                    child: ListView.builder(
                      itemCount: match.timeline.length,
                      itemBuilder: (context, index) {
                        final event = match.timeline[index];
                        return ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            radius: 14,
                            backgroundColor: event.isWicket
                                ? Theme.of(context).colorScheme.errorContainer
                                : Theme.of(
                                    context,
                                  ).colorScheme.secondaryContainer,
                            child: Text(
                              event.isWicket ? 'W' : '${event.runs}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(event.description),
                          subtitle: Text(
                            'Bowler: ${event.bowler} | Batter: ${event.batter}',
                          ),
                        );
                      },
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

class _NoMatchView extends StatelessWidget {
  const _NoMatchView({required this.latestResult});

  final MatchResult? latestResult;

  @override
  Widget build(BuildContext context) {
    if (latestResult == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('No active match. Start one from Dashboard.'),
        ),
      );
    }

    final result = latestResult!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Latest Match Result',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.summary,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                Text(
                  '${result.userInnings.teamName}: ${result.userInnings.runs}/${result.userInnings.wickets} (${result.userInnings.oversText})',
                ),
                Text(
                  '${result.aiInnings.teamName}: ${result.aiInnings.runs}/${result.aiInnings.wickets} (${result.aiInnings.oversText})',
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
                  'Batting Card - ${result.userInnings.teamName}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                for (final e in result.userInnings.battingCard)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      '${e.name}  ${e.runs} (${e.balls})  SR ${e.strikeRate.toStringAsFixed(1)}',
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
