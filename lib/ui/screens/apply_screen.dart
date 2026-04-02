import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mygang/core/domain/application_rules.dart';
import 'package:mygang/core/domain/questionnaire_rules.dart';
import 'package:mygang/core/router/app_router.dart';
import 'package:mygang/data/group_repository.dart';
import 'package:mygang/data/models/question_model.dart';

class ApplyScreen extends StatefulWidget {
  const ApplyScreen({super.key, required this.groupId});

  final String groupId;

  @override
  State<ApplyScreen> createState() => _ApplyScreenState();
}

class _ApplyScreenState extends State<ApplyScreen> {
  final Map<String, TextEditingController> _text = {};
  final Map<String, String?> _choice = {};
  final Map<String, bool?> _yesNo = {};
  bool _loading = false;

  @override
  void dispose() {
    for (final c in _text.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _ensureControllers(List<QuestionModel> qs) {
    for (final q in qs) {
      if (q.type == QuestionType.text) {
        _text.putIfAbsent(q.id, TextEditingController.new);
      }
    }
  }

  Future<void> _submit(List<QuestionModel> ordered) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final defs = ordered.map((q) => q.toDef()).toList();
    final answers = <String, String>{};
    for (final q in ordered) {
      switch (q.type) {
        case QuestionType.text:
          answers[q.id] = _text[q.id]?.text ?? '';
        case QuestionType.singleChoice:
          answers[q.id] = _choice[q.id] ?? '';
        case QuestionType.yesNo:
          final y = _yesNo[q.id];
          answers[q.id] = y == null ? '' : (y ? 'sim' : 'não');
      }
    }
    setState(() => _loading = true);
    try {
      await groups(context).submitApplication(
        groupId: widget.groupId,
        userId: uid,
        answers: answers,
        questionnaire: defs,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pedido enviado. Aguarde aprovação.')));
        context.go('/g/${widget.groupId}');
      }
    } on ApplicationValidationException catch (e) {
      if (!mounted) return;
      final msg = _applicationValidationMessage(e.error);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = groups(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Pedir entrada')),
      body: StreamBuilder<List<QuestionModel>>(
        stream: repo.watchQuestions(widget.groupId),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final qs = List<QuestionModel>.from(snap.data!)..sort((a, b) => a.order.compareTo(b.order));
          _ensureControllers(qs);
          if (qs.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Este grupo ainda não definiu perguntas. Você pode enviar um pedido vazio para os admins aprovarem.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _loading
                        ? null
                        : () => _submit(qs),
                    child: Text(_loading ? 'Enviando…' : 'Enviar pedido'),
                  ),
                ],
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                'Responda o questionário do grupo.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              ...qs.expand((q) {
                return [
                  Text(q.prompt, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  _field(q),
                  const SizedBox(height: 20),
                ];
              }),
              FilledButton(
                onPressed: _loading ? null : () => _submit(qs),
                child: Text(_loading ? 'Enviando…' : 'Enviar pedido'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _field(QuestionModel q) {
    switch (q.type) {
      case QuestionType.text:
        return TextField(
          controller: _text[q.id],
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'Sua resposta'),
        );
      case QuestionType.singleChoice:
        final opts = q.options ?? [];
        return Column(
          children: opts
              .map(
                (o) => RadioListTile<String>(
                  title: Text(o),
                  value: o,
                  groupValue: _choice[q.id],
                  onChanged: (v) => setState(() => _choice[q.id] = v),
                ),
              )
              .toList(),
        );
      case QuestionType.yesNo:
        return Row(
          children: [
            Expanded(
              child: SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: true, label: Text('Sim')),
                  ButtonSegment(value: false, label: Text('Não')),
                ],
                selected: _yesNo[q.id] != null ? {_yesNo[q.id]!} : {},
                onSelectionChanged: (s) => setState(() => _yesNo[q.id] = s.first),
              ),
            ),
          ],
        );
    }
  }
}

String _applicationValidationMessage(ApplicationValidationError err) {
  if (err == ApplicationValidationError.missingAnswer) {
    return 'Responda todas as perguntas.';
  }
  if (err == ApplicationValidationError.invalidTextAnswer) {
    return 'Texto inválido em alguma resposta.';
  }
  if (err == ApplicationValidationError.invalidSingleChoice) {
    return 'Escolha uma opção válida.';
  }
  return 'Use sim ou não onde indicado.';
}
