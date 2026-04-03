import 'dart:math';

import 'package:flutter/material.dart';

import '../game/game_controller.dart';
import '../game/game_scope.dart';
import '../game/models.dart';
import '../services/iap_scope.dart';
import '../services/iap_service.dart';
import '../widgets/stat_card.dart';
import '../widgets/team_badge.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  int fanTab = 0; // 0 my fans, 1 leaderboard
  bool showAllTimeTrend = true;
  bool showCareerFanRevenue = false;

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final iap = IapScope.of(context);
    final ledger = controller.financeLedger;

    final income = ledger
        .where((e) => e.amountCr > 0)
        .fold<double>(0, (a, b) => a + b.amountCr);
    final expense = ledger
        .where((e) => e.amountCr < 0)
        .fold<double>(0, (a, b) => a + b.amountCr.abs());

    final fanRows = controller.fanMovementSeason.entries.toList()
      ..sort((a, b) => b.value.abs().compareTo(a.value.abs()));
    final trend = showAllTimeTrend
        ? controller.fanTrendCareer
        : controller.fanTrendSeason;
    final fanCountL = controller.userTeam.fans / 100000;

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
        ListenableBuilder(
          listenable: iap,
          builder: (context, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!controller.adsRemoved)
                  _OwnersPackCard(controller: controller, iap: iap),
                if (controller.adsRemoved)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xFF0E3023),
                      border: Border.all(color: const Color(0xFF2AB77D)),
                    ),
                    child: const Text(
                      'Owner\'s Pack active • Ads removed • All facilities maxed',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF84F5C2),
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
                _CashPackRow(controller: controller, iap: iap),
                if (iap.lastError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    iap.lastError!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            );
          },
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
                  'Fans',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                _BinaryTab(
                  left: 'My Fans',
                  right: 'Leaderboard',
                  leftSelected: fanTab == 0,
                  onLeft: () => setState(() => fanTab = 0),
                  onRight: () => setState(() => fanTab = 1),
                ),
                const SizedBox(height: 12),
                if (fanTab == 0) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Theme.of(context).colorScheme.surfaceContainerLow,
                    ),
                    child: Row(
                      children: [
                        Text(
                          '${fanCountL.toStringAsFixed(2)}L',
                          style: const TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'fans\n${controller.fanMovementNet >= 0 ? '↑' : '↓'} ${controller.fanMovementNet.abs()} this season',
                            style: TextStyle(
                              color: controller.fanMovementNet >= 0
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Theme.of(context).colorScheme.surfaceContainerLow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Fan Trend',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const Spacer(),
                            _BinaryTab(
                              left: 'Season',
                              right: 'All Time',
                              leftSelected: !showAllTimeTrend,
                              compact: true,
                              onLeft: () =>
                                  setState(() => showAllTimeTrend = false),
                              onRight: () =>
                                  setState(() => showAllTimeTrend = true),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 200,
                          child: _FanTrendChart(values: trend),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerLow,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('AVG ATTENDANCE'),
                              Text(
                                '${(22000 + controller.facilityLevel('stadium') * 11000)}',
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerLow,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('OCCUPANCY'),
                              const SizedBox(height: 12),
                              LinearProgressIndicator(
                                value: min(
                                  1,
                                  (controller.userTeam.fans / 100000),
                                ),
                                minHeight: 8,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${min(100, ((controller.userTeam.fans / 100000) * 100).round())}%',
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Theme.of(context).colorScheme.surfaceContainerLow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Financial Impact',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const Spacer(),
                            _BinaryTab(
                              left: 'Season',
                              right: 'Career',
                              compact: true,
                              leftSelected: !showCareerFanRevenue,
                              onLeft: () =>
                                  setState(() => showCareerFanRevenue = false),
                              onRight: () =>
                                  setState(() => showCareerFanRevenue = true),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '+${(showCareerFanRevenue ? controller.fanRevenueCareerCr : controller.fanRevenueSeasonCr).toStringAsFixed(1)} Cr',
                          style: const TextStyle(
                            fontSize: 52,
                            color: Color(0xFF39C97A),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Text('earned from fans'),
                      ],
                    ),
                  ),
                ],
                if (fanTab == 1) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Theme.of(context).colorScheme.surfaceContainerLow,
                    ),
                    child: const Text(
                      'Live fan totals\nSeason change shows fan movement since start.',
                    ),
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
                          border: i == 0
                              ? Border.all(
                                  color: Theme.of(context).colorScheme.primary,
                                )
                              : null,
                        ),
                        child: ListTile(
                          leading: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${i + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 24,
                                ),
                              ),
                              const SizedBox(width: 8),
                              TeamBadge(
                                branding:
                                    controller.fanLeaderboard[i]['branding']
                                        as TeamBranding,
                                size: 30,
                              ),
                            ],
                          ),
                          title: Text(
                            controller.fanLeaderboard[i]['team'] as String,
                          ),
                          subtitle: Text(
                            '${(controller.fanLeaderboard[i]['delta'] as int) >= 0 ? '↑' : '↓'} ${(controller.fanLeaderboard[i]['delta'] as int).abs()}',
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
                            '${((controller.fanLeaderboard[i]['fans'] as int) / 100000).toStringAsFixed(2)}L',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 28,
                            ),
                          ),
                        ),
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

