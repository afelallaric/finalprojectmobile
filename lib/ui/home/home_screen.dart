import 'dart:async';

import 'package:act_for_earth/data/remote/leaderboard_firestore_service.dart';
import 'package:act_for_earth/domain/model/leaderboard_entry.dart';
import 'package:act_for_earth/domain/model/reward_item.dart';
import 'package:act_for_earth/domain/model/user_model.dart';
import 'package:act_for_earth/domain/repository/auth_repository.dart';
import 'package:act_for_earth/domain/repository/habit_repository.dart';
import 'package:act_for_earth/ui/challenges/challenges_screen.dart';
import 'package:act_for_earth/ui/habit_list/habit_list_screen.dart';
import 'package:act_for_earth/ui/habit_list/habit_list_viewmodel.dart';
import 'package:act_for_earth/ui/leaderboard/leaderboard_screen.dart';
import 'package:act_for_earth/ui/leaderboard/widgets/leaderboard_entry_dialog.dart';
import 'package:act_for_earth/ui/rewards/reward_screen.dart';
import 'package:flutter/material.dart';

class HomeShellPage extends StatefulWidget {
  const HomeShellPage({
    super.key,
    required this.currentUser,
    required this.authRepository,
    required this.habitRepository,
    this.onLogout,
  });

  final UserModel currentUser;
  final AuthRepository authRepository;
  final HabitRepository habitRepository;
  final Future<void> Function()? onLogout;

  @override
  State<HomeShellPage> createState() => _HomeShellPageState();
}

class _HomeShellPageState extends State<HomeShellPage> {
  int _currentIndex = 0;
  int _totalPoints = 120;
  bool _isLeaderboardLoading = true;
  String? _leaderboardError;

  late final LeaderboardFirestoreService _leaderboardService;
  late final HabitListViewModel _habitListViewModel;
  StreamSubscription<List<LeaderboardEntry>>? _leaderboardSubscription;

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

  List<LeaderboardEntry> _leaderboard = const [];

  @override
  void initState() {
    super.initState();
    _leaderboardService = LeaderboardFirestoreService();
    _habitListViewModel = HabitListViewModel(
      repository: widget.habitRepository,
      userId: widget.currentUser.id,
    );
    _initializeLeaderboard();
    _habitListViewModel.initialize();
  }

  @override
  void dispose() {
    _leaderboardSubscription?.cancel();
    _habitListViewModel.dispose();
    super.dispose();
  }

  Future<void> _initializeLeaderboard() async {
    try {
      await _leaderboardService.seedDefaults(const [
        LeaderboardEntry(
          id: LeaderboardFirestoreService.currentUserDocId,
          name: 'You',
          points: 120,
        ),
        LeaderboardEntry(name: 'Alya', points: 150),
        LeaderboardEntry(name: 'Raka', points: 95),
      ]);

      _leaderboardSubscription = _leaderboardService.watchEntries().listen(
        (entries) {
          if (!mounted) {
            return;
          }

          final currentUser = _findCurrentUser(entries);

          setState(() {
            _leaderboard = entries;
            _totalPoints = currentUser?.points ?? _totalPoints;
            _isLeaderboardLoading = false;
            _leaderboardError = null;
          });
        },
        onError: (Object error) {
          if (!mounted) {
            return;
          }

          setState(() {
            _isLeaderboardLoading = false;
            _leaderboardError = error.toString();
          });
        },
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLeaderboardLoading = false;
        _leaderboardError = error.toString();
      });
    }
  }

  LeaderboardEntry? _findCurrentUser(List<LeaderboardEntry> entries) {
    for (final entry in entries) {
      if (entry.id == LeaderboardFirestoreService.currentUserDocId) {
        return entry;
      }
    }

    return null;
  }

  LeaderboardEntry? get _currentUser => _findCurrentUser(_leaderboard);

  void _selectPage(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _addPoints(int amount) async {
    final currentUser = _currentUser;
    if (currentUser == null) {
      return;
    }

    final updatedPoints = currentUser.points + amount;
    await _leaderboardService.setCurrentUserPoints(updatedPoints);
  }

  Future<void> _subtractPoints(int amount) async {
    final currentUser = _currentUser;
    if (currentUser == null) {
      return;
    }

    final updatedPoints = (currentUser.points - amount).clamp(0, 999999);
    await _leaderboardService.setCurrentUserPoints(updatedPoints);
  }

  Future<void> _createEntry() async {
    final result = await showDialog<LeaderboardFormResult>(
      context: context,
      builder: (context) => const LeaderboardEntryDialog(),
    );

    if (result == null) {
      return;
    }

    await _leaderboardService.createEntry(
      name: result.name,
      points: result.points,
    );
  }

  Future<void> _editEntry(LeaderboardEntry entry) async {
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

    await _leaderboardService.updateEntry(
      entry.copyWith(name: result.name, points: result.points),
    );
  }

  Future<void> _deleteEntry(LeaderboardEntry entry) async {
    if (entry.id == LeaderboardFirestoreService.currentUserDocId) {
      return;
    }

    await _leaderboardService.deleteEntry(entry.id);
  }

  Future<void> _handleLogout() async {
    if (widget.onLogout == null) {
      return;
    }

    await widget.onLogout!.call();
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      RewardPage(
        totalPoints: _totalPoints,
        rewards: _rewards,
        onEarnPoints: () {
          _addPoints(10);
        },
        onSpendPoints: () {
          _subtractPoints(10);
        },
      ),
      LeaderboardPage(
        entries: List<LeaderboardEntry>.from(_leaderboard)
          ..sort((a, b) => b.points.compareTo(a.points)),
        isLoading: _isLeaderboardLoading,
        errorMessage: _leaderboardError,
        onAdd: _createEntry,
        onEdit: _editEntry,
        onDelete: _deleteEntry,
      ),
      ChallengesPage(authRepository: widget.authRepository),
      HabitListScreen(viewModel: _habitListViewModel),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Act For Earth - ${widget.currentUser.displayName}'),
        actions: [
          if (widget.onLogout != null)
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _handleLogout();
                        },
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
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
        NavigationDestination(
          icon: Icon(Icons.eco_outlined),
          selectedIcon: Icon(Icons.eco),
          label: 'Challenges',
        ),
        NavigationDestination(
          icon: Icon(Icons.event_repeat_outlined),
          selectedIcon: Icon(Icons.event_repeat),
          label: 'Habits',
        ),
      ],
    );
  }
}
