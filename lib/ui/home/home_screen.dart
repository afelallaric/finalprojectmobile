import 'dart:async';

import 'package:act_for_earth/data/remote/leaderboard_firestore_service.dart';
import 'package:act_for_earth/domain/model/leaderboard_entry.dart';
import 'package:act_for_earth/domain/model/user_model.dart';
import 'package:act_for_earth/domain/repository/auth_repository.dart';
import 'package:act_for_earth/domain/repository/habit_repository.dart';
import 'package:act_for_earth/ui/challenges/challenges_screen.dart';
import 'package:act_for_earth/ui/habit_list/habit_list_screen.dart';
import 'package:act_for_earth/ui/habit_list/habit_list_viewmodel.dart';
import 'package:act_for_earth/ui/leaderboard/leaderboard_screen.dart';
import 'package:act_for_earth/data/remote/reward_firestore_service.dart';
import 'package:act_for_earth/domain/model/user_reward.dart';
import 'package:act_for_earth/ui/home/ai_suggestions_page.dart';
import 'package:act_for_earth/ui/profile/profile_screen.dart';
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
  bool _isLeaderboardLoading = true;
  String? _leaderboardError;

  late final LeaderboardFirestoreService _leaderboardService;
  late final HabitListViewModel _habitListViewModel;
  StreamSubscription<List<LeaderboardEntry>>? _leaderboardSubscription;

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
      // Seed placeholder competitors only if the collection is empty.
      await _leaderboardService.seedDefaults([
        const LeaderboardEntry(name: 'Alya', points: 150),
        const LeaderboardEntry(name: 'Raka', points: 95),
      ]);

      _leaderboardSubscription = _leaderboardService.watchEntries().listen(
        (entries) {
          if (!mounted) return;
          setState(() {
            _leaderboard = entries;
            _isLeaderboardLoading = false;
            _leaderboardError = null;
          });
        },
        onError: (Object error) {
          if (!mounted) return;
          setState(() {
            _isLeaderboardLoading = false;
            _leaderboardError = error.toString();
          });
        },
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLeaderboardLoading = false;
        _leaderboardError = error.toString();
      });
    }
  }

  void _selectPage(int index) {
    setState(() {
      _currentIndex = index;
    });
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
      AISuggestionsPage(
        userId: widget.currentUser.id,
        habitRepository: widget.habitRepository,
      ),
      ChallengesPage(authRepository: widget.authRepository),
      HabitListScreen(viewModel: _habitListViewModel),
      LeaderboardPage(
        entries: _leaderboard,
        isLoading: _isLeaderboardLoading,
        errorMessage: _leaderboardError,
        currentUserId: widget.currentUser.id,
      ),
      StreamBuilder<UserReward?>(
        stream: RewardFirestoreService().watchUserReward(widget.currentUser.id),
        builder: (context, snapshot) {
          final userReward = snapshot.data;
          final totalPoints = userReward?.points ?? 0;
          final badges = userReward?.badges ?? [];

          // Keep the leaderboard entry in sync with rewards points.
          if (snapshot.hasData) {
            _leaderboardService.upsertUserEntry(
              userId: widget.currentUser.id,
              displayName: widget.currentUser.displayName,
              points: totalPoints,
            );
          }

          return ProfilePage(
            currentUser: widget.currentUser,
            authRepository: widget.authRepository,
            totalPoints: totalPoints,
            badges: badges,
            onLogout: _handleLogout,
          );
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
        actionsIconTheme: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
        title: Text(
          'Act For Earth - ${widget.currentUser.displayName}',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (widget.onLogout != null)
            IconButton(
              icon: const Icon(Icons.logout),
              color: Theme.of(context).colorScheme.onPrimary,
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
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            );
          }
          return TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          );
        }),
      ),
      child: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onTap,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Daily Quest',
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
          NavigationDestination(
            icon: Icon(Icons.leaderboard_outlined),
            selectedIcon: Icon(Icons.leaderboard),
            label: 'Leaderboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

