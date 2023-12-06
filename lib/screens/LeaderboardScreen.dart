import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LeaderboardScreen extends StatefulWidget {
  final String groupId;
  final String groupName;

  LeaderboardScreen({Key? key, required this.groupId, required this.groupName})
      : super(key: key);

  @override
  _LeaderboardScreenState createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<Map<String, int>> get leaderboardStream =>
      Stream.fromFuture(_calculatePoints());

  Future<Map<String, int>> _calculatePoints() async {
    // Holds the total points for each user
    Map<String, int> userPoints = {};

    // Initialize all group members with 0 points
    var membersSnapshot = await _firestore
        .collection('groups')
        .doc(widget.groupId)
        .collection('members')
        .get();

    for (var member in membersSnapshot.docs) {
      String userId = member.id; // Assuming the document ID is the user ID
      userPoints[userId] = 0; // Start with 0 points
    }

    // Get all tasks and their completion status
    var tasksSnapshot = await _firestore
        .collection('groups')
        .doc(widget.groupId)
        .collection('tasks')
        .get();

    for (var task in tasksSnapshot.docs) {
      Map<String, dynamic> completedBy = task.data()['completedBy'] ?? {};
      completedBy.forEach((userId, completed) {
        if (completed == true) {
          // If the task is completed by this user, add points
          userPoints[userId] = (userPoints[userId] ?? 0) + 10;
        }
      });
    }

    // Fetch user usernames based on their UIDs
    Map<String, String> userNames = {};
    for (String userId in userPoints.keys) {
      var userDoc = await _firestore.collection('users').doc(userId).get();
      // Use 'username' field where you store user names
      userNames[userId] = userDoc.data()?['username'] ?? 'Unknown';
    }

    // Map of user names to points
    Map<String, int> userNamePoints = {};
    userPoints.forEach((userId, points) {
      String name = userNames[userId] ??
          'Unknown'; // Use username or fallback to 'Unknown'
      userNamePoints[name] = points;
    });

    return userNamePoints;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leaderboard for ${widget.groupName}'),
      ),
      body: StreamBuilder<Map<String, int>>(
        stream: leaderboardStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return Center(child: Text('No leaderboard data available.'));
          }
          var leaderboardData = snapshot.data!;
          var sortedEntries = leaderboardData.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          return ListView.builder(
            itemCount: sortedEntries.length,
            itemBuilder: (context, index) {
              var entry = sortedEntries[index];
              return ListTile(
                title: Text(entry.key),
                trailing: Text('${entry.value} Points'),
              );
            },
          );
        },
      ),
    );
  }
}
