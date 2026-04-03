import 'package:flutter/material.dart';

import '../game/game_scope.dart';
import '../game/models.dart';

class SquadScreen extends StatefulWidget {
  const SquadScreen({super.key});

  @override
  State<SquadScreen> createState() => _SquadScreenState();
}

class _SquadScreenState extends State<SquadScreen> {
  String? selectedPlayerId;
  PlayerRole? roleFilter;

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    var squad = List<Player>.of(controller.userTeam.squad)
      ..sort((a, b) => b.overall.compareTo(a.overall));

    if (roleFilter != null) {
      squad = squad.where((p) => p.role == roleFilter).toList();
    }

    Player? selected;
    if (selectedPlayerId != null) {
      for (final p in controller.userTeam.squad) {
        if (p.id == selectedPlayerId) {
          selected = p;
          break;
        }
      }
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Squad Management',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text('Train players, manage playing XI, and monitor form/fitness.'),
        if (controller.selectedImpactPlayer != null) ...[
          const SizedBox(height: 6),
          Text(
            'Impact Player: ${controller.selectedImpactPlayer!.name}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: const Text('All Roles'),
              selected: roleFilter == null,
              onSelected: (_) => setState(() => roleFilter = null),
            ),
            for (final role in PlayerRole.values)
              ChoiceChip(
                label: Text(role.label),
                selected: roleFilter == role,
                onSelected: (_) => setState(() => roleFilter = role),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Roster (${controller.userTeam.squad.length})',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 420,
                  child: ListView.builder(
                    itemCount: squad.length,
                    itemBuilder: (context, index) {
                      final player = squad[index];
                      final selectedRow = player.id == selectedPlayerId;
                      return Card(
                        color: selectedRow
                            ? Theme.of(context).colorScheme.primaryContainer
                                  .withValues(alpha: 0.55)
                            : null,
                        child: ListTile(
                          onTap: () =>
                              setState(() => selectedPlayerId = player.id),
                          title: Text('${player.name} (${player.role.label})'),
                          subtitle: Text(
                            'OVR ${player.overall} | Form ${player.form} | Fit ${player.fitness} | '
                            'Bat ${player.hitting} / Bowl ${player.bowling}',
                          ),
                          trailing: Wrap(
                            spacing: 6,
                            children: [
                              if (player.injured)
                                const Chip(label: Text('Injured')),
                              Chip(
                                label: Text(
                                  player.inPlayingXI ? 'XI' : 'Bench',
                                ),
                              ),
                            ],
                          ),
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
              final player = selected;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${player!.name} Control Panel',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Age ${player.age} | Market ₹${player.marketValueCr.toStringAsFixed(1)} Cr',
                      ),
                      Text(
                        'Traits: ${player.traits.map((t) => t.name).join(', ')}',
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton(
                            onPressed: () =>
                                controller.togglePlayingXI(player.id),
                            child: Text(
                              player.inPlayingXI
                                  ? 'Move to Bench'
                                  : 'Move to XI',
                            ),
                          ),
                          OutlinedButton(
                            onPressed: () =>
                                controller.trainPlayer(player.id, 'Batting'),
                            child: const Text('Train Batting (-0.35)'),
                          ),
                          OutlinedButton(
                            onPressed: () =>
                                controller.trainPlayer(player.id, 'Bowling'),
                            child: const Text('Train Bowling (-0.35)'),
                          ),
                          OutlinedButton(
                            onPressed: () =>
                                controller.trainPlayer(player.id, 'Mental'),
                            child: const Text('Mental Coaching (-0.35)'),
                          ),
                          OutlinedButton(
                            onPressed: () =>
                                controller.trainPlayer(player.id, 'Fitness'),
                            child: const Text('Fitness Block (-0.35)'),
                          ),
                          OutlinedButton(
                            onPressed: player.inPlayingXI || player.injured
                                ? null
                                : () =>
                                      controller.setImpactCandidate(player.id),
                            child: const Text('Set as Impact Player'),
                          ),
                          OutlinedButton(
                            onPressed:
                                controller.selectedImpactPlayer?.id == player.id
                                ? () => controller.setImpactCandidate(null)
                                : null,
                            child: const Text('Clear Impact'),
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
