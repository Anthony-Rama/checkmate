import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'join_studygroups.dart';
import 'StudyGroupDetailsScreen.dart';
import 'createnewgroup.dart';
import 'sign_in_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, String>> currentStudyGroups =
      []; // Store both group name and ID

  @override
  void initState() {
    super.initState();
    fetchUserGroups();
  }

  Future<void> fetchUserGroups() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userGroupsRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .collection('groups');
      final querySnapshot = await userGroupsRef.get();

      final groups = querySnapshot.docs
          .map((doc) => {
                'name': doc.data()['name'].toString(),
                'id': doc.id // Store the group's document ID
              })
          .toList();

      setState(() {
        currentStudyGroups = groups;
      });
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => SignInPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.deepPurpleAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: _signOut,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.deepPurpleAccent, Colors.purple[100]!],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Your Study Groups',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white // Setting text color to white
                    ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: currentStudyGroups.length,
                  itemBuilder: (context, index) {
                    var group = currentStudyGroups[index];
                    return Card(
                      elevation: 5,
                      child: ListTile(
                        title: Text(group['name'] ?? ''),
                        trailing: Icon(Icons.arrow_forward_ios,
                            color: Colors.deepPurpleAccent),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StudyGroupDetailsScreen(
                                groupId: group['id'] ?? '',
                                groupName: group['name'] ?? '',
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                style:
                    ElevatedButton.styleFrom(primary: Colors.deepPurpleAccent),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          JoinStudyGroupsScreen(onGroupJoined: fetchUserGroups),
                    ),
                  );
                },
                child: Text('Join More Study Groups',
                    style: TextStyle(color: Colors.white)),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                style:
                    ElevatedButton.styleFrom(primary: Colors.deepPurpleAccent),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateNewGroupScreen(),
                    ),
                  ).then((_) =>
                      fetchUserGroups()); // Refresh group list after returning
                },
                child: Text('Create a New Group',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
