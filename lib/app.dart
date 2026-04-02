import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mygang/core/router/app_router.dart';
import 'package:mygang/core/theme/app_theme.dart';

class MyGangApp extends StatelessWidget {
  const MyGangApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'My Gang',
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