class _OwnersPackCard extends StatelessWidget {
  const _OwnersPackCard({required this.controller, required this.iap});

  final GameController controller;
  final IapService iap;

  @override
  Widget build(BuildContext context) {
    final canBuy = iap.storeAvailable && !iap.loading;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF102D1F), Color(0xFF1C4D34)],
        ),
        border: Border.all(color: const Color(0xFF2AB77D)),
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
            style: TextStyle(color: Color(0xFFB8E7D1)),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF36D399),
                foregroundColor: const Color(0xFF03281B),
              ),
              onPressed: canBuy
                  ? () => iap.buyProduct(IapService.ownersPackId)
                  : null,
              child: Text(iap.displayPrice(IapService.ownersPackId)),
            ),
          ),
          if (!iap.storeAvailable) ...[
            const SizedBox(height: 6),
            const Text(
              'Play Billing unavailable here. Use Android/iOS build.',
              style: TextStyle(color: Color(0xFFAEE5CF), fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

class _CashPackRow extends StatelessWidget {
  const _CashPackRow({required this.controller, required this.iap});

  final GameController controller;
  final IapService iap;

  @override
  Widget build(BuildContext context) {
    final packs = IapService.catalog.where((c) => c.cashCr > 0).toList();
    return Column(
      children: [
        for (final pack in packs)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                colors: [Color(0xFF0F251A), Color(0xFF15412C)],
              ),
              border: Border.all(color: const Color(0xFF248B62)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pack.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '+₹${pack.cashCr.toStringAsFixed(0)} Cr auction budget',
                        style: const TextStyle(color: Color(0xFFA9DFC7)),
                      ),
                    ],
                  ),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF5DE2A7),
                    foregroundColor: const Color(0xFF053324),
                  ),
                  onPressed: iap.storeAvailable && !iap.loading
                      ? () => iap.buyProduct(pack.id)
                      : null,
                  child: Text(iap.displayPrice(pack.id)),
                ),
              ],
            ),
          ),
        if (iap.storeAvailable && !controller.adsRemoved)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: iap.restorePurchases,
              child: const Text('Restore purchases'),
            ),
          ),
      ],
    );
  }
}

class _BinaryTab extends StatelessWidget {
  const _BinaryTab({
    required this.left,
    required this.right,
    required this.leftSelected,
    required this.onLeft,
    required this.onRight,
    this.compact = false,
  });

