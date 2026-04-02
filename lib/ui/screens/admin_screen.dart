import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mygang/core/domain/questionnaire_rules.dart';
import 'package:mygang/core/router/app_router.dart';
import 'package:mygang/data/group_repository.dart';
import 'package:mygang/data/models/group_model.dart';
import 'package:mygang/data/models/question_model.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key, required this.groupId});

  final String groupId;

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _prompt = TextEditingController();
  QuestionType _type = QuestionType.text;
  final _opt1 = TextEditingController();
  final _opt2 = TextEditingController();

  @override
  void dispose() {
    _prompt.dispose();
    _opt1.dispose();
    _opt2.dispose();
    super.dispose();
  }

  bool _canAdmin(GroupModel? g, MemberModel? m, String? uid) {
    if (uid == null || g == null) return false;
    if (g.ownerId == uid) return true;
    return m != null && m.isAdmin && m.isActive;
  }

  Future<void> _addQuestion(int orderBase) async {
    List<String>? opts;
    if (_type == QuestionType.singleChoice) {
      opts = [_opt1.text.trim(), _opt2.text.trim()];
    }
    final q = QuestionModel(
      id: '',
      type: _type,
      prompt: _prompt.text,
      options: _type == QuestionType.yesNo ? null : opts,
      order: orderBase,
    );
    try {
      await groups(context).upsertQuestion(widget.groupId, q);
      if (mounted) {
        _prompt.clear();
        _opt1.clear();
        _opt2.clear();
        setState(() => _type = QuestionType.text);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pergunta adicionada.')));
      }
    } on QuestionValidationException catch (e) {
      if (!mounted) return;
      final msg = switch (e.error) {
        QuestionValidationError.emptyPrompt => 'Digite o enunciado.',
        QuestionValidationError.invalidOptions => 'Escolha única precisa de duas opções válidas.',
        QuestionValidationError.yesNoMustHaveNoOptions => 'Sim/Não não usa opções customizadas.',
      };
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final grepo = groups(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Administração')),
      body: StreamBuilder<GroupModel?>(
        stream: grepo.watchGroup(widget.groupId),
        builder: (context, gs) {
          return StreamBuilder<MemberModel?>(
            stream: uid != null ? grepo.watchMyMembership(widget.groupId, uid) : Stream<MemberModel?>.value(null),
            builder: (context, ms) {
              final g = gs.data;
              final m = ms.data;
              if (!_canAdmin(g, m, uid)) {
                return const Center(child: Text('Sem permissão.'));
              }
              return StreamBuilder<List<QuestionModel>>(
                stream: grepo.watchQuestions(widget.groupId),
                builder: (context, qsnap) {
                  final qs = qsnap.data ?? [];
                  final nextOrder = qs.isEmpty
                      ? 0
                      : qs.map((e) => e.order).reduce((a, b) => a > b ? a : b) + 1;
                  return ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      Text('Pedidos pendentes', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      StreamBuilder<List<ApplicationEntry>>(
                        stream: grepo.watchApplications(widget.groupId),
                        builder: (context, asnap) {
                          if (!asnap.hasData) {
                            return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
                          }
                          final apps = asnap.data!;
                          if (apps.isEmpty) {
                            return Text(
                              'Nenhum pedido.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                            );
                          }
                          return Column(
                            children: apps
                                .map(
                                  (a) => Card(
                                    child: ListTile(
                                      title: Text('Usuário ${a.userId.substring(0, 8)}…'),
                                      subtitle: Text(a.answers.entries.map((e) => '${e.key}: ${e.value}').join('\n')),
                                      isThreeLine: true,
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.check, color: Colors.green),
                                            onPressed: () async {
                                              try {
                                                await grepo.approveApplication(
                                                  groupId: widget.groupId,
                                                  applicationId: a.id,
                                                  applicantUserId: a.userId,
                                                );
                                              } catch (e) {
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                                                }
                                              }
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.close, color: Colors.red),
                                            onPressed: () => grepo.rejectApplication(widget.groupId, a.id),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                      Text('Questionário de entrada', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      ...qs.map(
                        (q) => ListTile(
                          title: Text(q.prompt),
                          subtitle: Text(q.type.name),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => grepo.deleteQuestion(widget.groupId, q.id),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<QuestionType>(
                        value: _type,
                        decoration: const InputDecoration(labelText: 'Tipo'),
                        items: const [
                          DropdownMenuItem(value: QuestionType.text, child: Text('Texto curto')),
                          DropdownMenuItem(value: QuestionType.singleChoice, child: Text('Escolha única')),
                          DropdownMenuItem(value: QuestionType.yesNo, child: Text('Sim / Não')),
                        ],
                        onChanged: (v) => setState(() => _type = v ?? QuestionType.text),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _prompt,
                        decoration: const InputDecoration(labelText: 'Pergunta'),
                      ),
                      if (_type == QuestionType.singleChoice) ...[
                        const SizedBox(height: 12),
                        TextField(controller: _opt1, decoration: const InputDecoration(labelText: 'Opção 1')),
                        TextField(controller: _opt2, decoration: const InputDecoration(labelText: 'Opção 2')),
                      ],
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => _addQuestion(nextOrder),
                        child: const Text('Adicionar pergunta'),
                      ),
                      const SizedBox(height: 32),
                      OutlinedButton.icon(
                        onPressed: () => context.push('/g/${widget.groupId}/e/new'),
                        icon: const Icon(Icons.event_available),
                        label: const Text('Criar evento'),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
