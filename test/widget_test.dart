// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:act_for_earth/app/app.dart';
import 'package:act_for_earth/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:act_for_earth/features/auth/data/services/firebase_auth_service.dart';
import 'package:act_for_earth/features/auth/data/services/user_firestore_service.dart';

void main() {
  testWidgets('App boots smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    final authRepository = AuthRepositoryImpl(
      firebaseAuthService: FirebaseAuthService(),
      userFirestoreService: UserFirestoreService(),
    );

    await tester.pumpWidget(ActForEarthApp(authRepository: authRepository));

    // Verify the root MaterialApp is present.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
