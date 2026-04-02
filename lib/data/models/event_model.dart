import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mygang/core/domain/event_rules.dart';

class EventModel {
  EventModel({
    required this.id,
    required this.groupId,
    required this.title,
    required this.description,
    required this.startsAt,
    required this.kind,
    this.meetingLink,
    this.location,
    this.capacity,
    required this.createdBy,
  });

  final String id;
  final String groupId;
  final String title;
  final String description;
  final DateTime startsAt;
  final EventKind kind;
  final String? meetingLink;
  final String? location;
  final int? capacity;
  final String createdBy;

  static EventKind kindFromString(String? s) {
    switch (s) {
      case 'online':
        return EventKind.online;
      case 'hibrido':
        return EventKind.hibrido;
      default:
        return EventKind.presencial;
    }
  }

  static String kindToString(EventKind k) {
    switch (k) {
      case EventKind.online:
        return 'online';
      case EventKind.hibrido:
        return 'hibrido';
      case EventKind.presencial:
        return 'presencial';
    }
  }

  factory EventModel.fromDoc(String groupId, DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return EventModel(
      id: doc.id,
      groupId: groupId,
      title: d['title'] as String? ?? '',
      description: d['description'] as String? ?? '',
      startsAt: (d['startsAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      kind: kindFromString(d['kind'] as String?),
      meetingLink: d['meetingLink'] as String?,
      location: d['location'] as String?,
      capacity: (d['capacity'] as num?)?.toInt(),
      createdBy: d['createdBy'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'startsAt': Timestamp.fromDate(startsAt),
      'kind': kindToString(kind),
      'meetingLink': meetingLink,
      'location': location,
      'capacity': capacity,
      'createdBy': createdBy,
    };
  }
}
