import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:act_for_earth/app/app.dart';
import 'package:act_for_earth/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ActForEarthApp());
}
