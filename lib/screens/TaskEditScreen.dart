import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TaskEditScreen extends StatefulWidget {
  final String groupId;
  final String? taskId; // Use taskId to identify the task being edited

  TaskEditScreen({Key? key, required this.groupId, this.taskId})
      : super(key: key);

  @override
  _TaskEditScreenState createState() => _TaskEditScreenState();
}

class _TaskEditScreenState extends State<TaskEditScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _saveTask() async {
    String taskDescription = _descriptionController.text.trim();
    if (taskDescription.isEmpty) return;

    CollectionReference tasksRef =
        _firestore.collection('groups').doc(widget.groupId).collection('tasks');

    if (widget.taskId == null) {
      await tasksRef.add({
        'description': taskDescription,
        'createdAt': FieldValue.serverTimestamp(),
        'points': 10,
        'completedBy': {},
      });
    } else {
      // Update existing task
      await tasksRef.doc(widget.taskId).update({
        'description': taskDescription,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.taskId == null ? 'Create Task' : 'Edit Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _descriptionController,
          decoration: InputDecoration(labelText: 'Task Name'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveTask,
        child: Icon(Icons.save),
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
}
