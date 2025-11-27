import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mensacare/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('login flow: enter credentials and open home', (WidgetTester tester) async {
    // Launch the real app entrypoint inside tester.runAsync so async platform
    // calls (plugins, path_provider, sqflite) can complete during the test.
    await tester.runAsync(() async {
      print('integration_test: calling app.main()');
      app.main();
      // allow background async work (DB init, plugin setup) to run
      await Future.delayed(const Duration(seconds: 1));
    });

    // Wait for the UI to settle; increase timeout to 30s for slower devices
    await tester.pumpAndSettle(const Duration(seconds: 30));

    // Ensure app booted
    expect(find.byType(MaterialApp), findsOneWidget);

    // Enter login credentials using Keys added to the widgets
    final userField = find.byKey(const Key('login_user_field'));
    final passField = find.byKey(const Key('login_password_field'));
    final loginButton = find.byKey(const Key('login_button'));

    expect(userField, findsOneWidget);
    expect(passField, findsOneWidget);
    expect(loginButton, findsOneWidget);

    await tester.enterText(userField, 'testuser@example.com');
    await tester.enterText(passField, 'password123');

    await tester.tap(loginButton);
    await tester.pumpAndSettle(const Duration(seconds: 10));

    // After login we expect to reach HomeScreen which contains a BottomNavigationBar
    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });
}
