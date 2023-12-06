import 'package:checkmate/screens/create_account.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:checkmate/firebase_options.dart';
import 'package:checkmate/screens/home_screen.dart';
import 'package:checkmate/screens/sign_in_page.dart';
import 'package:checkmate/screens/join_studygroups.dart';
import 'package:checkmate/screens/createnewgroup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(MyApp());
  } catch (e) {
    print(
        e); // If Firebase initialization fails, print the error for debugging purposes
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CheckMate',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => AuthenticationWrapper(),
        '/signIn': (context) => SignInPage(),
        '/createAccount': (context) => CreateAccountPage(),
        '/home': (context) => MyHomePage(title: 'CheckMate Home'),
        '/joinStudyGroups': (context) => JoinStudyGroupsScreen(
              onGroupJoined: () {},
            ),
        '/createNewGroup': (context) => CreateNewGroupScreen(),
        // Add other routes as needed
      },
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasError) {
            print(snapshot.error);
            return Center(child: Text('Something went wrong'));
          } else if (snapshot.hasData) {
            return MyHomePage(title: 'CheckMate Home'); // User is signed in
          } else {
            return SignInPage(); // User is not signed in
          }
        }
        return Center(
            child:
                CircularProgressIndicator()); // Waiting for authentication state
      },
    );
  }
}
