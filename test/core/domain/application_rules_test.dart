import 'package:flutter_test/flutter_test.dart';
import 'package:mygang/core/domain/application_rules.dart';
import 'package:mygang/core/domain/questionnaire_rules.dart';

void main() {
  final questionnaire = [
    const QuestionDef(id: 'a', type: QuestionType.text, prompt: 'Bio', options: null, order: 0),
    const QuestionDef(
      id: 'b',
      type: QuestionType.singleChoice,
      prompt: 'Área',
      options: ['Dev', 'Design'],
      order: 1,
    ),
    const QuestionDef(id: 'c', type: QuestionType.yesNo, prompt: 'Maior de idade?', options: null, order: 2),
  ];

  group('Regras de negócio: respostas do questionário de entrada', () {
    test('todas as perguntas devem ter resposta', () {
      final r = validateApplicationAnswers(
        questionnaire,
        {'a': 'Sou dev', 'b': 'Dev'},
      );
      expect(r.isValid, false);
      expect(r.errorCode, ApplicationValidationError.missingAnswer);
    });

    test('resposta de texto vazia é inválida', () {
      final r = validateApplicationAnswers(
        questionnaire,
        {'a': '  ', 'b': 'Dev', 'c': 'sim'},
      );
      expect(r.isValid, false);
      expect(r.errorCode, ApplicationValidationError.invalidTextAnswer);
    });

    test('escolha única deve ser uma das opções', () {
      final r = validateApplicationAnswers(
        questionnaire,
        {'a': 'Bio ok', 'b': 'Marketing', 'c': 'sim'},
      );
      expect(r.isValid, false);
      expect(r.errorCode, ApplicationValidationError.invalidSingleChoice);
    });

    test('sim/não aceita sim, não, yes, no (case insensitive)', () {
      expect(
        validateApplicationAnswers(questionnaire, {
          'a': 'x',
          'b': 'Design',
          'c': 'SIM',
        }).isValid,
        true,
      );
      expect(
        validateApplicationAnswers(questionnaire, {
          'a': 'x',
          'b': 'Dev',
          'c': 'no',
        }).isValid,
        true,
      );
    });

    test('sim/não inválido rejeita', () {
      final r = validateApplicationAnswers(
        questionnaire,
        {'a': 'x', 'b': 'Dev', 'c': 'talvez'},
      );
      expect(r.isValid, false);
      expect(r.errorCode, ApplicationValidationError.invalidYesNo);
    });

    test('conjunto completo e válido é aceito', () {
      final r = validateApplicationAnswers(
        questionnaire,
        {'a': 'Quero participar', 'b': 'Dev', 'c': 'não'},
      );
      expect(r.isValid, true);
    });
  });
}
