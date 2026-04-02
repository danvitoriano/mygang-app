import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mygang/app.dart';
import 'package:mygang/core/router/app_router.dart';
import 'package:mygang/data/event_repository.dart';
import 'package:mygang/data/group_repository.dart';
import 'package:mygang/data/user_repository.dart';
import 'package:mygang/di/repositories_scope.dart';
import 'package:mygang/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  final userRepo = UserRepository(auth, firestore);
  final groupRepo = GroupRepository(firestore);
  final eventRepo = EventRepository(firestore);

  final router = createAppRouter(auth);

  runApp(
    RepositoriesScope(
      users: userRepo,
      groups: groupRepo,
      events: eventRepo,
      child: MyGangApp(router: router),
    ),
  );
}
