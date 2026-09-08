import 'package:chronowarp/data/marvel_data.dart';
import 'package:chronowarp/data/lionking_data.dart';
import 'package:chronowarp/models/media_item.dart';
import 'package:chronowarp/pages/watch_party_lobby_page.dart';
import 'package:chronowarp/pages/watch_party_page.dart';
import 'package:chronowarp/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// ── Palette ───────────────────────────────────────────────────────────────────
const _bgPage = Color.fromRGBO(26, 41, 49, 1);
const _bgCard = Color.fromRGBO(40, 58, 68, 1);
const _bgChip = Color.fromRGBO(50, 72, 85, 1);
const _accent = Color(0xFFD4622A);
const _accentAlt = Color(0xFFFFB703);
const _textPri = Color(0xFFEEF1F4);
const _textMuted = Color(0xFF8AABB4);

// ── Per-universe card colours ─────────────────────────────────────────────────
const _universeColors = {
  'Marvel Cinematic Universe': Color(0xFF0E2A47),
  'Lion King': Color(0xFF2A1A06),
  'Star Wars Universe': Color(0xFF0A0A1F),
};

const _universeAccents = {
  'Marvel Cinematic Universe': Color(0xFFED1D24),
  'Lion King': Color(0xFFD4A017),
  'Star Wars Universe': Color(0xFF4FC3F7),
};

// ── Helpers ───────────────────────────────────────────────────────────────────
List<MediaItem> _itemsForUniverse(String key) {
  switch (key) {
    case 'Marvel Cinematic Universe':
      return mcuReleaseOrder;
    case 'Lion King':
      return lionKingReleaseOrder;
    default:
      return [];
  }
}

String _shortUniverseName(String key) {
  switch (key) {
    case 'Marvel Cinematic Universe':
      return 'Marvel';
    case 'Star Wars Universe':
      return 'Star Wars';
    case 'Lion King':
      return 'Lion King';
    default:
      return key;
  }
}

