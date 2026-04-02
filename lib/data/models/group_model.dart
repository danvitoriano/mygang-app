import 'package:cloud_firestore/cloud_firestore.dart';

class GroupModel {
  GroupModel({
    required this.id,
    required this.name,
    required this.description,
    required this.ownerId,
    required this.createdAt,
    this.photoUrl,
  });

  final String id;
  final String name;
  final String description;
  final String ownerId;
  final DateTime createdAt;
  final String? photoUrl;

  factory GroupModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return GroupModel(
      id: doc.id,
      name: d['name'] as String? ?? '',
      description: d['description'] as String? ?? '',
      ownerId: d['ownerId'] as String? ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      photoUrl: d['photoUrl'] as String?,
    );
  }
}

class MemberModel {
  MemberModel({required this.userId, required this.role, required this.status, this.joinedAt});

  final String userId;
  final String role;
  final String status;
  final DateTime? joinedAt;

  factory MemberModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return MemberModel(
      userId: doc.id,
      role: d['role'] as String? ?? 'member',
      status: d['status'] as String? ?? 'active',
      joinedAt: (d['joinedAt'] as Timestamp?)?.toDate(),
    );
  }

  bool get isAdmin => role == 'admin';
  bool get isActive => status == 'active';
}
