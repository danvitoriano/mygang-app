import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mygang/core/domain/questionnaire_rules.dart';

class QuestionModel {
  QuestionModel({
    required this.id,
    required this.type,
    required this.prompt,
    this.options,
    required this.order,
  });

  final String id;
  final QuestionType type;
  final String prompt;
  final List<String>? options;
  final int order;

  static QuestionType typeFromString(String? s) {
    switch (s) {
      case 'singleChoice':
        return QuestionType.singleChoice;
      case 'yesNo':
        return QuestionType.yesNo;
      default:
        return QuestionType.text;
    }
  }

  static String typeToString(QuestionType t) {
    switch (t) {
      case QuestionType.singleChoice:
        return 'singleChoice';
      case QuestionType.yesNo:
        return 'yesNo';
      case QuestionType.text:
        return 'text';
    }
  }

  QuestionDef toDef() => QuestionDef(id: id, type: type, prompt: prompt, options: options, order: order);

  factory QuestionModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    final rawOpts = d['options'];
    List<String>? opts;
    if (rawOpts is List) {
      opts = rawOpts.map((e) => e.toString()).toList();
    }
    return QuestionModel(
      id: doc.id,
      type: typeFromString(d['type'] as String?),
      prompt: d['prompt'] as String? ?? '',
      options: opts,
      order: (d['order'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': typeToString(type),
      'prompt': prompt,
      'options': options,
      'order': order,
    };
  }
}
