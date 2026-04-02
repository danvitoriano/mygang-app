import 'package:flutter_test/flutter_test.dart';
import 'package:mygang/core/domain/group_rules.dart';

void main() {
  group('Regras de negócio: grupo', () {
    test('nome vazio após trim é inválido', () {
      final r = validateGroupDraft(const GroupDraft(name: '   ', description: null));
      expect(r.isValid, false);
      expect(r.errorCode, GroupValidationError.emptyName);
    });

    test('nome com pelo menos um caractere válido é aceito', () {
      final r = validateGroupDraft(const GroupDraft(name: 'Dev SP', description: null));
      expect(r.isValid, true);
    });

    test('nome acima do limite máximo é inválido', () {
      final r = validateGroupDraft(GroupDraft(name: 'a' * 121, description: null));
      expect(r.isValid, false);
      expect(r.errorCode, GroupValidationError.nameTooLong);
    });

    test('descrição opcional null é válida', () {
      final r = validateGroupDraft(const GroupDraft(name: 'Gang', description: null));
      expect(r.isValid, true);
    });

    test('descrição acima do limite é inválida', () {
      final r = validateGroupDraft(GroupDraft(name: 'Gang', description: 'x' * 2001));
      expect(r.isValid, false);
      expect(r.errorCode, GroupValidationError.descriptionTooLong);
    });
  });
}
