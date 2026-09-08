import 'package:chronowarp/pages/login_page.dart';
import 'package:chronowarp/pages/user_creation_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('returning from signup keeps the root login listener alive', (
    tester,
  ) async {
    final signedIn = ValueNotifier(false);
    addTearDown(signedIn.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: ValueListenableBuilder<bool>(
          valueListenable: signedIn,
          builder: (context, value, child) => value
              ? const Scaffold(body: Text('Authenticated home'))
              : const LoginPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Create account'));
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();
    expect(find.byType(UserCreationPage), findsOneWidget);
    final back = find.text('Already have an account? return to Login');
    await tester.ensureVisible(back);
    await tester.tap(back);
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);
    signedIn.value = true;
    await tester.pumpAndSettle();
    expect(find.text('Authenticated home'), findsOneWidget);
    expect(find.byType(LoginPage), findsNothing);
  });
}
