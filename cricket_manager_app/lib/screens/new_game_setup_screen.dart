import 'package:flutter/material.dart';

import '../game/game_controller.dart';
import '../game/game_scope.dart';
import '../game/models.dart';
import '../widgets/team_badge.dart';

class NewGameSetupScreen extends StatefulWidget {
  const NewGameSetupScreen({
    super.key,
    required this.onCancel,
    required this.onComplete,
  });

  final VoidCallback onCancel;
  final VoidCallback onComplete;

  @override
  State<NewGameSetupScreen> createState() => _NewGameSetupScreenState();
}

class _NewGameSetupScreenState extends State<NewGameSetupScreen> {
  int step = 0;
  String? selectedTeam;
  String? selectedCaptainId;

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final teams = GameController.defaultTeamBrandings.keys.toList();
    teams.sort();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (step == 0) _teamStep(controller, teams),
                  if (step == 1) _introStep(),
                  if (step == 2) _captainStep(controller),
                  if (step == 3) _planStep(),
                ],
              ),
            ),
            _bottomBar(controller),
          ],
        ),
      ),
    );
  }

  Widget _teamStep(GameController controller, List<String> teams) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: widget.onCancel,
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            const Text(
              'New Game',
              style: TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Choose your franchise',
          style: TextStyle(color: Color(0xFF9AA4B2), fontSize: 22),
        ),
        const SizedBox(height: 12),
        for (int i = 0; i < teams.length; i++)
          _teamRow(controller, teams[i], i),
      ],
    );
  }

  Widget _teamRow(GameController controller, String teamName, int index) {
    final selected = selectedTeam == teamName;
    final tier = switch (index) {
      0 || 1 || 2 => ('Contender', Color(0xFF1E5C3D)),
      3 || 4 || 5 || 6 => ('Mid-table', Color(0xFF5B4720)),
      _ => ('Underdog', Color(0xFF5B2327)),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF151A22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? const Color(0xFFFB8B5E) : const Color(0xFF252B33),
        ),
      ),
      child: ListTile(
        onTap: () => setState(() => selectedTeam = teamName),
        leading: TeamBadge(
          branding: controller.teamBrandingFor(teamName),
          size: 38,
        ),
        title: Text(
          teamName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 26,
          ),
        ),
        subtitle: Text(
          'Home city franchise',
          style: const TextStyle(color: Color(0xFF9AA4B2)),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: tier.$2,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            tier.$1,
            style: const TextStyle(
              color: Color(0xFFE8EEF5),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _introStep() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'The franchise awaits,\nChairman.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 42,
            height: 0.95,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 200),
        Text(
          'Shape the squad.\nCall the shots.\nChase the title.',
          style: TextStyle(
            color: Color(0xFFFB8B5E),
            fontSize: 34,
            height: 1.18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _captainStep(GameController controller) {
    final players = List<Player>.of(controller.userTeam.squad)
      ..sort((a, b) => b.overall.compareTo(a.overall));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose Your Captain',
          style: TextStyle(
            color: Colors.white,
            fontSize: 38,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Captain gives +5% morale impact in close matches.',
          style: TextStyle(color: Color(0xFF9AA4B2), fontSize: 20),
        ),
        const SizedBox(height: 12),
        for (final player in players.take(10))
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF151A22),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selectedCaptainId == player.id
                    ? const Color(0xFFF1BF15)
                    : const Color(0xFF252B33),
              ),
            ),
            child: ListTile(
              onTap: () => setState(() => selectedCaptainId = player.id),
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
              trailing: selectedCaptainId == player.id
                  ? const Icon(Icons.check_circle, color: Color(0xFFF1BF15))
                  : Text(
                      '₹${player.salaryCr.toStringAsFixed(1)} Cr',
                      style: const TextStyle(color: Color(0xFFD5DDE7)),
                    ),
            ),
          ),
      ],
    );
  }

  Widget _planStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Game Plan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 42,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 16),
        _planCard(
          'Set Your XI',
          'Pick your lineup and batting order.',
          Icons.groups_rounded,
        ),
        _planCard(
          'Watch the Bench',
          'Fitness drops, morale shifts, injuries happen.',
          Icons.favorite_outline,
        ),
        _planCard(
          'Chase the Title',
          'Top 4 make playoffs. One team lifts the trophy.',
          Icons.emoji_events_outlined,
        ),
        _planCard(
          'Reshape at Auction',
          'Bid between seasons and build your next squad.',
          Icons.gavel,
        ),
      ],
    );
  }

  Widget _planCard(String title, String subtitle, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF151A22),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF252B33)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFB8B5E)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Color(0xFF9AA4B2)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomBar(GameController controller) {
    return Container(
      color: const Color(0xFF0C0F14),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      child: Row(
        children: [
          if (step > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => step -= 1),
                child: const Text('Back'),
              ),
            ),
          if (step > 0) const SizedBox(width: 10),
          Expanded(
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFF46A2F),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(54),
              ),
              onPressed: () {
                if (step == 0) {
                  if (selectedTeam == null) return;
                  controller.chooseFranchiseFromTemplate(selectedTeam!);
                  setState(() => step = 1);
                  return;
                }
                if (step == 1) {
                  setState(() => step = 2);
                  return;
                }
                if (step == 2) {
                  if (selectedCaptainId == null) return;
                  controller.setClubCaptain(selectedCaptainId!);
                  setState(() => step = 3);
                  return;
                }
                widget.onComplete();
              },
              child: Text(
                step == 3 ? 'Take Charge' : (step == 0 ? 'Start Game' : 'Next'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
