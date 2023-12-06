import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:checkmate/screens/home_screen.dart';

class CreateAccountPage extends StatefulWidget {
  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController =
      TextEditingController(); // Add controller for username

  Future<void> _createAccount() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Get the user ID of the newly created user
      String userId = userCredential.user!.uid;

      // Store the username in Firestore
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'email': _emailController.text,
        'username': _usernameController.text, // Store the username
        // Add other initial user data as needed
      });

      // Navigate to the home page
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => MyHomePage(title: 'CheckMate Home')));
    } on FirebaseAuthException catch (e) {
      // Handle error (e.g., show an error message)
      print(e.message); // Consider displaying this in a user-friendly way
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Account')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextFormField(
              controller: _usernameController, // Add TextField for username
              decoration: InputDecoration(labelText: 'Username'),
            ),
            ElevatedButton(
              onPressed: _createAccount,
              child: Text('Create Account'),
            ),
          ],
        ),
      ),
    );
  }
}
