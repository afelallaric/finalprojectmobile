import 'package:act_for_earth/app/theme/app_theme.dart';
import 'package:act_for_earth/domain/repository/habit_repository.dart';
import 'package:act_for_earth/domain/model/user_model.dart';
import 'package:act_for_earth/domain/repository/auth_repository.dart';
import 'package:act_for_earth/ui/auth/auth_shell_screen.dart';
import 'package:act_for_earth/ui/home/home_screen.dart';
import 'package:flutter/material.dart';

class ActForEarthApp extends StatelessWidget {
  final AuthRepository authRepository;
  final HabitRepository habitRepository;

  const ActForEarthApp({
    super.key,
    required this.authRepository,
    required this.habitRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Act For Earth',
      theme: AppTheme.light(),
      home: StreamBuilder<UserModel?>(
        stream: _authStateStream(),
        builder: (context, snapshot) {
          // While checking authentication state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // User is authenticated
          final currentUser = snapshot.data;
          if (currentUser != null) {
            return HomeShellPage(
              currentUser: currentUser,
              authRepository: authRepository,
              habitRepository: habitRepository,
              onLogout: () async {
                await authRepository.logout();
              },
            );
          }

          // User is not authenticated - show auth pages
          return AuthShellPage(
            authRepository: authRepository,
            onAuthSuccess: () {
              // Auth state will be updated, triggering a rebuild
            },
          );
        },
      ),
    );
  }

  /// Stream that emits the signed-in user model or null when signed out.
  Stream<UserModel?> _authStateStream() {
    return authRepository.authStateChanges;
  }
}
