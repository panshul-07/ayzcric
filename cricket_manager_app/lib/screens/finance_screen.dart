import 'package:flutter/material.dart';

import '../game/game_scope.dart';
import '../widgets/stat_card.dart';

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final ledger = controller.financeLedger;

    final income = ledger
        .where((e) => e.amountCr > 0)
        .fold<double>(0, (a, b) => a + b.amountCr);
    final expense = ledger
        .where((e) => e.amountCr < 0)
        .fold<double>(0, (a, b) => a + b.amountCr.abs());

    final fanRows = controller.fanMovementSeason.entries.toList()
      ..sort((a, b) => b.value.abs().compareTo(a.value.abs()));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Facilities',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text('₹${controller.userTeam.cashCr.toStringAsFixed(1)} Cr'),
        const SizedBox(height: 12),
        if (!controller.adsRemoved)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Color(0xFF33240F), Color(0xFF5A3D13)],
              ),
              border: Border.all(color: const Color(0xFFC39B2E)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Owner\'s Pack',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Max all facilities + ₹20 Cr bonus + remove ads',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFF4BE2A),
                      foregroundColor: Colors.black,
                    ),
                    onPressed: controller.buyOwnersPack,
                    child: const Text('₹9.50 Cr'),
                  ),
                ),
              ],
            ),
          ),
        if (controller.adsRemoved)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.secondaryContainer,
            ),
            child: const Text(
              'Owner\'s Pack active • Ads removed • All facilities maxed',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        const SizedBox(height: 14),
        _FacilityCard(
          title: 'Stadium',
          description:
              'More seats means bigger crowds and higher gate receipts.',
          level: controller.facilityLevel('stadium'),
          maxLevel: controller.facilityMaxLevel('stadium'),
          cta:
              controller.facilityLevel('stadium') >=
                  controller.facilityMaxLevel('stadium')
              ? 'Maxed'
              : 'Upgrade ₹${controller.facilityUpgradeCost('stadium').toStringAsFixed(1)} Cr',
          onTap: () => controller.upgradeFacility('stadium'),
        ),
        const SizedBox(height: 10),
        _FacilityCard(
          title: 'Training',
          description: 'Better facilities help players develop faster.',
          level: controller.facilityLevel('training'),
          maxLevel: controller.facilityMaxLevel('training'),
          cta:
              controller.facilityLevel('training') >=
                  controller.facilityMaxLevel('training')
              ? 'Maxed'
              : 'Upgrade ₹${controller.facilityUpgradeCost('training').toStringAsFixed(1)} Cr',
          onTap: () => controller.upgradeFacility('training'),
        ),
        const SizedBox(height: 10),
        _FacilityCard(
          title: 'Medical',
          description: 'Reduces injuries and restores player fitness quicker.',
          level: controller.facilityLevel('medical'),
          maxLevel: controller.facilityMaxLevel('medical'),
          cta:
              controller.facilityLevel('medical') >=
                  controller.facilityMaxLevel('medical')
              ? 'Maxed'
              : 'Upgrade ₹${controller.facilityUpgradeCost('medical').toStringAsFixed(1)} Cr',
          onTap: () => controller.upgradeFacility('medical'),
        ),
        const SizedBox(height: 10),
        _FacilityCard(
          title: 'Scouting',
          description:
              'Unlock better talent visibility in auction and youth pool.',
          level: controller.facilityLevel('scouting'),
          maxLevel: controller.facilityMaxLevel('scouting'),
          cta:
              controller.facilityLevel('scouting') >=
                  controller.facilityMaxLevel('scouting')
              ? 'Maxed'
              : 'Upgrade ₹${controller.facilityUpgradeCost('scouting').toStringAsFixed(1)} Cr',
          onTap: () => controller.upgradeFacility('scouting'),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: 180,
              child: StatCard(
                title: 'Current Cash',
                value: '₹${controller.userTeam.cashCr.toStringAsFixed(1)} Cr',
              ),
            ),
            SizedBox(
              width: 180,
              child: StatCard(
                title: 'Total Income',
                value: '₹${income.toStringAsFixed(1)} Cr',
              ),
            ),
            SizedBox(
              width: 180,
              child: StatCard(
                title: 'Total Expense',
                value: '₹${expense.toStringAsFixed(1)} Cr',
              ),
            ),
            SizedBox(
              width: 180,
              child: StatCard(
                title: 'Net Fan Swing',
                value:
                    '${controller.fanMovementNet >= 0 ? '+' : ''}${controller.fanMovementNet}',
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
                  'Fan Movement',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                for (final row in fanRows)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(child: Text(row.key)),
                        Text(
                          '${row.value >= 0 ? '+' : ''}${row.value}',
                          style: TextStyle(
                            color: row.value >= 0 ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withValues(alpha: 0.45),
                  ),
                  child: Text(
                    'Net Change ${controller.fanMovementNet >= 0 ? '+' : ''}${controller.fanMovementNet}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
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
                  'Fan Leaderboard',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                for (int i = 0; i < controller.fanLeaderboard.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerLow,
                      ),
                      child: ListTile(
                        title: Text(
                          '${i + 1}. ${controller.fanLeaderboard[i]['team']}',
                        ),
                        subtitle: Text(
                          'Δ ${controller.fanLeaderboard[i]['delta']}',
                          style: TextStyle(
                            color:
                                (controller.fanLeaderboard[i]['delta']
                                        as int) >=
                                    0
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        trailing: Text(
                          '${controller.fanLeaderboard[i]['fans']} fans',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
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
                  'Ledger',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                if (ledger.isEmpty)
                  const Text('No finance activity yet.')
                else
                  SizedBox(
                    height: 320,
                    child: ListView.builder(
                      itemCount: ledger.length,
                      itemBuilder: (context, index) {
                        final entry = ledger[index];
                        final positive = entry.amountCr >= 0;
                        return ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            positive ? Icons.trending_up : Icons.trending_down,
                            color: positive ? Colors.green : Colors.red,
                          ),
                          title: Text(entry.title),
                          subtitle: Text(
                            '${entry.timestamp.toLocal()}'.split('.').first,
                          ),
                          trailing: Text(
                            '${positive ? '+' : '-'}₹${entry.amountCr.abs().toStringAsFixed(2)} Cr',
                            style: TextStyle(
                              color: positive ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
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
      ],
    );
  }
}

class _FacilityCard extends StatelessWidget {
  const _FacilityCard({
    required this.title,
    required this.description,
    required this.level,
    required this.maxLevel,
    required this.cta,
    required this.onTap,
  });

  final String title;
  final String description;
  final int level;
  final int maxLevel;
  final String cta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final maxed = level >= maxLevel;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title.toUpperCase(),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(description),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Lvl $level/$maxLevel',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                FilledButton(onPressed: maxed ? null : onTap, child: Text(cta)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
