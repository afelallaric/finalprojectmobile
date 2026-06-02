import 'package:act_for_earth/features/rewards/domain/reward_item.dart';
import 'package:act_for_earth/features/rewards/presentation/widgets/reward_card.dart';
import 'package:flutter/material.dart';

class RewardPage extends StatelessWidget {
  const RewardPage({
    super.key,
    required this.totalPoints,
    required this.rewards,
    required this.onEarnPoints,
    required this.onSpendPoints,
  });

  final int totalPoints;
  final List<RewardItem> rewards;
  final VoidCallback onEarnPoints;
  final VoidCallback onSpendPoints;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colorScheme.primary.withOpacity(0.9), colorScheme.surface],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              title: const Text('Eco Rewards'),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Card(
                  color: colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your green score',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$totalPoints points',
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: onEarnPoints,
                                icon: const Icon(Icons.add_circle_outline),
                                label: const Text('Earn 10'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: onSpendPoints,
                                icon: const Icon(Icons.remove_circle_outline),
                                label: const Text('Spend 10'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate.fixed([
                  Text(
                    'Available rewards',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final reward in rewards) ...[
                    RewardCard(reward: reward, pointsBalance: totalPoints),
                    const SizedBox(height: 12),
                  ],
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
