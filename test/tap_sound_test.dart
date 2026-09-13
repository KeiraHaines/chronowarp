import 'package:chronowarp/widgets/tap_sound_feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
void main() {
 testWidgets('buttons click once while disabled controls and scrolling stay silent', (tester) async {
 var sounds=0, presses=0;
 await tester.pumpWidget(MaterialApp(home: TapSoundFeedback(onTapSound:()=>sounds++,child: Scaffold(body: ListView(children:[TextButton(onPressed:()=>presses++,child: const Text('Tap')),const TextButton(onPressed:null,child:Text('Disabled')),const SizedBox(height:2000)])))));
 await tester.tap(find.text('Tap'));await tester.pump();
 expect(sounds,1);expect(presses,1);
 await tester.tap(find.text('Disabled'));await tester.pump();expect(sounds,1);
 await tester.drag(find.text('Tap'),const Offset(0,-100));await tester.pumpAndSettle();expect(sounds,1);
 });
}
