import 'package:flutter/material.dart';
import '../widgets/profile_avatar.dart';

class PartyInvitePage extends StatefulWidget {
  final String partyId;
  final String currentUid;
  final Stream<Map<String, dynamic>?> party;
  final Stream<List<String>> friends;
  final Stream<Map<String, dynamic>?> Function(String) user;
  final Future<int> Function(List<String>) send;
  const PartyInvitePage({
    super.key,
    required this.partyId,
    required this.currentUid,
    required this.party,
    required this.friends,
    required this.user,
    required this.send,
  });
  @override
  State<PartyInvitePage> createState() => _PartyInvitePageState();
}

class _PartyInvitePageState extends State<PartyInvitePage> {
  final selected = <String>{};
  final users = <String, Stream<Map<String, dynamic>?>>{};
  bool sending = false;
  String? error;
  Future<void> _send(List<String> ids) async {
    setState(() {
      sending = true;
      error = null;
    });
    try {
      final count = await widget.send(ids);
      if (mounted) Navigator.pop(context, count);
    } catch (_) {
      if (mounted)
        setState(() {
          sending = false;
          error =
              'Could not send invitations. Check your connection and try again.';
        });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF1A2931),
    appBar: AppBar(
      title: const Text('Invite friends'),
      backgroundColor: const Color(0xFF1A2931),
      foregroundColor: Colors.white,
    ),
    body: StreamBuilder<Map<String, dynamic>?>(
      stream: widget.party,
      builder: (context, partySnap) {
        if (partySnap.hasError)
          return const Center(
            child: Text(
              'Party unavailable. Please reopen this page.',
              style: TextStyle(color: Colors.white),
            ),
          );
        if (partySnap.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());
        final party = partySnap.data;
        if (party == null || party['leaderUid'] != widget.currentUid)
          return const Center(
            child: Text(
              'Only the party leader can invite friends.',
              style: TextStyle(color: Colors.white),
            ),
          );
        final members = List<String>.from(party['memberIds'] ?? []);
        return StreamBuilder<List<String>>(
          stream: widget.friends,
          builder: (context, friendsSnap) {
            if (friendsSnap.hasError)
              return const Center(
                child: Text(
                  'Friends unavailable. Please reopen this page.',
                  style: TextStyle(color: Colors.white),
                ),
              );
            if (!friendsSnap.hasData)
              return const Center(child: CircularProgressIndicator());
            final ids = friendsSnap.data!
                .where((id) => id != widget.currentUid)
                .toSet()
                .toList();
            final toSend = selected
                .where((id) => ids.contains(id) && !members.contains(id))
                .toList();
            return SafeArea(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'Choose friends to join this watch party.',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  Expanded(
                    child: ids.isEmpty
                        ? const Center(
                            child: Text(
                              'Add friends from the Friends page first.',
                              style: TextStyle(color: Colors.white70),
                            ),
                          )
                        : ListView.builder(
                            itemCount: ids.length,
                            itemBuilder: (context, index) {
                              final id = ids[index];
                              return StreamBuilder<Map<String, dynamic>?>(
                                stream: users.putIfAbsent(
                                  id,
                                  () => widget.user(id),
                                ),
                                builder: (context, snap) {
                                  final data = snap.data;
                                  final member = members.contains(id);
                                  final invited = List<String>.from(
                                    data?['pendingPartyInvites'] ?? [],
                                  ).contains(widget.partyId);
                                  final disabled =
                                      sending ||
                                      member ||
                                      invited ||
                                      data == null ||
                                      snap.hasError;
                                  final name =
                                      data?['displayName'] as String? ??
                                      (snap.hasError
                                          ? 'Friend unavailable'
                                          : 'Loading…');
                                  return CheckboxListTile(
                                    title: Text(
                                      name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    subtitle: member
                                        ? const Text(
                                            'Already in party',
                                            style: TextStyle(
                                              color: Colors.white70,
                                            ),
                                          )
                                        : invited
                                        ? const Text(
                                            'Invited',
                                            style: TextStyle(
                                              color: Colors.white70,
                                            ),
                                          )
                                        : null,
                                    secondary: ProfileAvatar(
                                      name: name,
                                      avatarId: data?['avatarId'] as String?,
                                    ),
                                    value:
                                        member ||
                                        invited ||
                                        selected.contains(id),
                                    onChanged: disabled
                                        ? null
                                        : (value) => setState(() {
                                            if (value == true) {
                                              selected.add(id);
                                            } else {
                                              selected.remove(id);
                                            }
                                          }),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        error!,
                        style: const TextStyle(color: Colors.orangeAccent),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: sending || toSend.isEmpty
                            ? null
                            : () => _send(toSend),
                        icon: const Icon(Icons.person_add_alt_1),
                        label: Text(
                          sending
                              ? 'Sending…'
                              : 'Send invitations (${toSend.length})',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ),
  );
}
