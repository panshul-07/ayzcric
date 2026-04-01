import 'package:flutter/material.dart';

import '../game/game_scope.dart';
import '../game/models.dart';

class CareerScreen extends StatelessWidget {
  const CareerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Career & Board',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text('Long-term progression, format strategy, and board trust.'),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Season ${controller.seasonYear}',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text('Trophies: ${controller.userTeam.trophies}'),
                Text('Matches remaining: ${controller.matchesRemaining}'),
                const SizedBox(height: 10),
                DropdownButtonFormField<MatchFormat>(
                  initialValue: controller.matchFormat,
                  decoration: const InputDecoration(
                    labelText: 'Primary Match Format',
                  ),
                  items: MatchFormat.values
                      .map(
                        (f) => DropdownMenuItem(
                          value: f,
                          child: Text(
                            '${f.label} (${f.oversPerInnings} overs)',
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (format) {
                    if (format != null) controller.setFormat(format);
                  },
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: controller.seasonComplete
                      ? controller.advanceSeason
                      : null,
                  icon: const Icon(Icons.skip_next),
                  label: const Text('Advance to Next Season'),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: controller.triggerDynamicEvent,
                      icon: const Icon(Icons.bolt),
                      label: const Text('Trigger Dynamic Event'),
                    ),
                    if (controller.fired)
                      FilledButton.icon(
                        onPressed: controller.restartCareer,
                        icon: const Icon(Icons.restart_alt),
                        label: const Text('Restart Career'),
                      ),
                  ],
                ),
                if (!controller.seasonComplete)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text('Complete all fixtures before advancing.'),
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
                  'Youth Academy',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Promote 15-18 year-old prospects into your senior squad.',
                ),
                const SizedBox(height: 10),
                for (final prospect in controller.youthAcademy)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('${prospect.name} (${prospect.role.label})'),
                    subtitle: Text(
                      'Age ${prospect.age} | OVR ${prospect.overall} | Potential traits: ${prospect.traits.map((t) => t.name).join(', ')}',
                    ),
                    trailing: OutlinedButton(
                      onPressed: () =>
                          controller.promoteYouthPlayer(prospect.id),
                      child: const Text('Promote'),
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
                  'Board Trust Objectives',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                for (final objective in controller.objectives)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          objective.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(objective.description),
                        const SizedBox(height: 6),
                        LinearProgressIndicator(
                          value: (objective.current / objective.target).clamp(
                            0,
                            1,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${objective.current}/${objective.target} ${objective.completed ? 'Complete' : ''}',
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
                  'Career Log',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                if (controller.careerLog.isEmpty)
                  const Text('No events yet.')
                else
                  SizedBox(
                    height: 320,
                    child: ListView.builder(
                      itemCount: controller.careerLog.length,
                      itemBuilder: (context, index) => ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.history),
                        title: Text(controller.careerLog[index]),
                      ),
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
