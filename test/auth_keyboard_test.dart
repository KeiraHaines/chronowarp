import 'package:chronowarp/pages/login_page.dart';
import 'package:chronowarp/pages/user_creation_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final page in <String, Widget>{
    'Login': const LoginPage(),
    'Sign Up': const UserCreationPage(),
  }.entries) {
    testWidgets('${page.key} remains reachable above the keyboard', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 780);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpWidget(MaterialApp(home: page.value));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.showKeyboard(find.byType(TextFormField).last);
      tester.view.viewInsets = FakeViewPadding(bottom: 320);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      final button = find.widgetWithText(ElevatedButton, page.key);
      await tester.ensureVisible(button);
      await tester.pumpAndSettle();
      expect(button.hitTestable(), findsOneWidget);
      expect(tester.getBottomRight(button).dy, lessThanOrEqualTo(460));
      expect(tester.takeException(), isNull);

      tester.view.resetViewInsets();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
