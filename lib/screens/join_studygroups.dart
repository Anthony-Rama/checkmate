import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class JoinStudyGroupsScreen extends StatefulWidget {
  final VoidCallback onGroupJoined;

  JoinStudyGroupsScreen({Key? key, required this.onGroupJoined})
      : super(key: key);

  @override
  _JoinStudyGroupsScreenState createState() => _JoinStudyGroupsScreenState();
}

class _JoinStudyGroupsScreenState extends State<JoinStudyGroupsScreen> {
  final _groupKeyController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> joinGroup() async {
    final String key = _groupKeyController.text.trim();
    final user = _auth.currentUser;

    if (key.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Group key cannot be empty.')),
      );
      return;
    }

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You must be logged in to join a group.')),
      );
      return;
    }

    try {
      final QuerySnapshot groupSnapshot = await _firestore
          .collection('groups')
          .where('key', isEqualTo: key)
          .limit(1)
          .get();

      if (groupSnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No group found with that key.')),
        );
        return;
      }

      final DocumentSnapshot groupDoc = groupSnapshot.docs.first;
      final groupId = groupDoc.id;

      // Add the user to the group's 'members' subcollection
      await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('members')
          .doc(user.uid)
          .set({
        'email': user.email, // Use the user's email as their identifier
        'points': 0, // Initialize their points to 0
      });

      // Also add the group reference to the user's 'groups' subcollection
      await _firestore
          .collection('Users')
          .doc(user.uid)
          .collection('groups')
          .doc(groupId)
          .set({
        'name': groupDoc.get('name'),
        'key': key,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully joined the group.')),
      );

      widget.onGroupJoined(); // Call the callback function
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error joining group: $e')),
      );
    }
  }

  @override
  void dispose() {
    _groupKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Join Study Group'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _groupKeyController,
              decoration: InputDecoration(
                labelText: 'Enter Group Key',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                joinGroup();
              },
              child: Text('Join Group'),
            ),
          ],
        ),
      ),
    );
  }
}
