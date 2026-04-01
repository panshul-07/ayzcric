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

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Finance & Infrastructure',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text('Balance short-term spend against long-term growth.'),
        const SizedBox(height: 12),
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
                title: 'Infra / Sponsor',
                value:
                    '${controller.userTeam.infraLevel} / ${controller.userTeam.sponsorLevel}',
                subtitle: '${controller.userTeam.fans} fans',
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
                  'Strategic Actions',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton.icon(
                      onPressed: controller.runMarketingCampaign,
                      icon: const Icon(Icons.campaign),
                      label: const Text('Marketing Push'),
                    ),
                    FilledButton.icon(
                      onPressed: controller.upgradeInfrastructure,
                      icon: const Icon(Icons.stadium),
                      label: const Text('Upgrade Infrastructure'),
                    ),
                    FilledButton.icon(
                      onPressed: controller.negotiateSponsor,
                      icon: const Icon(Icons.handshake),
                      label: const Text('Negotiate Sponsor'),
                    ),
                  ],
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
                    height: 360,
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
