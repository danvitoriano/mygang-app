import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mygang/core/domain/group_rules.dart';
import 'package:mygang/core/router/app_router.dart';
import 'package:mygang/data/group_repository.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _name = TextEditingController();
  final _desc = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final uid = users(context).currentUser?.uid;
    if (uid == null) return;
    setState(() => _loading = true);
    try {
      final id = await groups(context).createGroup(
        ownerId: uid,
        name: _name.text,
        description: _desc.text.isEmpty ? null : _desc.text,
      );
      if (mounted) context.go('/g/$id');
    } on GroupValidationException catch (e) {
      if (!mounted) return;
      final msg = switch (e.error) {
        GroupValidationError.emptyName => 'Informe o nome do grupo.',
        GroupValidationError.nameTooLong => 'Nome muito longo.',
        GroupValidationError.descriptionTooLong => 'Descrição muito longa.',
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
      appBar: AppBar(title: const Text('Novo grupo')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Nome da comunidade'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _desc,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Descrição (opcional)'),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _loading ? null : _save,
            child: Text(_loading ? 'Salvando…' : 'Criar'),
          ),
        ],
      ),
    );
  }
}
