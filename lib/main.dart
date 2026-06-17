import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

import 'package:act_for_earth/app/app.dart';
import 'package:act_for_earth/data/remote/firebase_auth_service.dart';
import 'package:act_for_earth/data/remote/habit_remote_datasource.dart';
import 'package:act_for_earth/data/remote/user_firestore_service.dart';
import 'package:act_for_earth/data/remote/notification_service.dart';
import 'package:act_for_earth/data/repository/habit_repository_impl.dart';
import 'package:act_for_earth/data/repository/auth_repository_impl.dart';
import 'package:act_for_earth/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  // Pass all uncaught asynchronous errors that aren't handled by
  // the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  await NotificationService.init();

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
