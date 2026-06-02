import 'package:flutter/material.dart';

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
