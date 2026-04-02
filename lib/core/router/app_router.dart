import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mygang/core/router/go_router_refresh.dart';
import 'package:mygang/data/event_repository.dart';
import 'package:mygang/data/group_repository.dart';
import 'package:mygang/data/user_repository.dart';
import 'package:mygang/di/repositories_scope.dart';
import 'package:mygang/ui/screens/admin_screen.dart';
import 'package:mygang/ui/screens/apply_screen.dart';
import 'package:mygang/ui/screens/create_group_screen.dart';
import 'package:mygang/ui/screens/event_detail_screen.dart';
import 'package:mygang/ui/screens/event_form_screen.dart';
import 'package:mygang/ui/screens/group_detail_screen.dart';
import 'package:mygang/ui/screens/group_list_screen.dart';
import 'package:mygang/ui/screens/login_screen.dart';
import 'package:mygang/ui/screens/profile_screen.dart';
import 'package:mygang/ui/screens/register_screen.dart';

GoRouter createAppRouter(FirebaseAuth auth) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(auth.authStateChanges()),
    redirect: (context, state) {
      final loggedIn = auth.currentUser != null;
      final loc = state.uri.path;
      final isAuthPage = loc == '/login' || loc == '/register';
      if (!loggedIn && !isAuthPage) {
        return '/login';
      }
      if (loggedIn && isAuthPage) {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const GroupListScreen(),
        routes: [
          GoRoute(
            path: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: 'new-group',
            builder: (context, state) => const CreateGroupScreen(),
          ),
          GoRoute(
            path: 'g/:gid',
            builder: (context, state) {
              final gid = state.pathParameters['gid']!;
              return GroupDetailScreen(groupId: gid);
            },
            routes: [
              GoRoute(
                path: 'join',
                builder: (context, state) {
                  final gid = state.pathParameters['gid']!;
                  return ApplyScreen(groupId: gid);
                },
              ),
              GoRoute(
                path: 'admin',
                builder: (context, state) {
                  final gid = state.pathParameters['gid']!;
                  return AdminScreen(groupId: gid);
                },
              ),
              GoRoute(
                path: 'e/new',
                builder: (context, state) {
                  final gid = state.pathParameters['gid']!;
                  return EventFormScreen(groupId: gid);
                },
              ),
              GoRoute(
                path: 'e/:eid',
                builder: (context, state) {
                  final gid = state.pathParameters['gid']!;
                  final eid = state.pathParameters['eid']!;
                  return EventDetailScreen(groupId: gid, eventId: eid);
                },
              ),
              GoRoute(
                path: 'e/:eid/edit',
                builder: (context, state) {
                  final gid = state.pathParameters['gid']!;
                  final eid = state.pathParameters['eid']!;
                  return EventFormScreen(groupId: gid, eventId: eid);
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

UserRepository users(BuildContext context) => RepositoriesScope.of(context).users;
GroupRepository groups(BuildContext context) => RepositoriesScope.of(context).groups;
EventRepository events(BuildContext context) => RepositoriesScope.of(context).events;
