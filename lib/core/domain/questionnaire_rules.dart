import 'biz_validation.dart';

enum QuestionType { text, singleChoice, yesNo }

enum QuestionValidationError {
  emptyPrompt,
  invalidOptions,
  yesNoMustHaveNoOptions,
}

class QuestionDef {
  const QuestionDef({
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
}

BizValidation<QuestionValidationError> validateQuestionDef(QuestionDef q) {
  if (q.prompt.trim().isEmpty) {
    return const BizValidation.fail(QuestionValidationError.emptyPrompt);
  }
  switch (q.type) {
    case QuestionType.text:
      break;
    case QuestionType.singleChoice:
      final opts = q.options;
      if (opts == null || opts.length < 2) {
        return const BizValidation.fail(QuestionValidationError.invalidOptions);
      }
      for (final o in opts) {
        if (o.trim().isEmpty) {
          return const BizValidation.fail(QuestionValidationError.invalidOptions);
        }
      }
    case QuestionType.yesNo:
      if (q.options != null && q.options!.isNotEmpty) {
        return const BizValidation.fail(QuestionValidationError.yesNoMustHaveNoOptions);
      }
  }
  return const BizValidation.ok();
}
