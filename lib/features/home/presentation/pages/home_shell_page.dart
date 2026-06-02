import 'package:act_for_earth/features/leaderboard/domain/leaderboard_entry.dart';
import 'package:act_for_earth/features/leaderboard/presentation/widgets/leaderboard_entry_dialog.dart';
import 'package:act_for_earth/features/leaderboard/presentation/pages/leaderboard_page.dart';
import 'package:act_for_earth/features/rewards/domain/reward_item.dart';
import 'package:act_for_earth/features/rewards/presentation/pages/reward_page.dart';
import 'package:flutter/material.dart';

class HomeShellPage extends StatefulWidget {
  const HomeShellPage({super.key});

  @override
  State<HomeShellPage> createState() => _HomeShellPageState();
}

class _HomeShellPageState extends State<HomeShellPage> {
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
    const LeaderboardEntry(name: 'You', points: 120),
    const LeaderboardEntry(name: 'Alya', points: 150),
    const LeaderboardEntry(name: 'Raka', points: 95),
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
    final result = await showDialog<LeaderboardFormResult>(
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
    final result = await showDialog<LeaderboardFormResult>(
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
  const EcoNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

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
