import 'package:chronowarp/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chronowarp/pages/watch_party_page.dart';
import 'package:flutter/material.dart';

const _bgPage = Color.fromRGBO(26, 41, 49, 1);
const _bgCard = Color.fromRGBO(40, 58, 68, 1);
const _bgChip = Color.fromRGBO(50, 72, 85, 1);
const _accent = Color(0xFFD4622A);
const _textPri = Color(0xFFEEF1F4);
const _textMuted = Color(0xFF8AABB4);

/// All known universes the user can pick for a watch party.
const _universeOptions = [
  'Marvel Cinematic Universe',
  'Star Wars Universe',
  'Lion King',
];

class WatchPartyLobbyPage extends StatefulWidget {
  const WatchPartyLobbyPage({super.key});

  @override
  State<WatchPartyLobbyPage> createState() => _WatchPartyLobbyPageState();
}

class _WatchPartyLobbyPageState extends State<WatchPartyLobbyPage> {
  final _service = FirestoreService.instance;
  String? _selectedUniverse;
  final Set<String> _invitedUids = {};
  bool _creating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgPage,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: _textMuted),
                    style: IconButton.styleFrom(
                      backgroundColor: _bgCard,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(36, 36),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'New Watch Party',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _textPri,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Universe picker ──────────────────────────
                    _sectionLabel('Choose a Universe'),
                    const SizedBox(height: 10),
                    ..._universeOptions.map((u) => _universeTile(u)),
                    const SizedBox(height: 24),

                    // ── Friends to invite ────────────────────────
                    _sectionLabel('Invite Friends'),
                    const SizedBox(height: 10),
                    _buildFriendPicker(),
                    const SizedBox(height: 32),

                    // ── Create button ────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _selectedUniverse == null || _creating
                            ? null
                            : _createParty,
                        style: FilledButton.styleFrom(
                          backgroundColor: _accent,
                          disabledBackgroundColor: _bgChip,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _creating
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Create Party',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: _textMuted,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _universeTile(String universe) {
    final selected = _selectedUniverse == universe;
    return GestureDetector(
      onTap: () => setState(() => _selectedUniverse = universe),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? _accent.withValues(alpha: 0.12) : _bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? _accent : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.movie_filter_outlined,
              color: selected ? _accent : _textMuted,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              universe,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: selected ? _accent : _textPri,
              ),
            ),
            const Spacer(),
            if (selected)
              const Icon(Icons.check_circle, color: _accent, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendPicker() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _service.myFriendsStream(),
      builder: (context, snap) {
        if (!snap.hasData) return const CircularProgressIndicator();
        final data = snap.data!.data() as Map<String, dynamic>?;
        final friendIds = List<String>.from(data?['friendIds'] ?? []);

        if (friendIds.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _bgCard,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'No friends yet — add some from the Friends page first.',
              style: TextStyle(fontSize: 13, color: _textMuted),
            ),
          );
        }

        return Column(
          children: friendIds.map((uid) => _friendInviteTile(uid)).toList(),
        );
      },
    );
  }

  Widget _friendInviteTile(String uid) {
    final invited = _invitedUids.contains(uid);
    return FutureBuilder<Map<String, dynamic>?>(
      future: _service.getUser(uid),
      builder: (context, snap) {
        final user = snap.data;
        return GestureDetector(
          onTap: () {
            setState(() {
              if (invited) {
                _invitedUids.remove(uid);
              } else {
                _invitedUids.add(uid);
              }
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: invited ? _accent.withValues(alpha: 0.08) : _bgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: invited ? _accent.withValues(alpha: 0.4) : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: _accent.withValues(alpha: 0.2),
                  child: Text(
                    (user?['displayName'] ?? '?')[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _accent,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    user?['displayName'] ?? 'Loading…',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _textPri,
                    ),
                  ),
                ),
                Icon(
                  invited ? Icons.check_circle : Icons.circle_outlined,
                  color: invited ? _accent : _textMuted,
                  size: 20,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _createParty() async {
    setState(() => _creating = true);
    try {
      final partyId = await _service.createWatchParty(
        universeKey: _selectedUniverse!,
        title: _selectedUniverse!,
        invitedUids: _invitedUids.toList(),
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => WatchPartyPage(partyId: partyId)),
      );
    } catch (e) {
      setState(() => _creating = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to create party: $e')));
    }
  }
}
