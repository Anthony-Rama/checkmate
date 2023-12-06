import 'package:checkmate/screens/LeaderboardScreen.dart';
import 'package:checkmate/screens/set_tasks.dart';
import 'package:flutter/material.dart';

class StudyGroupDetailsScreen extends StatelessWidget {
  final String groupId;
  final String groupName;

  StudyGroupDetailsScreen(
      {Key? key, required this.groupId, required this.groupName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Group Details'),
      ),
      body: Center(
        // Use Center to ensure content is centered on the screen
        child: Column(
          mainAxisSize: MainAxisSize.min, // Use MainAxisSize.min for the Column
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SetTasksScreen(groupId: groupId),
                  ),
                );
              },
              child: Text('View Tasks'),
            ),
            SizedBox(height: 20), // Spacing between buttons
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LeaderboardScreen(
                        groupId: groupId, groupName: groupName),
                  ),
                );
              },
              child: Text('View Leaderboard'),
            ),
          ],
        ),
      ),
    );
  }
}
