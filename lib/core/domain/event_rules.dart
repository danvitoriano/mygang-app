import 'biz_validation.dart';

enum EventKind { presencial, online, hibrido }

enum EventValidationError {
  emptyTitle,
  missingMeetingLink,
  missingLocation,
  invalidCapacity,
}

class EventDraft {
  const EventDraft({
    required this.title,
    required this.description,
    required this.startsAt,
    required this.kind,
    this.meetingLink,
    this.location,
    this.capacity,
  });

  final String title;
  final String description;
  final DateTime startsAt;
  final EventKind kind;
  final String? meetingLink;
  final String? location;
  final int? capacity;
}

BizValidation<EventValidationError> validateEventDraft(EventDraft draft) {
  if (draft.title.trim().isEmpty) {
    return const BizValidation.fail(EventValidationError.emptyTitle);
  }
  final cap = draft.capacity;
  if (cap != null && cap <= 0) {
    return const BizValidation.fail(EventValidationError.invalidCapacity);
  }

  switch (draft.kind) {
    case EventKind.online:
      if (_blank(draft.meetingLink)) {
        return const BizValidation.fail(EventValidationError.missingMeetingLink);
      }
    case EventKind.presencial:
      if (_blank(draft.location)) {
        return const BizValidation.fail(EventValidationError.missingLocation);
      }
    case EventKind.hibrido:
      if (_blank(draft.meetingLink)) {
        return const BizValidation.fail(EventValidationError.missingMeetingLink);
      }
      if (_blank(draft.location)) {
        return const BizValidation.fail(EventValidationError.missingLocation);
      }
  }
  return const BizValidation.ok();
}

bool _blank(String? s) => s == null || s.trim().isEmpty;
