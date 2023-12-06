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
        'createdBy': user
            .uid, // Optionally store the ID of the user who created the group
        // Add other group details as necessary
      });

      // Add a reference to the new group in the user's 'groups' subcollection
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .collection('groups')
          .doc(newGroupRef.id) // Use the new group's ID as the document ID
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
            // Image picker for group picture
            if (_groupImage != null) Image.file(File(_groupImage!.path)),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Group Image'),
            ),
            SizedBox(height: 16),
            // Display the generated group key
            Text(
              'Your Group Key: $groupKey',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 16),
            // Button to create group
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  // Save the group data to Firestore
                  _createGroupInFirestore(_groupName, groupKey).then((_) {
                    // Show a SnackBar after popping the screen
                    Navigator.of(context).pop(); // Pop first
                  }).catchError((error) {
                    Navigator.of(context).pop(); // Pop first
                    // The actual SnackBar is shown by the previous screen that this screen returns to.
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
