import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mygang/core/domain/application_rules.dart';
import 'package:mygang/core/domain/group_rules.dart';
import 'package:mygang/core/domain/questionnaire_rules.dart';
import 'package:mygang/data/models/group_model.dart';
import 'package:mygang/data/models/question_model.dart';

class GroupRepository {
  GroupRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _groups => _firestore.collection('groups');

  Stream<List<GroupModel>> watchAllGroups() {
    return _groups.orderBy('createdAt', descending: true).snapshots().map(
          (s) => s.docs.map(GroupModel.fromDoc).toList(),
        );
  }

  Stream<GroupModel?> watchGroup(String groupId) {
    return _groups.doc(groupId).snapshots().map((d) {
      if (!d.exists) return null;
      return GroupModel.fromDoc(d);
    });
  }

  Stream<MemberModel?> watchMyMembership(String groupId, String uid) {
    return _groups.doc(groupId).collection('members').doc(uid).snapshots().map((d) {
      if (!d.exists) return null;
      return MemberModel.fromDoc(d);
    });
  }

  Stream<List<QuestionModel>> watchQuestions(String groupId) {
    return _groups
        .doc(groupId)
        .collection('questions')
        .orderBy('order')
        .snapshots()
        .map((s) => s.docs.map(QuestionModel.fromDoc).toList());
  }

  Stream<List<ApplicationEntry>> watchApplications(String groupId) {
    return _groups
        .doc(groupId)
        .collection('applications')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((s) => s.docs.map(ApplicationEntry.fromDoc).toList());
  }

  Future<String> createGroup({
    required String ownerId,
    required String name,
    String? description,
  }) async {
    final v = validateGroupDraft(GroupDraft(name: name, description: description));
    if (!v.isValid) {
      throw GroupValidationException(v.errorCode!);
    }
    final ref = _groups.doc();
    // Duas escritas em sequência (não batch): as regras de `members` fazem get no
    // grupo; num batch a ordem de avaliação não é garantida e pode dar permission-denied.
    await ref.set({
      'name': name.trim(),
      'description': (description ?? '').trim(),
      'ownerId': ownerId,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await ref.collection('members').doc(ownerId).set({
      'role': 'admin',
      'status': 'active',
      'joinedAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<void> upsertQuestion(String groupId, QuestionModel q) async {
    final v = validateQuestionDef(q.toDef());
    if (!v.isValid) {
      throw QuestionValidationException(v.errorCode!);
    }
    final col = _groups.doc(groupId).collection('questions');
    final doc = q.id.isEmpty ? col.doc() : col.doc(q.id);
    await doc.set(q.toFirestore(), SetOptions(merge: true));
  }

  Future<void> deleteQuestion(String groupId, String questionId) {
    return _groups.doc(groupId).collection('questions').doc(questionId).delete();
  }

  Future<void> submitApplication({
    required String groupId,
    required String userId,
    required Map<String, String> answers,
    required List<QuestionDef> questionnaire,
  }) async {
    final v = validateApplicationAnswers(questionnaire, answers);
    if (!v.isValid) {
      throw ApplicationValidationException(v.errorCode!);
    }
    await _groups.doc(groupId).collection('applications').add({
      'userId': userId,
      'answers': answers,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> approveApplication({
    required String groupId,
    required String applicationId,
    required String applicantUserId,
  }) async {
    final appRef = _groups.doc(groupId).collection('applications').doc(applicationId);
    final memberRef = _groups.doc(groupId).collection('members').doc(applicantUserId);
    final batch = _firestore.batch();
    batch.update(appRef, {'status': 'approved'});
    batch.set(memberRef, {
      'role': 'member',
      'status': 'active',
      'joinedAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  Future<void> rejectApplication(String groupId, String applicationId) {
    return _groups.doc(groupId).collection('applications').doc(applicationId).update({'status': 'rejected'});
  }

  Future<bool> hasPendingApplication(String groupId, String userId) async {
    final q = await _groups.doc(groupId).collection('applications').where('userId', isEqualTo: userId).get();
    return q.docs.any((d) => (d.data()['status'] as String?) == 'pending');
  }
}

class GroupValidationException implements Exception {
  GroupValidationException(this.error);
  final GroupValidationError error;
}

class QuestionValidationException implements Exception {
  QuestionValidationException(this.error);
  final QuestionValidationError error;
}

class ApplicationValidationException implements Exception {
  ApplicationValidationException(this.error);
  final ApplicationValidationError error;
}

class ApplicationEntry {
  ApplicationEntry({
    required this.id,
    required this.userId,
    required this.answers,
    required this.status,
  });

  final String id;
  final String userId;
  final Map<String, String> answers;
  final String status;

  factory ApplicationEntry.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    if (d == null) {
      return ApplicationEntry(id: doc.id, userId: '', answers: const {}, status: 'pending');
    }
    final raw = d['answers'];
    final map = <String, String>{};
    if (raw is Map) {
      raw.forEach((k, v) {
        map[k.toString()] = v?.toString() ?? '';
      });
    }
    return ApplicationEntry(
      id: doc.id,
      userId: d['userId'] as String? ?? '',
      answers: map,
      status: d['status'] as String? ?? 'pending',
    );
  }
}
