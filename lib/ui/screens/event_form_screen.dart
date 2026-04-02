import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mygang/core/domain/event_rules.dart';
import 'package:mygang/core/router/app_router.dart';
import 'package:mygang/data/event_repository.dart';
import 'package:mygang/data/models/event_model.dart';

class EventFormScreen extends StatefulWidget {
  const EventFormScreen({super.key, required this.groupId, this.eventId});

  final String groupId;
  final String? eventId;

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _link = TextEditingController();
  final _location = TextEditingController();
  final _capacity = TextEditingController();
  EventKind _kind = EventKind.presencial;
  DateTime _starts = DateTime.now().add(const Duration(days: 1));
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final eid = widget.eventId;
    if (eid != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _load(eid));
    }
  }

  Future<void> _load(String eid) async {
    final ev = await events(context).getEvent(widget.groupId, eid);
    if (ev == null || !mounted) return;
    setState(() {
      _title.text = ev.title;
      _desc.text = ev.description;
      _kind = ev.kind;
      _starts = ev.startsAt;
      _link.text = ev.meetingLink ?? '';
      _location.text = ev.location ?? '';
      _capacity.text = ev.capacity?.toString() ?? '';
    });
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _link.dispose();
    _location.dispose();
    _capacity.dispose();
    super.dispose();
  }

  EventDraft _draft() {
    int? cap;
    final c = _capacity.text.trim();
    if (c.isNotEmpty) {
      cap = int.tryParse(c);
    }
    return EventDraft(
      title: _title.text,
      description: _desc.text,
      startsAt: _starts,
      kind: _kind,
      meetingLink: _link.text.isEmpty ? null : _link.text,
      location: _location.text.isEmpty ? null : _location.text,
      capacity: cap,
    );
  }

  Future<void> _save() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    setState(() => _loading = true);
    try {
      final repo = events(context);
      final draft = _draft();
      if (widget.eventId == null) {
        await repo.createEvent(groupId: widget.groupId, createdBy: uid, draft: draft);
      } else {
        await repo.updateEvent(groupId: widget.groupId, eventId: widget.eventId!, draft: draft);
      }
      if (mounted) context.pop();
    } on EventValidationException catch (e) {
      if (!mounted) return;
      final msg = switch (e.error) {
        EventValidationError.emptyTitle => 'Informe o título.',
        EventValidationError.missingMeetingLink => 'Informe o link (online/híbrido).',
        EventValidationError.missingLocation => 'Informe o local (presencial/híbrido).',
        EventValidationError.invalidCapacity => 'Capacidade deve ser maior que zero.',
      };
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.eventId == null ? 'Novo evento' : 'Editar evento')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          TextField(controller: _title, decoration: const InputDecoration(labelText: 'Título')),
          const SizedBox(height: 12),
          TextField(controller: _desc, maxLines: 3, decoration: const InputDecoration(labelText: 'Descrição')),
          const SizedBox(height: 12),
          DropdownButtonFormField<EventKind>(
            value: _kind,
            decoration: const InputDecoration(labelText: 'Formato'),
            items: const [
              DropdownMenuItem(value: EventKind.presencial, child: Text('Presencial')),
              DropdownMenuItem(value: EventKind.online, child: Text('Online')),
              DropdownMenuItem(value: EventKind.hibrido, child: Text('Híbrido')),
            ],
            onChanged: (v) => setState(() => _kind = v ?? EventKind.presencial),
          ),
          const SizedBox(height: 12),
          ListTile(
            title: const Text('Data e hora'),
            subtitle: Text(_fmt(_starts)),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: _starts,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              if (d == null || !mounted) return;
              final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_starts));
              if (t == null || !mounted) return;
              setState(() {
                _starts = DateTime(d.year, d.month, d.day, t.hour, t.minute);
              });
            },
          ),
          if (_kind == EventKind.online || _kind == EventKind.hibrido)
            TextField(
              controller: _link,
              decoration: const InputDecoration(labelText: 'Link (meet, zoom, etc.)'),
            ),
          if (_kind == EventKind.presencial || _kind == EventKind.hibrido) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _location,
              decoration: const InputDecoration(labelText: 'Local / endereço'),
            ),
          ],
          const SizedBox(height: 12),
          TextField(
            controller: _capacity,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Capacidade (opcional)'),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _loading ? null : _save,
            child: Text(_loading ? 'Salvando…' : 'Salvar'),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}
