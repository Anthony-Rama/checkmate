import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:checkmate/main.dart';
import 'package:checkmate/firebase_options.dart';
import 'package:checkmate/screens/home_screen.dart';
import 'package:checkmate/screens/sign_in_page.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  });

  testWidgets('Widget Test with Real Firebase Connection',
      (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    // The following tests depend on the real authentication state.
    // For example, if no user is currently signed in, the SignInPage will be displayed.
    // If a user is signed in, the HomeScreen or another relevant screen will be displayed.

    // Check for the presence of SignInPage or HomeScreen based on the auth state.
    expect(
      find.byType(SignInPage).evaluate().isNotEmpty ||
          find.byType(MyHomePage).evaluate().isNotEmpty,
      true,
    );

    // Add more tests based on your app's functionality and UI.
  });
}
