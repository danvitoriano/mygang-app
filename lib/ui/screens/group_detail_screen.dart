import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mygang/core/domain/event_rules.dart';
import 'package:mygang/core/router/app_router.dart';
import 'package:mygang/data/models/event_model.dart';
import 'package:mygang/data/models/group_model.dart';

class GroupDetailScreen extends StatelessWidget {
  const GroupDetailScreen({super.key, required this.groupId});

  final String groupId;

  bool _isAdmin(GroupModel? g, MemberModel? m, String? uid) {
    if (uid == null || g == null) return false;
    if (g.ownerId == uid) return true;
    return m != null && m.isAdmin && m.isActive;
  }

  bool _isMember(MemberModel? m) => m != null && m.isActive;

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final grepo = groups(context);
    final erepo = events(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grupo'),
        actions: [
          StreamBuilder<GroupModel?>(
            stream: grepo.watchGroup(groupId),
            builder: (context, gs) {
              return StreamBuilder<MemberModel?>(
                stream: uid != null ? grepo.watchMyMembership(groupId, uid) : Stream<MemberModel?>.value(null),
                builder: (context, ms) {
                  final g = gs.data;
                  final m = ms.data;
                  if (!_isAdmin(g, m, uid)) return const SizedBox.shrink();
                  return IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: () => context.push('/g/$groupId/admin'),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<GroupModel?>(
        stream: grepo.watchGroup(groupId),
        builder: (context, snap) {
          if (!snap.hasData || snap.data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final g = snap.data!;
          return StreamBuilder<MemberModel?>(
            stream: uid != null ? grepo.watchMyMembership(groupId, uid) : Stream<MemberModel?>.value(null),
            builder: (context, ms) {
              final m = ms.data;
              final admin = _isAdmin(g, m, uid);
              final member = _isMember(m);

              return ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Text(g.name, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(
                    g.description.isEmpty ? 'Sem descrição.' : g.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  if (!member)
                    FilledButton(
                      onPressed: () => context.push('/g/$groupId/join'),
                      child: const Text('Pedir entrada'),
                    ),
                  if (member) ...[
                    Text('Eventos', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    StreamBuilder<List<EventModel>>(
                      stream: erepo.watchEvents(groupId),
                      builder: (context, es) {
                        if (!es.hasData) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final evs = es.data!;
                        if (evs.isEmpty) {
                          return Text(
                            admin ? 'Nenhum evento. Crie no painel admin.' : 'Nenhum evento agendado.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          );
                        }
                        return Column(
                          children: evs
                              .map(
                                (e) => ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(e.title),
                                  subtitle: Text(_eventSubtitle(e)),
                                  onTap: () => context.push('/g/$groupId/e/${e.id}'),
                                ),
                              )
                              .toList(),
                        );
                      },
                    ),
                    if (admin)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: OutlinedButton.icon(
                          onPressed: () => context.push('/g/$groupId/e/new'),
                          icon: const Icon(Icons.event),
                          label: const Text('Novo evento'),
                        ),
                      ),
                  ],
                ],
              );
            },
          );
        },
      ),
    );
  }

  String _eventSubtitle(EventModel e) {
    final kind = switch (e.kind) {
      EventKind.presencial => 'Presencial',
      EventKind.online => 'Online',
      EventKind.hibrido => 'Híbrido',
    };
    return '$kind · ${_fmt(e.startsAt)}';
  }

  String _fmt(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}
