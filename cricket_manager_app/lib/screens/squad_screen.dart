import 'package:flutter/material.dart';

import '../game/game_controller.dart';
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
  int tab = 0; // 0 players, 1 academy

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
          'Team',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${controller.userTeam.name} • Academy ${controller.academyTierLabel}',
          style: const TextStyle(color: Color(0xFF9AA4B2)),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFF171A1F),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF252B33)),
          ),
          child: Row(
            children: [
              _tabCell(
                label: 'Players',
                selected: tab == 0,
                onTap: () => setState(() => tab = 0),
              ),
              _tabCell(
                label: 'Academy',
                selected: tab == 1,
                onTap: () => setState(() => tab = 1),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (tab == 0) ...[
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
          const SizedBox(height: 10),
          Container(
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
                  'SQUAD (${controller.userTeam.squad.length})',
                  style: const TextStyle(
                    color: Color(0xFFD0D5DD),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                for (final player in squad)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: player.id == selectedPlayerId
                          ? const Color(0xFF2A221F)
                          : const Color(0xFF101418),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: player.id == selectedPlayerId
                            ? const Color(0xFFFB8B5E)
                            : const Color(0xFF202833),
                      ),
                    ),
                    child: ListTile(
                      onTap: () => setState(() => selectedPlayerId = player.id),
                      dense: true,
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF2A3039),
                        child: Text(
                          _grade(player.overall),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      title: Text(
                        player.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        '${player.role.label} • Age ${player.age} • OVR ${player.overall}',
                        style: const TextStyle(color: Color(0xFF9AA4B2)),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₹${player.salaryCr.toStringAsFixed(1)} Cr',
                            style: const TextStyle(color: Color(0xFFE6ECF3)),
                          ),
                          Text(
                            player.inPlayingXI ? 'XI' : 'Bench',
                            style: TextStyle(
                              color: player.inPlayingXI
                                  ? const Color(0xFF57D986)
                                  : const Color(0xFF9AA4B2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          if (selected != null)
            _playerControls(controller: controller, player: selected),
        ],
        if (tab == 1) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF171A1F),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF252B33)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ACADEMY TIERS',
                  style: const TextStyle(
                    color: Color(0xFFD0D5DD),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  controller.academyTierLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Level ${controller.academyLevel}/${controller.academyMaxLevel} • Promotion cost ₹${controller.academyPromotionCost.toStringAsFixed(2)} Cr',
                  style: const TextStyle(color: Color(0xFF9AA4B2)),
                ),
                const SizedBox(height: 10),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF57D986),
                    foregroundColor: const Color(0xFF0F2A1C),
                  ),
                  onPressed:
                      controller.academyLevel >= controller.academyMaxLevel
                      ? null
                      : controller.upgradeAcademy,
                  child: Text(
                    controller.academyLevel >= controller.academyMaxLevel
                        ? 'Academy Maxed'
                        : 'Upgrade Academy • ₹${controller.academyUpgradeCost.toStringAsFixed(1)} Cr',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF171A1F),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF252B33)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'YOUTH PROSPECTS',
                  style: TextStyle(
                    color: Color(0xFFD0D5DD),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                for (final prospect in controller.youthAcademy)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF101418),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF202833)),
                    ),
                    child: ListTile(
                      dense: true,
                      title: Text(
                        prospect.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        'Age ${prospect.age} • ${prospect.role.label} • OVR ${prospect.overall}',
                        style: const TextStyle(color: Color(0xFF9AA4B2)),
                      ),
                      trailing: OutlinedButton(
                        onPressed: () =>
                            controller.promoteYouthPlayer(prospect.id),
                        child: const Text('Promote'),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _tabCell({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          alignment: Alignment.center,
          height: 38,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: selected ? const Color(0xFF2C333D) : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : const Color(0xFF9AA4B2),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _playerControls({
    required GameController controller,
    required Player player,
  }) {
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
            '${player.name} Control',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Traits: ${player.traits.map((t) => t.name).join(', ')}',
            style: const TextStyle(color: Color(0xFF9AA4B2)),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: () => controller.togglePlayingXI(player.id),
                child: Text(
                  player.inPlayingXI ? 'Move to Bench' : 'Move to XI',
                ),
              ),
              OutlinedButton(
                onPressed: () => controller.trainPlayer(player.id, 'Batting'),
                child: const Text('Batting'),
              ),
              OutlinedButton(
                onPressed: () => controller.trainPlayer(player.id, 'Bowling'),
                child: const Text('Bowling'),
              ),
              OutlinedButton(
                onPressed: () => controller.trainPlayer(player.id, 'Mental'),
                child: const Text('Mental'),
              ),
              OutlinedButton(
                onPressed: () => controller.trainPlayer(player.id, 'Fitness'),
                child: const Text('Fitness'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _grade(int overall) {
    if (overall >= 88) return 'A+';
    if (overall >= 82) return 'A';
    if (overall >= 76) return 'B+';
    if (overall >= 70) return 'B';
    if (overall >= 64) return 'C';
    return 'D';
  }
}
