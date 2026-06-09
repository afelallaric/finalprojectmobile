// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:act_for_earth/app/app.dart';
import 'package:act_for_earth/domain/model/habit.dart';
import 'package:act_for_earth/domain/model/user_model.dart';
import 'package:act_for_earth/domain/repository/auth_repository.dart';
import 'package:act_for_earth/domain/repository/habit_repository.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Stream<UserModel?> get authStateChanges => const Stream<UserModel?>.empty();

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> logout() async {}

  @override
  Future<UserModel?> getCurrentUser() async => null;

  @override
  Future<bool> get isAuthenticated async => false;
}

class _FakeHabitRepository implements HabitRepository {
  @override
  Future<void> createHabit(Habit habit) async {}

  @override
  Future<void> deleteHabit(String habitId) async {}

  @override
  Stream<List<Habit>> watchHabits(String userId) =>
      const Stream<List<Habit>>.empty();

  @override
  Future<void> updateHabit(Habit habit) async {}
}

void main() {
  testWidgets('App boots smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    final authRepository = _FakeAuthRepository();
    final habitRepository = _FakeHabitRepository();

    await tester.pumpWidget(
      ActForEarthApp(
        authRepository: authRepository,
        habitRepository: habitRepository,
      ),
    );

    // Verify the root MaterialApp is present.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
