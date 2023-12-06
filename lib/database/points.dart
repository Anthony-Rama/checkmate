import 'package:cloud_firestore/cloud_firestore.dart';

class PointsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> completeTask(
      String groupId, String userId, bool taskCompleted) async {
    var groupRef = _firestore.collection('groups').doc(groupId);
    var memberRef = groupRef.collection('members').doc(userId);

    return _firestore.runTransaction((transaction) async {
      var memberSnapshot = await transaction.get(memberRef);
      var memberData = memberSnapshot.data() as Map<String, dynamic>?;
      var currentPoints = memberData?['points'] ?? 0;
      var newPoints = taskCompleted ? currentPoints + 10 : currentPoints;

      transaction.update(memberRef, {'points': newPoints});
    });
  }

  Future<void> addUserToGroup(
      String groupId, String userId, String userName) async {
    var memberRef = _firestore
        .collection('groups')
        .doc(groupId)
        .collection('members')
        .doc(userId);
    var memberSnapshot = await memberRef.get();

    if (!memberSnapshot.exists) {
      await memberRef.set({
        'name': userName,
        'points': 0,
      });
    }
  }
}
