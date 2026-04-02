import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mygang/core/router/app_router.dart';
import 'package:mygang/data/models/group_model.dart';

class GroupListScreen extends StatelessWidget {
  const GroupListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = groups(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grupos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: StreamBuilder<List<GroupModel>>(
        stream: repo.watchAllGroups(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(child: Text('Erro: ${snap.error}'));
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final list = snap.data!;
          if (list.isEmpty) {
            return Center(
              child: Text(
                'Nenhum grupo ainda.\nCrie o primeiro!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final g = list[i];
              return ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                tileColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.35),
                title: Text(g.name),
                subtitle: Text(
                  g.description.isEmpty ? 'Sem descrição' : g.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () => context.push('/g/${g.id}'),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/new-group'),
        icon: const Icon(Icons.add),
        label: const Text('Novo grupo'),
      ),
    );
  }
}
