import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:act_for_earth/app/app.dart';
import 'package:act_for_earth/firebase_options.dart';
import 'package:act_for_earth/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:act_for_earth/features/auth/data/services/firebase_auth_service.dart';
import 'package:act_for_earth/features/auth/data/services/user_firestore_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final authRepository = AuthRepositoryImpl(
    firebaseAuthService: FirebaseAuthService(),
    userFirestoreService: UserFirestoreService(),
  );

  runApp(ActForEarthApp(authRepository: authRepository));
}
