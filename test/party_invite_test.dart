import 'package:chronowarp/pages/party_invite_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'only available friends can be selected and invitations require sending',
    (tester) async {
      List<String>? sent;
      await tester.pumpWidget(
        MaterialApp(
          home: PartyInvitePage(
            partyId: 'party',
            currentUid: 'me',
            party: Stream.value({
              'leaderUid': 'me',
              'memberIds': ['me', 'member'],
            }),
            friends: Stream.value(['member', 'pending', 'new']),
            user: (id) => Stream.value({
              'displayName': id,
              'pendingPartyInvites': id == 'pending' ? ['party'] : [],
            }),
            send: (ids) async {
              sent = ids;
              throw StateError('offline');
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Already in party'), findsOneWidget);
      expect(find.text('Invited'), findsOneWidget);
      for (final label in ['member', 'pending']) {
        final tile = tester.widget<CheckboxListTile>(
          find.ancestor(
            of: find.text(label),
            matching: find.byType(CheckboxListTile),
          ),
        );
        expect(tile.onChanged, isNull);
      }
      await tester.tap(find.text('new'));
      await tester.pumpAndSettle();
      expect(sent, isNull);
      await tester.tap(find.text('Send invitations (1)'));
      await tester.pumpAndSettle();
      expect(sent, ['new']);
      expect(
        find.text(
          'Could not send invitations. Check your connection and try again.',
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('non-leaders cannot send invites', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PartyInvitePage(
          partyId: 'party',
          currentUid: 'me',
          party: Stream.value({'leaderUid': 'other'}),
          friends: Stream.value(['friend']),
          user: (_) => Stream.value({}),
          send: (_) async => 0,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Only the party leader can invite friends.'),
      findsOneWidget,
    );
    expect(find.byType(CheckboxListTile), findsNothing);
  });
}
