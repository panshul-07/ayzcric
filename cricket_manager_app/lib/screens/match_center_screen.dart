import 'package:flutter/material.dart';

import '../game/game_scope.dart';
import '../game/models.dart';
import '../widgets/over_run_chart.dart';
import '../widgets/wagon_wheel.dart';
import '../widgets/worm_chart.dart';

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
    final currentRr = innings.runRate;
    final reqRr = match.requiredRunRateFor(innings);
    final projected = match.projectedScoreFor(innings);

    final overRuns = List<int>.of(innings.overRuns);
    if (innings.balls % 6 != 0) {
      overRuns.add(innings.currentOverRuns);
    }
    final avgOver = overRuns.isEmpty
        ? 0
        : overRuns.reduce((a, b) => a + b) / overRuns.length;
    final bestOverValue = overRuns.isEmpty
        ? 0
        : overRuns.reduce((a, b) => a > b ? a : b);
    final bestOverIndex = overRuns.indexOf(bestOverValue) + 1;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Match Centre',
          style: TextStyle(
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          match.statusText,
          style: const TextStyle(
            color: Color(0xFFFB8B5E),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        _panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _kpi(
                      title: first.battingTeam,
                      value: '${first.runs}/${first.wickets}',
                      subtitle: '${first.overText} ov',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _kpi(
                      title: second.battingTeam,
                      value: '${second.runs}/${second.wickets}',
                      subtitle: '${second.overText} ov',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _kpi(
                      title: 'Current RR',
                      value: currentRr.toStringAsFixed(2),
                      subtitle: reqRr == null
                          ? 'Setting pace'
                          : 'Req ${reqRr.toStringAsFixed(2)}',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _kpi(
                      title: 'Projected',
                      value: projected.toStringAsFixed(0),
                      subtitle: controller.autoPlay
                          ? 'Auto Play ON'
                          : 'Auto Play OFF',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '${innings.battingTeam} batting',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Striker: ${innings.striker.name} • Non-striker: ${innings.nonStriker.name}',
                style: const TextStyle(color: Color(0xFFAFBAC8)),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InsightChip(
                    label: 'Your Impact',
                    value: match.userImpactName,
                  ),
                  _InsightChip(label: 'Opp Impact', value: match.aiImpactName),
                  _InsightChip(
                    label: 'Status',
                    value: match.userImpactUsed ? 'Used' : 'Available',
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Aggression',
                style: TextStyle(color: Color(0xFFC8D1DC)),
              ),
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
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFF46A2F),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: match.completed ? null : controller.stepBall,
                    icon: const Icon(Icons.skip_next),
                    label: const Text('Next Ball'),
                  ),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2B333E),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: match.completed
                        ? null
                        : controller.toggleAutoPlay,
                    icon: Icon(
                      controller.autoPlay
                          ? Icons.pause_circle
                          : Icons.play_circle,
                    ),
                    label: Text(controller.autoPlay ? 'Stop Auto' : 'Auto'),
                  ),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF1F7F59),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: match.canActivateUserImpact
                        ? controller.activateImpactPlayer
                        : null,
                    icon: const Icon(Icons.flash_on),
                    label: const Text('Impact'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Live Charts',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              WormChart(
                firstInningsRuns: first.runProgression,
                secondInningsRuns: second.runProgression,
                maxBalls: match.format.oversPerInnings * 6,
                firstLabel: first.battingTeam,
                secondLabel: second.battingTeam,
                firstRuns: first.runs,
                secondRuns: second.runs,
                firstBalls: first.balls,
                secondBalls: second.balls,
                projectedScore: projected,
                target: match.target,
                requiredRate: reqRr,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InsightChip(
                    label: 'Avg / Over',
                    value: avgOver.toStringAsFixed(1),
                  ),
                  _InsightChip(
                    label: 'Best Over',
                    value: bestOverValue == 0
                        ? '-'
                        : '$bestOverValue (Ov $bestOverIndex)',
                  ),
                  _InsightChip(
                    label: 'Current RR',
                    value: currentRr.toStringAsFixed(2),
                  ),
                  _InsightChip(
                    label: 'Projected',
                    value: projected.toStringAsFixed(0),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              OverRunChart(overRuns: overRuns, label: innings.battingTeam),
              const SizedBox(height: 10),
              Text(
                'Wagon Wheel • ${innings.battingTeam}',
                style: const TextStyle(
                  color: Color(0xFFCCD4DF),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              WagonWheel(
                shotZones: innings.shotZones,
                totalRuns: innings.runs,
                totalBalls: innings.balls,
                boundaries: innings.boundaries,
                sixes: innings.sixes,
                dots: innings.dots,
                singles: innings.singles,
                doubles: innings.doubles,
                triples: innings.triples,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ball-by-Ball',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              if (match.timeline.isEmpty)
                const Text(
                  'No deliveries yet.',
                  style: TextStyle(color: Color(0xFF9AA4B2)),
                )
              else
                SizedBox(
                  height: 320,
                  child: ListView.builder(
                    itemCount: match.timeline.length,
                    itemBuilder: (context, index) {
                      final event = match.timeline[index];
                      return _EventTile(event: event);
                    },
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _panel({required Widget child}) {
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

  static Widget _kpi({
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF101418),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF202833)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFFAAB4C0)),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 38,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(subtitle, style: const TextStyle(color: Color(0xFF8A95A2))),
        ],
      ),
    );
  }
}

class _InsightChip extends StatelessWidget {
  const _InsightChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: const Color(0xFF183D30),
        border: Border.all(color: const Color(0xFF236649)),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          color: Color(0xFFD4F2E4),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event});

  final MatchBallEvent event;

  @override
  Widget build(BuildContext context) {
    final wicket = event.isWicket;
    final dotBall = !wicket && event.runs == 0;
    final color = wicket
        ? const Color(0xFFFF6767)
        : dotBall
        ? const Color(0xFF97A1AF)
        : (event.runs >= 4 ? const Color(0xFF4A8BFF) : const Color(0xFF4AD487));

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF101418),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF202833)),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        leading: CircleAvatar(
          radius: 16,
          backgroundColor: color.withValues(alpha: 0.2),
          child: Text(
            wicket ? 'W' : '${event.runs}',
            style: TextStyle(color: color, fontWeight: FontWeight.w800),
          ),
        ),
        title: Text(
          event.description,
          style: TextStyle(
            color: wicket ? const Color(0xFFFF8686) : const Color(0xFFE8EDF4),
            fontWeight: wicket ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        subtitle: Text(
          '${event.overText} • ${event.bowler} to ${event.batter}',
          style: const TextStyle(color: Color(0xFF8D98A6)),
        ),
      ),
    );
  }
}

class _NoMatchView extends StatelessWidget {
  const _NoMatchView({required this.latestResult});

  final MatchResult? latestResult;

  @override
  Widget build(BuildContext context) {
    if (latestResult == null) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF151A22),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF252B33)),
          ),
          child: const Text(
            'No active match. Start from Home > Play.',
            style: TextStyle(color: Color(0xFFB9C4D1), fontSize: 22),
          ),
        ),
      );
    }

    final result = latestResult!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Latest Result',
          style: TextStyle(
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        MatchCenterScreen._panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                result.summary,
                style: const TextStyle(
                  color: Color(0xFFFB8B5E),
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${result.userInnings.teamName}: ${result.userInnings.runs}/${result.userInnings.wickets} (${result.userInnings.oversText})',
                style: const TextStyle(color: Color(0xFFE6ECF3), fontSize: 22),
              ),
              Text(
                '${result.aiInnings.teamName}: ${result.aiInnings.runs}/${result.aiInnings.wickets} (${result.aiInnings.oversText})',
                style: const TextStyle(color: Color(0xFFE6ECF3), fontSize: 22),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
