import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mygang/core/domain/event_rules.dart';
import 'package:mygang/core/router/app_router.dart';
import 'package:mygang/data/models/event_model.dart';
import 'package:mygang/data/models/group_model.dart';

class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({super.key, required this.groupId, required this.eventId});

  final String groupId;
  final String eventId;

  String _kindLabel(EventKind k) => switch (k) {
        EventKind.presencial => 'Presencial',
        EventKind.online => 'Online',
        EventKind.hibrido => 'Híbrido',
      };

  String _fmt(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  bool _admin(GroupModel? g, MemberModel? m, String? uid) {
    if (uid == null || g == null) return false;
    if (g.ownerId == uid) return true;
    return m != null && m.isAdmin && m.isActive;
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final erepo = events(context);
    final grepo = groups(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Evento'),
        actions: [
          StreamBuilder<GroupModel?>(
            stream: grepo.watchGroup(groupId),
            builder: (context, gs) {
              return StreamBuilder<MemberModel?>(
                stream: uid != null ? grepo.watchMyMembership(groupId, uid) : Stream<MemberModel?>.value(null),
                builder: (context, ms) {
                  final g = gs.data;
                  final m = ms.data;
                  if (!_admin(g, m, uid)) return const SizedBox.shrink();
                  return IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => context.push('/g/$groupId/e/$eventId/edit'),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<EventModel?>(
        stream: erepo.watchEvent(groupId, eventId),
        builder: (context, snap) {
          if (!snap.hasData || snap.data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final e = snap.data!;
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(e.title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text('${_kindLabel(e.kind)} · ${_fmt(e.startsAt)}'),
              if (e.meetingLink != null && e.meetingLink!.isNotEmpty) ...[
                const SizedBox(height: 8),
                SelectableText(e.meetingLink!),
              ],
              if (e.location != null && e.location!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(e.location!),
              ],
              if (e.capacity != null) ...[
                const SizedBox(height: 8),
                Text('Capacidade: ${e.capacity}'),
              ],
              const SizedBox(height: 16),
              Text(e.description, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 32),
              StreamBuilder<MemberModel?>(
                stream: uid != null ? grepo.watchMyMembership(groupId, uid) : Stream<MemberModel?>.value(null),
                builder: (context, ms) {
                  if (uid == null || ms.data == null || !ms.data!.isActive) {
                    return const Text('Participe do grupo para confirmar presença.');
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Presença', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      StreamBuilder<String?>(
                        stream: erepo.watchRsvp(groupId, eventId, uid),
                        builder: (context, rs) {
                          final current = rs.data;
                          return Wrap(
                            spacing: 8,
                            children: [
                              ChoiceChip(
                                label: const Text('Vou'),
                                selected: current == 'going',
                                onSelected: (_) => erepo.setRsvp(groupId, eventId, uid, 'going'),
                              ),
                              ChoiceChip(
                                label: const Text('Talvez'),
                                selected: current == 'maybe',
                                onSelected: (_) => erepo.setRsvp(groupId, eventId, uid, 'maybe'),
                              ),
                              ChoiceChip(
                                label: const Text('Não vou'),
                                selected: current == 'notGoing',
                                onSelected: (_) => erepo.setRsvp(groupId, eventId, uid, 'notGoing'),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
