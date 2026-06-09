import 'dart:async';

import 'package:act_for_earth/features/auth/domain/repositories/auth_repository.dart';
import 'package:act_for_earth/features/challenges/data/challenge_firestore_service.dart';
import 'package:act_for_earth/features/challenges/data/user_challenge_firestore_service.dart';
import 'package:act_for_earth/features/challenges/domain/challenge.dart';
import 'package:act_for_earth/features/challenges/domain/userChallenge.dart';
import 'package:act_for_earth/features/challenges/presentation/pages/available_challenges_page.dart';
import 'package:act_for_earth/features/challenges/presentation/pages/my_challenges_page.dart';
import 'package:flutter/material.dart';

class ChallengesPage extends StatefulWidget {
  final AuthRepository authRepository;

  const ChallengesPage({super.key, required this.authRepository});

  @override
  State<ChallengesPage> createState() => _ChallengePageState();
}

class _ChallengePageState extends State<ChallengesPage> {
  late String _currentUserId;

  int _currentTabIndex = 0;
  bool _isLoading = true;
  String? _error;

  late final ChallengeFirestoreService _challengeService;
  late final UserChallengeFirestoreService _userChallengeService;

  StreamSubscription<List<Challenge>>? _challengesSubscription;
  StreamSubscription<List<UserChallenge>>? _userChallengesSubscription;

  List<Challenge> _allChallenges = [];
  List<UserChallenge> _myChallenges = [];

  @override
  void initState() {
    super.initState();
    _challengeService = ChallengeFirestoreService();
    _userChallengeService = UserChallengeFirestoreService();
    _initializeAuthAndChallenges();
  }

  @override
  void dispose() {
    _challengesSubscription?.cancel();
    _userChallengesSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeAuthAndChallenges() async {
    try {
      final currentUser = await widget.authRepository.getCurrentUser();
      if (currentUser == null) {
        if (!mounted) return;
        setState(() {
          _error = 'User not authenticated';
          _isLoading = false;
        });
        return;
      }
      _currentUserId = currentUser.id;
      _initializeChallenges();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = 'Error loading user: ${error.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _initializeChallenges() async {
    try {
      await _challengeService.seedDefaultChallenges();

      _challengesSubscription = _challengeService.watchChallenges().listen(
        (challenges) {
          if (!mounted) return;
          setState(() {
            _allChallenges = challenges;
            _updateLoadingState();
          });
        },
        onError: (Object error) {
          if (!mounted) return;
          setState(() {
            _error = error.toString();
            _isLoading = false;
          });
        },
      );

      _userChallengesSubscription =
          _userChallengeService.watchUserChallenges(_currentUserId).listen(
        (userChallenges) {
          if (!mounted) return;
          setState(() {
            _myChallenges = userChallenges;
            _updateLoadingState();
          });
        },
        onError: (Object error) {
          if (!mounted) return;
          setState(() {
            _error = error.toString();
            _isLoading = false;
          });
        },
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  void _updateLoadingState() {
    if (_allChallenges.isNotEmpty || _myChallenges.isNotEmpty) {
      _isLoading = false;
      _error = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show error if authentication failed
    if (_error != null && _error!.contains('User not authenticated')) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Challenges'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _error ?? 'An error occurred',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Challenges'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Available'),
              Tab(text: 'My Challenges'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            AvailableChallengesPage(
              challenges: _allChallenges,
              userChallenges: _myChallenges,
              isLoading: _isLoading,
              error: _error,
              onJoinChallenge: _handleJoinChallenge,
              currentUserId: _currentUserId,
            ),
            MyChallengiesPage(
              userChallenges: _myChallenges,
              challenges: _allChallenges,
              isLoading: _isLoading,
              error: _error,
              onUpdateProgress: _handleUpdateProgress,
              onCompleteChallenge: _handleCompleteChallenge,
              onLeaveChallenge: _handleLeaveChallenge,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleJoinChallenge(String challengeId) async {
    try {
      await _userChallengeService.joinChallenge(
        _currentUserId,
        challengeId,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Challenge joined!')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${error.toString()}')),
      );
    }
  }

  Future<void> _handleUpdateProgress(
    String userChallengeId,
    int progress,
  ) async {
    try {
      await _userChallengeService.updateProgress(userChallengeId, progress);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Progress updated!')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${error.toString()}')),
      );
    }
  }

  Future<void> _handleCompleteChallenge(String userChallengeId) async {
    try {
      await _userChallengeService.completeChallenge(userChallengeId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Challenge completed!')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${error.toString()}')),
      );
    }
  }

  Future<void> _handleLeaveChallenge(String userChallengeId) async {
    try {
      await _userChallengeService.leaveChallenge(userChallengeId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Left challenge')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${error.toString()}')),
      );
    }
  }
}