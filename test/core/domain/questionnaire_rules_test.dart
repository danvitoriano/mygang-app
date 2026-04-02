import 'package:flutter_test/flutter_test.dart';
import 'package:mygang/core/domain/questionnaire_rules.dart';

void main() {
  group('Regras de negócio: definição de pergunta', () {
    test('texto curto válido sem opções', () {
      final r = validateQuestionDef(
        const QuestionDef(id: 'q1', type: QuestionType.text, prompt: 'Por quê?', options: null, order: 0),
      );
      expect(r.isValid, true);
    });

    test('escolha única exige ao menos duas opções não vazias', () {
      expect(
        validateQuestionDef(
          const QuestionDef(
            id: 'q1',
            type: QuestionType.singleChoice,
            prompt: 'Nível?',
            options: ['a'],
            order: 0,
          ),
        ).isValid,
        false,
      );
      expect(
        validateQuestionDef(
          const QuestionDef(
            id: 'q1',
            type: QuestionType.singleChoice,
            prompt: 'Nível?',
            options: ['a', '  '],
            order: 0,
          ),
        ).errorCode,
        QuestionValidationError.invalidOptions,
      );
      expect(
        validateQuestionDef(
          const QuestionDef(
            id: 'q1',
            type: QuestionType.singleChoice,
            prompt: 'Nível?',
            options: ['Iniciante', 'Avançado'],
            order: 0,
          ),
        ).isValid,
        true,
      );
    });

    test('sim/não não deve ter opções customizadas', () {
      final r = validateQuestionDef(
        const QuestionDef(
          id: 'q1',
          type: QuestionType.yesNo,
          prompt: 'Aceita regras?',
          options: ['Sim', 'Não'],
          order: 0,
        ),
      );
      expect(r.isValid, false);
      expect(r.errorCode, QuestionValidationError.yesNoMustHaveNoOptions);
    });

    test('enunciado vazio é inválido', () {
      final r = validateQuestionDef(
        const QuestionDef(id: 'q1', type: QuestionType.text, prompt: '  ', options: null, order: 0),
      );
      expect(r.isValid, false);
      expect(r.errorCode, QuestionValidationError.emptyPrompt);
    });
  });
}
