import 'package:flutter_test/flutter_test.dart';
import 'package:mygang/core/domain/biz_validation.dart';
import 'package:mygang/core/domain/group_rules.dart';

void main() {
  test('smoke: validação de grupo alinhada ao TDD', () {
    final r = validateGroupDraft(const GroupDraft(name: 'Gang', description: null));
    expect(r, isA<BizValidation<GroupValidationError>>());
    expect(r.isValid, isTrue);
  });
}
