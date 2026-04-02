import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mygang/core/domain/event_rules.dart';
import 'package:mygang/data/models/event_model.dart';

class EventRepository {
  EventRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _eventsCol(String groupId) {
    return _firestore.collection('groups').doc(groupId).collection('events');
  }

  Stream<List<EventModel>> watchEvents(String groupId) {
    return _eventsCol(groupId).orderBy('startsAt').snapshots().map(
          (s) => s.docs.map((d) => EventModel.fromDoc(groupId, d)).toList(),
        );
  }

  Stream<EventModel?> watchEvent(String groupId, String eventId) {
    return _eventsCol(groupId).doc(eventId).snapshots().map((d) {
      if (!d.exists) return null;
      return EventModel.fromDoc(groupId, d);
    });
  }

  Future<EventModel?> getEvent(String groupId, String eventId) async {
    final d = await _eventsCol(groupId).doc(eventId).get();
    if (!d.exists) return null;
    return EventModel.fromDoc(groupId, d);
  }

  Future<String> createEvent({
    required String groupId,
    required String createdBy,
    required EventDraft draft,
  }) async {
    final v = validateEventDraft(draft);
    if (!v.isValid) {
      throw EventValidationException(v.errorCode!);
    }
    final doc = _eventsCol(groupId).doc();
    final model = EventModel(
      id: doc.id,
      groupId: groupId,
      title: draft.title.trim(),
      description: draft.description.trim(),
      startsAt: draft.startsAt,
      kind: draft.kind,
      meetingLink: _nonEmpty(draft.meetingLink),
      location: _nonEmpty(draft.location),
      capacity: draft.capacity,
      createdBy: createdBy,
    );
    await doc.set({...model.toFirestore()});
    return doc.id;
  }

  Future<void> updateEvent({
    required String groupId,
    required String eventId,
    required EventDraft draft,
  }) async {
    final v = validateEventDraft(draft);
    if (!v.isValid) {
      throw EventValidationException(v.errorCode!);
    }
    await _eventsCol(groupId).doc(eventId).update({
      'title': draft.title.trim(),
      'description': draft.description.trim(),
      'startsAt': Timestamp.fromDate(draft.startsAt),
      'kind': EventModel.kindToString(draft.kind),
      'meetingLink': _nonEmpty(draft.meetingLink),
      'location': _nonEmpty(draft.location),
      'capacity': draft.capacity,
    });
  }

  Future<void> deleteEvent(String groupId, String eventId) {
    return _eventsCol(groupId).doc(eventId).delete();
  }

  Stream<String?> watchRsvp(String groupId, String eventId, String uid) {
    return _eventsCol(groupId)
        .doc(eventId)
        .collection('rsvps')
        .doc(uid)
        .snapshots()
        .map((d) => d.data()?['status'] as String?);
  }

  Future<void> setRsvp(String groupId, String eventId, String uid, String status) {
    return _eventsCol(groupId).doc(eventId).collection('rsvps').doc(uid).set({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}

class EventValidationException implements Exception {
  EventValidationException(this.error);
  final EventValidationError error;
}

String? _nonEmpty(String? s) {
  if (s == null) return null;
  final t = s.trim();
  return t.isEmpty ? null : t;
}
