import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:act_for_earth/app/app.dart';
import 'package:act_for_earth/data/remote/firebase_auth_service.dart';
import 'package:act_for_earth/data/remote/habit_remote_datasource.dart';
import 'package:act_for_earth/data/remote/user_firestore_service.dart';
import 'package:act_for_earth/data/repository/habit_repository_impl.dart';
import 'package:act_for_earth/data/repository/auth_repository_impl.dart';
import 'package:act_for_earth/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final authRepository = AuthRepositoryImpl(
    firebaseAuthService: FirebaseAuthService(),
    userFirestoreService: UserFirestoreService(),
  );

  final habitRepository = HabitRepositoryImpl(
    remoteDataSource: HabitRemoteDataSource(),
  );

  runApp(
    ActForEarthApp(
      authRepository: authRepository,
      habitRepository: habitRepository,
    ),
  );
}
