import 'package:flutter/material.dart';

void main() {
  runApp(const EcoHabitTrackerApp());
}

class EcoHabitTrackerApp extends StatelessWidget {
  const EcoHabitTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFF1B5E20);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Eco Habit Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
        useMaterial3: true,
      ),
      home: const EcoHomePage(),
    );
  }
}

class EcoHomePage extends StatefulWidget {
  const EcoHomePage({super.key});

  @override
  State<EcoHomePage> createState() => _EcoHomePageState();
}

class _EcoHomePageState extends State<EcoHomePage> {
  int _currentIndex = 0;
  int _totalPoints = 120;

  final List<RewardItem> _rewards = const [
    RewardItem(
      title: 'Reusable Bottle',
      description: 'Stay hydrated and reduce single-use plastic.',
      points: 50,
      icon: Icons.water_drop,
    ),
    RewardItem(
      title: 'Seed Kit',
      description: 'Start a small indoor garden at home.',
      points: 80,
      icon: Icons.spa,
    ),
    RewardItem(
      title: 'Eco Badge',
      description: 'Unlock a special badge for your profile.',
      points: 30,
      icon: Icons.emoji_events,
    ),
  ];

  final List<LeaderboardEntry> _leaderboard = [
    LeaderboardEntry(name: 'You', points: 120),
    LeaderboardEntry(name: 'Alya', points: 150),
    LeaderboardEntry(name: 'Raka', points: 95),
  ];

  void _selectPage(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _addPoints(int amount) {
    setState(() {
      _totalPoints += amount;
      _leaderboard[0] = _leaderboard[0].copyWith(points: _totalPoints);
    });
  }

  void _subtractPoints(int amount) {
    setState(() {
      _totalPoints = (_totalPoints - amount).clamp(0, 999999);
      _leaderboard[0] = _leaderboard[0].copyWith(points: _totalPoints);
    });
  }

  Future<void> _createEntry() async {
    final result = await showDialog<_LeaderboardFormResult>(
      context: context,
      builder: (context) => const LeaderboardEntryDialog(),
    );

    if (result == null) {
      return;
    }

    setState(() {
      _leaderboard.add(
        LeaderboardEntry(name: result.name, points: result.points),
      );
    });
  }

  Future<void> _editEntry(int index) async {
    final entry = _leaderboard[index];
    final result = await showDialog<_LeaderboardFormResult>(
      context: context,
      builder: (context) => LeaderboardEntryDialog(
        initialName: entry.name,
        initialPoints: entry.points,
      ),
    );

    if (result == null) {
      return;
    }

    setState(() {
      _leaderboard[index] = entry.copyWith(
        name: result.name,
        points: result.points,
      );

      if (index == 0) {
        _totalPoints = result.points;
      }
    });
  }

  void _deleteEntry(int index) {
    if (index == 0) {
      return;
    }

    setState(() {
      _leaderboard.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      RewardPage(
        totalPoints: _totalPoints,
        rewards: _rewards,
        onEarnPoints: () => _addPoints(10),
        onSpendPoints: () => _subtractPoints(10),
      ),
      LeaderboardPage(
        entries: List<LeaderboardEntry>.from(_leaderboard)
          ..sort((a, b) => b.points.compareTo(a.points)),
        onAdd: _createEntry,
        onEdit: _editEntry,
        onDelete: _deleteEntry,
      ),
    ];

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: pages[_currentIndex],
      ),
      bottomNavigationBar: EcoNavigationBar(
        currentIndex: _currentIndex,
        onTap: _selectPage,
      ),
    );
  }
}

class EcoNavigationBar extends StatelessWidget {
  const EcoNavigationBar({super.key, required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.card_giftcard_outlined),
          selectedIcon: Icon(Icons.card_giftcard),
          label: 'Rewards',
        ),
        NavigationDestination(
          icon: Icon(Icons.leaderboard_outlined),
          selectedIcon: Icon(Icons.leaderboard),
          label: 'Leaderboard',
        ),
      ],
    );
  }
}

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
            colors: [
              colorScheme.primary.withOpacity(0.9),
              colorScheme.surface,
            ],
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
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
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
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
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

class RewardCard extends StatelessWidget {
  const RewardCard({super.key, required this.reward, required this.pointsBalance});

  final RewardItem reward;
  final int pointsBalance;

  @override
  Widget build(BuildContext context) {
    final canRedeem = pointsBalance >= reward.points;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 24,
              child: Icon(reward.icon),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          reward.title,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      Chip(label: Text('${reward.points} pts')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(reward.description),
                  const SizedBox(height: 12),
                  Text(
                    canRedeem ? 'Ready to redeem' : 'Keep tracking habits to unlock this reward',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({
    super.key,
    required this.entries,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  final List<LeaderboardEntry> entries;
  final VoidCallback onAdd;
  final ValueChanged<int> onEdit;
  final ValueChanged<int> onDelete;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Leaderboard CRUD',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                FilledButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Manage user points locally for the leaderboard.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: entries.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text('${index + 1}'),
                      ),
                      title: Text(entry.name),
                      subtitle: Text('${entry.points} points'),
                      trailing: Wrap(
                        spacing: 8,
                        children: [
                          IconButton(
                            onPressed: () => onEdit(index),
                            icon: const Icon(Icons.edit_outlined),
                            tooltip: 'Edit points',
                          ),
                          IconButton(
                            onPressed: index == 0 ? null : () => onDelete(index),
                            icon: const Icon(Icons.delete_outline),
                            tooltip: 'Delete entry',
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
    );
  }
}

class LeaderboardEntryDialog extends StatefulWidget {
  const LeaderboardEntryDialog({super.key, this.initialName = '', this.initialPoints = 0});

  final String initialName;
  final int initialPoints;

  @override
  State<LeaderboardEntryDialog> createState() => _LeaderboardEntryDialogState();
}

class _LeaderboardEntryDialogState extends State<LeaderboardEntryDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _pointsController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _pointsController = TextEditingController(text: widget.initialPoints.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    final points = int.tryParse(_pointsController.text.trim());

    if (name.isEmpty || points == null) {
      return;
    }

    Navigator.of(context).pop(
      _LeaderboardFormResult(name: name, points: points),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Leaderboard entry'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _pointsController,
            decoration: const InputDecoration(labelText: 'Points'),
            keyboardType: TextInputType.number,
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class RewardItem {
  const RewardItem({
    required this.title,
    required this.description,
    required this.points,
    required this.icon,
  });

  final String title;
  final String description;
  final int points;
  final IconData icon;
}

class LeaderboardEntry {
  const LeaderboardEntry({required this.name, required this.points});

  final String name;
  final int points;

  LeaderboardEntry copyWith({String? name, int? points}) {
    return LeaderboardEntry(
      name: name ?? this.name,
      points: points ?? this.points,
    );
  }
}

class _LeaderboardFormResult {
  const _LeaderboardFormResult({required this.name, required this.points});

  final String name;
  final int points;
}
