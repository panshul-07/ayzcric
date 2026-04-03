import 'package:flutter/material.dart';

import '../game/game_scope.dart';
import '../game/models.dart';
import '../widgets/team_badge.dart';

class FranchiseEditorScreen extends StatefulWidget {
  const FranchiseEditorScreen({super.key});

  @override
  State<FranchiseEditorScreen> createState() => _FranchiseEditorScreenState();
}

class _FranchiseEditorScreenState extends State<FranchiseEditorScreen> {
  late TextEditingController franchiseController;
  late TextEditingController suffixController;
  late TextEditingController abbrController;

  late TeamBadgeShape shape;
  late TeamBadgePattern pattern;
  late TeamBadgeEmblem emblem;
  late int primaryColor;
  late int secondaryColor;
  late int accentColor;
  bool _initialized = false;

  static const List<int> palette = [
    0xFF1E88E5,
    0xFFFBC02D,
    0xFFD32F2F,
    0xFF8E24AA,
    0xFFEF6C00,
    0xFF00897B,
    0xFF455A64,
    0xFFE53935,
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final c = GameScope.of(context);
    franchiseController = TextEditingController(text: c.teamFranchise);
    suffixController = TextEditingController(text: c.teamSuffix);
    abbrController = TextEditingController(text: c.teamAbbreviation);
    shape = c.userTeam.branding.shape;
    pattern = c.userTeam.branding.pattern;
    emblem = c.userTeam.branding.emblem;
    primaryColor = c.userTeam.branding.primaryColor;
    secondaryColor = c.userTeam.branding.secondaryColor;
    accentColor = c.userTeam.branding.accentColor;
    _initialized = true;
  }

  @override
  void dispose() {
    franchiseController.dispose();
    suffixController.dispose();
    abbrController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final branding = TeamBranding(
      shape: shape,
      pattern: pattern,
      emblem: emblem,
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      accentColor: accentColor,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Current Save')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: franchiseController,
                          decoration: const InputDecoration(
                            labelText: 'Franchise',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: suffixController,
                          decoration: const InputDecoration(
                            labelText: 'Suffix',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: abbrController,
                    decoration: const InputDecoration(
                      labelText: 'Abbreviation',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Center(child: TeamBadge(branding: branding, size: 140)),
          const SizedBox(height: 12),
          _EnumSegment<TeamBadgeShape>(
            title: 'Shape',
            values: TeamBadgeShape.values,
            current: shape,
            label: (v) => v.name,
            onChanged: (v) => setState(() => shape = v),
          ),
          const SizedBox(height: 10),
          _EnumSegment<TeamBadgePattern>(
            title: 'Pattern',
            values: TeamBadgePattern.values,
            current: pattern,
            label: (v) => v.name,
            onChanged: (v) => setState(() => pattern = v),
          ),
          const SizedBox(height: 10),
          _EnumSegment<TeamBadgeEmblem>(
            title: 'Emblem',
            values: TeamBadgeEmblem.values,
            current: emblem,
            label: (v) => v.name,
            onChanged: (v) => setState(() => emblem = v),
          ),
          const SizedBox(height: 10),
          Text('Primary Color', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          _ColorPalette(
            colors: palette,
            value: primaryColor,
            onTap: (c) => setState(() => primaryColor = c),
          ),
          const SizedBox(height: 10),
          Text(
            'Secondary Color',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          _ColorPalette(
            colors: palette,
            value: secondaryColor,
            onTap: (c) => setState(() => secondaryColor = c),
          ),
          const SizedBox(height: 10),
          Text('Accent Color', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          _ColorPalette(
            colors: palette,
            value: accentColor,
            onTap: (c) => setState(() => accentColor = c),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              controller.saveFranchiseIdentity(
                franchise: franchiseController.text,
                suffix: suffixController.text,
                abbreviation: abbrController.text,
                branding: branding,
              );
              Navigator.of(context).pop();
            },
            child: const Text('Save to Current Save'),
          ),
        ],
      ),
    );
  }
}

class _EnumSegment<T> extends StatelessWidget {
  const _EnumSegment({
    required this.title,
    required this.values,
    required this.current,
    required this.label,
    required this.onChanged,
  });

  final String title;
  final List<T> values;
  final T current;
  final String Function(T value) label;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final value in values)
              ChoiceChip(
                label: Text(label(value)),
                selected: value == current,
                onSelected: (_) => onChanged(value),
              ),
          ],
        ),
      ],
    );
  }
}

class _ColorPalette extends StatelessWidget {
  const _ColorPalette({
    required this.colors,
    required this.value,
    required this.onTap,
  });

  final List<int> colors;
  final int value;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final color in colors)
          InkWell(
            onTap: () => onTap(color),
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(color),
                border: Border.all(
                  color: value == color
                      ? Colors.white
                      : Colors.black.withValues(alpha: 0.2),
                  width: value == color ? 3 : 1,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
