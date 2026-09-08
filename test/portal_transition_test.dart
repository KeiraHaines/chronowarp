import 'package:chronowarp/transitions/portal_transition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _MountProbe extends StatefulWidget {
  final VoidCallback onMount;
  const _MountProbe({required this.onMount});
  @override
  State<_MountProbe> createState() => _MountProbeState();
}

class _MountProbeState extends State<_MountProbe> {
  @override
  void initState() {
    super.initState();
    widget.onMount();
  }

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Private home')));
}

void main() {
  testWidgets(
    'login portal retains Home state and clears it immediately on sign-out',
    (tester) async {
      final signedIn = ValueNotifier(false);
      addTearDown(signedIn.dispose);
      var mounts = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: ValueListenableBuilder<bool>(
            valueListenable: signedIn,
            builder: (context, value, _) => AuthPortalTransition(
              signedIn: value,
              child: value
                  ? _MountProbe(onMount: () => mounts++)
                  : const Scaffold(body: Text('Login')),
            ),
          ),
        ),
      );
      signedIn.value = true;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Login'), findsOneWidget);
      expect(mounts, 1);
      await tester.pumpAndSettle();
      expect(find.text('Login'), findsNothing);
      expect(mounts, 1);
      signedIn.value = false;
      await tester.pump();
      expect(find.text('Private home'), findsNothing);
      expect(find.text('Login'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'portal routes open and return without duplicating destination state',
    (tester) async {
      var mounts = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  PortalPageRoute(
                    builder: (_) => _MountProbe(onMount: () => mounts++),
                  ),
                ),
                child: const Text('Enter universe'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Enter universe'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      expect(mounts, 1);
      await tester.pumpAndSettle();
      expect(mounts, 1);
      tester.state<NavigatorState>(find.byType(Navigator)).pop();
      await tester.pumpAndSettle();
      expect(find.text('Enter universe'), findsOneWidget);
      expect(find.text('Private home'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('reduced motion skips the login portal', (tester) async {
    final signedIn = ValueNotifier(false);
    addTearDown(signedIn.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: ValueListenableBuilder<bool>(
            valueListenable: signedIn,
            builder: (_, value, child) => AuthPortalTransition(
              signedIn: value,
              child: Scaffold(body: Text(value ? 'Home' : 'Login')),
            ),
          ),
        ),
      ),
    );
    signedIn.value = true;
    await tester.pump();
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Login'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
