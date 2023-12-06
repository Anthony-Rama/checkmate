import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:checkmate/database/task.dart';

class TaskEditScreen extends StatefulWidget {
  final String groupId;
  final Task? task;

  TaskEditScreen({Key? key, required this.groupId, this.task})
      : super(key: key);

  @override
  _TaskEditScreenState createState() => _TaskEditScreenState();
}

class _TaskEditScreenState extends State<TaskEditScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _descriptionController.text = widget.task!.description;
    }
  }

  Future<void> _saveTask() async {
    if (_descriptionController.text.isEmpty) return;

    if (widget.task == null) {
      // Add new task
      await _firestore
          .collection('groups')
          .doc(widget.groupId)
          .collection('tasks')
          .add({
        'description': _descriptionController.text,
        'points': 10,
        'completedBy': {},
      });
    } else {
      // Update existing task
      await _firestore
          .collection('groups')
          .doc(widget.groupId)
          .collection('tasks')
          .doc(widget.task!.id)
          .update({'description': _descriptionController.text});
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _descriptionController,
          decoration: InputDecoration(labelText: 'Task Description'),
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
