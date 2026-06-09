import 'package:act_for_earth/app/theme/app_theme.dart';
import 'package:act_for_earth/features/auth/domain/repositories/auth_repository.dart';
import 'package:act_for_earth/features/auth/presentation/pages/auth_shell_page.dart';
import 'package:act_for_earth/features/home/presentation/pages/home_shell_page.dart';
import 'package:flutter/material.dart';

class ActForEarthApp extends StatelessWidget {
  final AuthRepository authRepository;

  const ActForEarthApp({
    super.key,
    required this.authRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ActForEarth',
      theme: AppTheme.light(),
      home: StreamBuilder<bool>(
        stream: _authStateStream(),
        builder: (context, snapshot) {
          // While checking authentication state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          // User is authenticated
          if (snapshot.hasData && snapshot.data == true) {
            return HomeShellPage(
              authRepository: authRepository,
              onLogout: () {
                authRepository.logout();
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

  /// Stream that emits true when user is authenticated, false otherwise
  Stream<bool> _authStateStream() {
    return authRepository.authStateChanges.map((user) => user != null);
  }
}