  final String left;
  final String right;
  final bool leftSelected;
  final VoidCallback onLeft;
  final VoidCallback onRight;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final height = compact ? 34.0 : 42.0;
    return Container(
      height: height,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Row(
        mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
        children: [
          _TabCell(
            label: left,
            selected: leftSelected,
            onTap: onLeft,
            compact: compact,
          ),
          _TabCell(
            label: right,
            selected: !leftSelected,
            onTap: onRight,
            compact: compact,
          ),
        ],
      ),
    );
  }
}

class _TabCell extends StatelessWidget {
  const _TabCell({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.compact,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: compact ? 0 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: compact ? 82 : null,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: selected ? Theme.of(context).colorScheme.surface : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: selected
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
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
      color: const Color(0xFF0E1F17),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title.toUpperCase(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF87E8BE),
              ),
            ),
            const SizedBox(height: 6),
            Text(description, style: const TextStyle(color: Color(0xFF9BCDB8))),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Lvl $level/$maxLevel',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFBEEFD8),
                    ),
                  ),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: maxed
                        ? const Color(0xFF2C3A34)
                        : const Color(0xFF2AB77D),
                    foregroundColor: maxed
                        ? const Color(0xFFB0BBB6)
                        : const Color(0xFF06281C),
                  ),
                  onPressed: maxed ? null : onTap,
                  child: Text(cta),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FanTrendChart extends StatelessWidget {
  const _FanTrendChart({required this.values});

  final List<int> values;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _FanTrendPainter(values),
      child: const SizedBox.expand(),
    );
  }
}

class _FanTrendPainter extends CustomPainter {
  _FanTrendPainter(this.values);

  final List<int> values;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(10)),
      Paint()..color = const Color(0x0BFFFFFF),
    );

    if (values.length < 2) {
      return;
    }

    final minVal = values.reduce(min).toDouble();
    final maxVal = values.reduce(max).toDouble();
    final range = (maxVal - minVal).abs() < 1 ? 1 : (maxVal - minVal);

    final left = 36.0;
    final right = 10.0;
    final top = 10.0;
    final bottom = 24.0;
    final chart = Rect.fromLTWH(
      left,
      top,
      size.width - left - right,
      size.height - top - bottom,
    );

    final grid = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 1;
    for (int i = 0; i <= 5; i++) {
      final y = chart.top + chart.height * (i / 5);
      canvas.drawLine(Offset(chart.left, y), Offset(chart.right, y), grid);
    }
    for (int i = 0; i <= 10; i++) {
      final x = chart.left + chart.width * (i / 10);
      canvas.drawLine(Offset(x, chart.top), Offset(x, chart.bottom), grid);
    }

    final line = Paint()
      ..color = const Color(0xFF3F8CFF)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final fill = Paint()
      ..color = const Color(0x223F8CFF)
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();
    for (int i = 0; i < values.length; i++) {
      final dx = chart.left + (i / (values.length - 1)) * chart.width;
      final dy = chart.bottom - ((values[i] - minVal) / range) * chart.height;
      if (i == 0) {
        path.moveTo(dx, dy);
        fillPath.moveTo(dx, chart.bottom);
        fillPath.lineTo(dx, dy);
      } else {
        path.lineTo(dx, dy);
        fillPath.lineTo(dx, dy);
      }
    }
    fillPath.lineTo(chart.right, chart.bottom);
    fillPath.close();

    canvas.drawPath(fillPath, fill);
    canvas.drawPath(path, line);

    final labels = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i <= 4; i++) {
      final value = minVal + ((4 - i) / 4) * range;
      labels.text = TextSpan(
        text: '${(value / 100000).toStringAsFixed(1)}L',
        style: const TextStyle(fontSize: 10, color: Colors.white70),
      );
      labels.layout();
      final y = chart.top + chart.height * (i / 4);
      labels.paint(canvas, Offset(2, y - labels.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _FanTrendPainter oldDelegate) {
    return oldDelegate.values != values;
  }
}
