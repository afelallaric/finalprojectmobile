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
