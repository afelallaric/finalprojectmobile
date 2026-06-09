import 'package:act_for_earth/domain/repository/auth_repository.dart';
import 'package:act_for_earth/ui/auth/login_screen.dart';
import 'package:act_for_earth/ui/auth/register_screen.dart';
import 'package:flutter/material.dart';

class AuthShellPage extends StatefulWidget {
  final AuthRepository authRepository;
  final VoidCallback onAuthSuccess;

  const AuthShellPage({
    super.key,
    required this.authRepository,
    required this.onAuthSuccess,
  });

  @override
  State<AuthShellPage> createState() => _AuthShellPageState();
}

class _AuthShellPageState extends State<AuthShellPage> {
  bool _isLoginPage = true;

  void _showLogin() {
    setState(() {
      _isLoginPage = true;
    });
  }

  void _showRegister() {
    setState(() {
      _isLoginPage = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoginPage
          ? LoginPage(
              authRepository: widget.authRepository,
              onLoginSuccess: widget.onAuthSuccess,
              onNavigateToRegister: _showRegister,
            )
          : RegisterPage(
              authRepository: widget.authRepository,
              onRegisterSuccess: _showLogin,
              onNavigateToLogin: _showLogin,
            ),
    );
  }
}
