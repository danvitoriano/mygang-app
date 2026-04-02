import 'biz_validation.dart';

enum GroupValidationError { emptyName, nameTooLong, descriptionTooLong }

const int kGroupNameMaxLength = 120;
const int kGroupDescriptionMaxLength = 2000;

class GroupDraft {
  const GroupDraft({required this.name, this.description});

  final String name;
  final String? description;
}

BizValidation<GroupValidationError> validateGroupDraft(GroupDraft draft) {
  final name = draft.name.trim();
  if (name.isEmpty) {
    return const BizValidation.fail(GroupValidationError.emptyName);
  }
  if (name.length > kGroupNameMaxLength) {
    return const BizValidation.fail(GroupValidationError.nameTooLong);
  }
  final desc = draft.description;
  if (desc != null && desc.length > kGroupDescriptionMaxLength) {
    return const BizValidation.fail(GroupValidationError.descriptionTooLong);
  }
  return const BizValidation.ok();
}
