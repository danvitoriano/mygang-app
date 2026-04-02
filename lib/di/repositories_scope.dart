import 'package:flutter/material.dart';
import 'package:mygang/data/event_repository.dart';
import 'package:mygang/data/group_repository.dart';
import 'package:mygang/data/user_repository.dart';

class RepositoriesScope extends InheritedWidget {
  const RepositoriesScope({
    super.key,
    required this.users,
    required this.groups,
    required this.events,
    required super.child,
  });

  final UserRepository users;
  final GroupRepository groups;
  final EventRepository events;

  static RepositoriesScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<RepositoriesScope>();
    assert(scope != null, 'RepositoriesScope not found');
    return scope!;
  }

  @override
  bool updateShouldNotify(covariant RepositoriesScope oldWidget) {
    return users != oldWidget.users || groups != oldWidget.groups || events != oldWidget.events;
  }
}
