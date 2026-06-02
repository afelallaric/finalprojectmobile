import 'package:act_for_earth/app/theme/app_theme.dart';
import 'package:act_for_earth/features/home/presentation/pages/home_shell_page.dart';
import 'package:flutter/material.dart';

class ActForEarthApp extends StatelessWidget {
  const ActForEarthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ActForEarth',
      theme: AppTheme.light(),
      home: const HomeShellPage(),
    );
  }
}
