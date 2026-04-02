import 'package:flutter_test/flutter_test.dart';
import 'package:mygang/core/domain/event_rules.dart';

void main() {
  final baseTime = DateTime(2030, 6, 15, 18, 0);

  group('Regras de negócio: evento', () {
    test('título vazio é inválido', () {
      final r = validateEventDraft(
        EventDraft(
          title: '  ',
          description: 'd',
          startsAt: baseTime,
          kind: EventKind.online,
          meetingLink: 'https://meet.example',
          location: null,
          capacity: null,
        ),
      );
      expect(r.isValid, false);
      expect(r.errorCode, EventValidationError.emptyTitle);
    });

    test('evento online exige link de acesso', () {
      final r = validateEventDraft(
        EventDraft(
          title: 'Live',
          description: '',
          startsAt: baseTime,
          kind: EventKind.online,
          meetingLink: '  ',
          location: null,
          capacity: null,
        ),
      );
      expect(r.isValid, false);
      expect(r.errorCode, EventValidationError.missingMeetingLink);
    });

    test('evento presencial exige local', () {
      final r = validateEventDraft(
        EventDraft(
          title: 'Encontro',
          description: '',
          startsAt: baseTime,
          kind: EventKind.presencial,
          meetingLink: null,
          location: '   ',
          capacity: null,
        ),
      );
      expect(r.isValid, false);
      expect(r.errorCode, EventValidationError.missingLocation);
    });

    test('evento híbrido exige link e local', () {
      expect(
        validateEventDraft(
          EventDraft(
            title: 'H',
            description: '',
            startsAt: baseTime,
            kind: EventKind.hibrido,
            meetingLink: '',
            location: 'Rua A',
            capacity: null,
          ),
        ).isValid,
        false,
      );
      expect(
        validateEventDraft(
          EventDraft(
            title: 'H',
            description: '',
            startsAt: baseTime,
            kind: EventKind.hibrido,
            meetingLink: 'https://x',
            location: '',
            capacity: null,
          ),
        ).isValid,
        false,
      );
      expect(
        validateEventDraft(
          EventDraft(
            title: 'H',
            description: '',
            startsAt: baseTime,
            kind: EventKind.hibrido,
            meetingLink: 'https://x',
            location: 'Auditório',
            capacity: null,
          ),
        ).isValid,
        true,
      );
    });

    test('capacidade informada deve ser positiva', () {
      final r = validateEventDraft(
        EventDraft(
          title: 'T',
          description: '',
          startsAt: baseTime,
          kind: EventKind.presencial,
          meetingLink: null,
          location: 'Lugar',
          capacity: 0,
        ),
      );
      expect(r.isValid, false);
      expect(r.errorCode, EventValidationError.invalidCapacity);
    });

    test('capacidade null é permitida', () {
      final r = validateEventDraft(
        EventDraft(
          title: 'T',
          description: '',
          startsAt: baseTime,
          kind: EventKind.presencial,
          meetingLink: null,
          location: 'Lugar',
          capacity: null,
        ),
      );
      expect(r.isValid, true);
    });
  });
}
