import 'biz_validation.dart';
import 'questionnaire_rules.dart';

enum ApplicationValidationError {
  missingAnswer,
  invalidTextAnswer,
  invalidSingleChoice,
  invalidYesNo,
}

BizValidation<ApplicationValidationError> validateApplicationAnswers(
  List<QuestionDef> questionnaire,
  Map<String, String> answersByQuestionId,
) {
  for (final q in questionnaire) {
    final raw = answersByQuestionId[q.id];
    if (raw == null) {
      return const BizValidation.fail(ApplicationValidationError.missingAnswer);
    }
    switch (q.type) {
      case QuestionType.text:
        if (raw.trim().isEmpty) {
          return const BizValidation.fail(ApplicationValidationError.invalidTextAnswer);
        }
      case QuestionType.singleChoice:
        final opts = q.options ?? const [];
        final normalized = raw.trim();
        final match = opts.any((o) => o.trim() == normalized);
        if (!match) {
          return const BizValidation.fail(ApplicationValidationError.invalidSingleChoice);
        }
      case QuestionType.yesNo:
        if (!_parseYesNo(raw)) {
          return const BizValidation.fail(ApplicationValidationError.invalidYesNo);
        }
    }
  }
  return const BizValidation.ok();
}

bool _parseYesNo(String raw) {
  final t = raw.trim().toLowerCase();
  return t == 'sim' || t == 'não' || t == 'nao' || t == 'yes' || t == 'no';
}
