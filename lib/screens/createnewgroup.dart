import 'dart:io';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateNewGroupScreen extends StatefulWidget {
  @override
  _CreateNewGroupScreenState createState() => _CreateNewGroupScreenState();
}

class _CreateNewGroupScreenState extends State<CreateNewGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  String _groupName = '';
  XFile? _groupImage;
  final ImagePicker _picker = ImagePicker();

  // Function to generate a random key for the group
  String generateGroupKey() {
    var rng = Random();
    var codeUnits = List.generate(6, (index) => rng.nextInt(26) + 65);
    return String.fromCharCodes(codeUnits);
  }

  // Function to handle group image selection
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _groupImage = image;
    });
  }

  // Function to save group data to Firestore
  Future<void> _createGroupInFirestore(
      String groupName, String groupKey) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Create the new group in the root 'groups' collection
      DocumentReference newGroupRef =
          await FirebaseFirestore.instance.collection('groups').add({
        'name': groupName,
        'key': groupKey,
        'createdBy': user.uid, // Store the ID of the user who created the group
      });

      // Initialize the 'members' subcollection with the group creator
      await newGroupRef.collection('members').doc(user.uid).set({
        'email': user.email, // Assuming user.email is not null
        'points': 0,
      });

      // Add a reference to the new group in the user's 'groups' subcollection
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .collection('groups')
          .doc(newGroupRef.id)
          .set({
        'name': groupName,
        'key': groupKey,
        'groupId': newGroupRef.id, // Store the new group's ID
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String groupKey = generateGroupKey();

    return Scaffold(
      appBar: AppBar(
        title: Text('Create New Group'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Enter Group Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a group name';
                }
                return null;
              },
              onSaved: (value) {
                _groupName = value!;
              },
            ),
            SizedBox(height: 16),
            if (_groupImage != null) Image.file(File(_groupImage!.path)),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Group Image'),
            ),
            SizedBox(height: 16),
            Text(
              'Your Group Key: $groupKey',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  _createGroupInFirestore(_groupName, groupKey).then((_) {
                    Navigator.of(context).pop();
                  }).catchError((error) {
                    Navigator.of(context).pop();
                    // Handle the error here if necessary
                  });
                }
              },
              child: Text('Create Group'),
            ),
          ],
        ),
      ),
    );
  }
}