// ── Page ──────────────────────────────────────────────────────────────────────
class WatchPartyDiscoverPage extends StatelessWidget {
  const WatchPartyDiscoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService.instance;

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
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Watch Parties',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: _textPri,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Marathon with your friends',
                          style: TextStyle(fontSize: 13, color: _textMuted),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WatchPartyLobbyPage(),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _accent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.add, color: Colors.white, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'New Party',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Pending invites banner ───────────────────────────
            StreamBuilder<DocumentSnapshot>(
              stream: service.myFriendsStream(),
              builder: (context, snap) {
                if (!snap.hasData) return const SizedBox.shrink();
                final data = snap.data!.data() as Map<String, dynamic>?;
                final invites = List<String>.from(
                  data?['pendingPartyInvites'] ?? [],
                );
                if (invites.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  child: GestureDetector(
                    onTap: () => _showInvitesSheet(context, invites, service),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: _accent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _accent.withOpacity(0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.mail_outline_rounded,
                            color: _accent,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '${invites.length} pending party invite${invites.length != 1 ? 's' : ''}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _accent,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: _accent,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // ── Party grid ───────────────────────────────────────
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: service.myPartiesStream(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: _accent),
                    );
                  }

                  final docs = snap.data?.docs ?? [];

                  if (docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.local_movies_outlined,
                            size: 56,
                            color: _textMuted,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No watch parties yet',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _textPri,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Start one with your friends',
                            style: TextStyle(fontSize: 13, color: _textMuted),
                          ),
                          const SizedBox(height: 24),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const WatchPartyLobbyPage(),
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: _accent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                '+ Create a party',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.82,
                        ),
                    itemCount: docs.length,
                    itemBuilder: (context, i) {
                      final doc = docs[i];
                      final data = doc.data() as Map<String, dynamic>;
                      return _PartyCard(
                        partyId: doc.id,
                        data: data,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WatchPartyPage(partyId: doc.id),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInvitesSheet(
    BuildContext context,
    List<String> inviteIds,
    FirestoreService service,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Party Invites',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _textPri,
              ),
            ),
            const SizedBox(height: 16),
            ...inviteIds.map(
              (partyId) => _InviteTile(
                partyId: partyId,
                service: service,
                onAccepted: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WatchPartyPage(partyId: partyId),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Party card ────────────────────────────────────────────────────────────────
class _PartyCard extends StatelessWidget {
  final String partyId;
  final Map<String, dynamic> data;
  final VoidCallback onTap;

  const _PartyCard({
    required this.partyId,
    required this.data,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final universeKey = data['universeKey'] as String? ?? '';
    final memberIds = List<String>.from(data['memberIds'] ?? []);
    final watchedNums = List<int>.from(
      (data['watchedNumbers'] as List? ?? []).map((e) => e as int),
    );
    final items = _itemsForUniverse(universeKey);
    final total = items.length;
    final progress = total > 0 ? watchedNums.length / total : 0.0;
    final cardColor = _universeColors[universeKey] ?? _bgCard;
    final accentColor = _universeAccents[universeKey] ?? _accent;

    MediaItem? nextUp;
    try {
      nextUp = items.firstWhere((i) => !watchedNums.contains(i.number));
    } catch (_) {
      nextUp = null;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accentColor.withOpacity(0.35), width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Universe pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _shortUniverseName(universeKey),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: accentColor,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Party title
              Text(
                data['title'] ?? universeKey,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _textPri,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 10),

              // Member avatars
              _MemberAvatarRow(
                memberIds: memberIds,
                service: FirestoreService.instance,
              ),
              const Spacer(),

              // Progress bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${watchedNums.length}/$total watched',
                        style: const TextStyle(
                          fontSize: 10,
                          color: _textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${(progress * 100).round()}%',
                        style: TextStyle(
                          fontSize: 10,
                          color: accentColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 5,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Next up
              if (nextUp != null)
                Row(
                  children: [
                    Icon(
                      Icons.play_arrow_rounded,
                      size: 14,
                      color: accentColor,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        nextUp.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: _textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Icon(Icons.check_circle, size: 14, color: accentColor),
                    const SizedBox(width: 4),
                    Text(
                      'All watched!',
                      style: TextStyle(
                        fontSize: 11,
                        color: accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Member avatar row ─────────────────────────────────────────────────────────
class _MemberAvatarRow extends StatelessWidget {
  final List<String> memberIds;
  final FirestoreService service;

  const _MemberAvatarRow({required this.memberIds, required this.service});

  @override
  Widget build(BuildContext context) {
    final visible = memberIds.take(4).toList();
    final overflow = memberIds.length - 4;

    return Row(
      children: [
        ...visible.map(
          (uid) => FutureBuilder<Map<String, dynamic>?>(
            future: service.getUser(uid),
            builder: (context, snap) {
              final name = snap.data?['displayName'] ?? '?';
              return Padding(
                padding: const EdgeInsets.only(right: 4),
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.white.withOpacity(0.15),
                  child: Text(
                    name[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: _textPri,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (overflow > 0)
          CircleAvatar(
            radius: 12,
            backgroundColor: Colors.white.withOpacity(0.1),
            child: Text(
              '+$overflow',
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: _textMuted,
              ),
            ),
          ),
      ],
    );
  }
}

// ── Invite tile ───────────────────────────────────────────────────────────────
class _InviteTile extends StatelessWidget {
  final String partyId;
  final FirestoreService service;
  final VoidCallback onAccepted;

  const _InviteTile({
    required this.partyId,
    required this.service,
    required this.onAccepted,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: service.partyStream(partyId),
      builder: (context, snap) {
        if (!snap.hasData) return const SizedBox.shrink();
        final data = snap.data!.data() as Map<String, dynamic>?;
        if (data == null) return const SizedBox.shrink();

        final universeKey = data['universeKey'] as String? ?? '';
        final memberCount = (data['memberIds'] as List?)?.length ?? 0;
        final accentColor = _universeAccents[universeKey] ?? _accent;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: _universeColors[universeKey] ?? _bgChip,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: accentColor.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _shortUniverseName(universeKey),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _textPri,
                      ),
                    ),
                    Text(
                      '$memberCount member${memberCount != 1 ? 's' : ''}',
                      style: const TextStyle(fontSize: 12, color: _textMuted),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () async {
                  await service.acceptPartyInvite(partyId);
                  onAccepted();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Join',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () async {
                  await service.declinePartyInvite(partyId);
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Decline',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _textMuted,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
