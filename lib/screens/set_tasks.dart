import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'TaskEditScreen.dart';
import 'package:checkmate/database/task.dart';

class SetTasksScreen extends StatefulWidget {
  final String groupId;

  SetTasksScreen({Key? key, required this.groupId}) : super(key: key);

  @override
  _SetTasksScreenState createState() => _SetTasksScreenState();
}

class _SetTasksScreenState extends State<SetTasksScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<Task>> get groupTasksStream {
    return _firestore
        .collection('groups')
        .doc(widget.groupId)
        .collection('tasks')
        .orderBy('createdAt', descending: false) // Order by creation time
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Task.fromFirestore(doc.data() as Map<String, dynamic>,
                doc.id, _auth.currentUser?.uid))
            .toList());
  }

  void _toggleTaskCompletion(Task task, bool completed) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('groups')
          .doc(widget.groupId)
          .collection('tasks')
          .doc(task.id)
          .update({
        'completedBy.${user.uid}': completed,
      });

      // Optionally update user points here
      // ...
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Group Tasks'),
      ),
      body: StreamBuilder<List<Task>>(
        stream: groupTasksStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          var tasks = snapshot.data!;
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              var task = tasks[index];
              return ListTile(
                title: Text(task.description),
                trailing: Checkbox(
                  value: task.isCompletedByCurrentUser,
                  onChanged: (bool? value) {
                    _toggleTaskCompletion(task, value ?? false);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskEditScreen(groupId: widget.groupId),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
