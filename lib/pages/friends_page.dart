import 'package:chronowarp/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// ── Palette ──────────────────────────────────────────────────────────────────
const _bgPage = Color.fromRGBO(26, 41, 49, 1);
const _bgCard = Color.fromRGBO(40, 58, 68, 1);
const _bgChip = Color.fromRGBO(50, 72, 85, 1);

const _accent = Color(0xFFD4622A);
const _accentAlt = Color(0xFFFFB703);

const _textPri = Color(0xFFEEF1F4);
const _textMuted = Color(0xFF8AABB4);

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  final _service = FirestoreService.instance;
  final _searchController = TextEditingController();

  List<Map<String, dynamic>> _searchResults = [];
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _searching = true;
    });

    final results = await _service.searchUsers(query.trim());

    setState(() {
      _searchResults = results;
      _searching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgPage,

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ─────────────────────────────────────────────
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
                          'Friends',

                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: _textPri,
                            letterSpacing: -0.5,
                          ),
                        ),

                        Text(
                          'Connect with your friends',

                          style: TextStyle(fontSize: 13, color: _textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Tabs ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),

              child: Container(
                decoration: BoxDecoration(
                  color: _bgCard,

                  borderRadius: BorderRadius.circular(10),
                ),

                padding: const EdgeInsets.all(3),

                child: TabBar(
                  controller: _tabs,

                  dividerColor: Colors.transparent,

                  indicator: BoxDecoration(
                    color: _bgChip,

                    borderRadius: BorderRadius.circular(8),
                  ),

                  labelColor: _textPri,

                  unselectedLabelColor: _textMuted,

                  labelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),

                  unselectedLabelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),

                  tabs: const [
                    Tab(text: 'Friends', height: 36),

                    Tab(text: 'Requests', height: 36),

                    Tab(text: 'Find', height: 36),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: TabBarView(
                controller: _tabs,

                children: [_buildFriendsList(), _buildRequests(), _buildFind()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Friends list ────────────────────────────────────────────────

  Widget _buildFriendsList() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _service.myFriendsStream(),

      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator(color: _accent));
        }

        final data = snap.data!.data() as Map<String, dynamic>?;

        final friendIds = List<String>.from(data?['friendIds'] ?? []);

        if (friendIds.isEmpty) {
          return _emptyState(
            'No friends yet',
            'Search for people in the Find tab',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),

          itemCount: friendIds.length,

          itemBuilder: (context, i) {
            return _buildFriendTile(friendIds[i]);
          },
        );
      },
    );
  }

  Widget _buildFriendTile(String uid) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _service.getUser(uid),

      builder: (context, snap) {
        final user = snap.data;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),

          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),

          decoration: BoxDecoration(
            color: _bgCard,

            borderRadius: BorderRadius.circular(16),
          ),

          child: Row(
            children: [
              _avatar(user?['displayName'] ?? '?'),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  user?['displayName'] ?? 'Loading…',

                  style: const TextStyle(
                    fontSize: 15,

                    fontWeight: FontWeight.w600,

                    color: _textPri,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  // ── Requests ────────────────────────────────────────────────────────────────

  Widget _buildRequests() {
    return StreamBuilder<QuerySnapshot>(
      stream: _service.incomingRequestsStream(),

      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator(color: _accent));
        }

        final docs = snap.data!.docs;

        if (docs.isEmpty) {
          return _emptyState(
            'No pending requests',
            'When someone adds you they\'ll appear here',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),

          itemCount: docs.length,

          itemBuilder: (context, i) {
            final doc = docs[i];

            final fromUid = doc['fromUid'] as String;

            return FutureBuilder<Map<String, dynamic>?>(
              future: _service.getUser(fromUid),

              builder: (context, userSnap) {
                final user = userSnap.data;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),

                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),

                  decoration: BoxDecoration(
                    color: _bgCard,

                    borderRadius: BorderRadius.circular(16),
                  ),

                  child: Row(
                    children: [
                      _avatar(user?['displayName'] ?? '?'),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Text(
                          user?['displayName'] ?? 'Loading…',

                          style: const TextStyle(
                            fontSize: 15,

                            fontWeight: FontWeight.w600,

                            color: _textPri,
                          ),
                        ),
                      ),

                      _actionButton('Accept', _accent, () async {
                        await _service.respondToRequest(doc.id, true);
                      }),

                      const SizedBox(width: 8),

                      _actionButton('Decline', _bgChip, () async {
                        await _service.respondToRequest(doc.id, false);
                      }),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // ── Find Friends ────────────────────────────────────────────────────────────

  Widget _buildFind() {
    final myUid = FirebaseAuth.instance.currentUser!.uid;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),

          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),

            decoration: BoxDecoration(
              color: _bgCard,

              borderRadius: BorderRadius.circular(12),
            ),

            child: Row(
              children: [
                const Icon(Icons.search, color: _textMuted, size: 18),

                const SizedBox(width: 8),

                Expanded(
                  child: TextField(
                    controller: _searchController,

                    style: const TextStyle(color: _textPri, fontSize: 14),

                    decoration: const InputDecoration(
                      border: InputBorder.none,

                      hintText: 'Search by display name…',

                      hintStyle: TextStyle(color: _textMuted, fontSize: 14),
                    ),

                    onChanged: _search,
                  ),
                ),

                if (_searching)
                  const SizedBox(
                    width: 16,

                    height: 16,

                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _accent,
                    ),
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        Expanded(
          child: _searchResults.isEmpty
              ? _emptyState('Search for friends', 'Type a display name above')
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),

                  itemCount: _searchResults.length,

                  itemBuilder: (context, i) {
                    final user = _searchResults[i];

                    final uid = user['uid'] as String;

                    if (uid == myUid) {
                      return const SizedBox.shrink();
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),

                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),

                      decoration: BoxDecoration(
                        color: _bgCard,

                        borderRadius: BorderRadius.circular(16),
                      ),

                      child: Row(
                        children: [
                          _avatar(user['displayName'] ?? '?'),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Text(
                              user['displayName'] ?? '',

                              style: const TextStyle(
                                fontSize: 15,

                                fontWeight: FontWeight.w600,

                                color: _textPri,
                              ),
                            ),
                          ),

                          _actionButton('Add', _accent, () async {
                            await _service.sendFriendRequest(uid);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Friend request sent'),
                              ),
                            );
                          }),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _avatar(String name) {
    return CircleAvatar(
      radius: 18,

      backgroundColor: _accent.withOpacity(0.15),

      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',

        style: const TextStyle(
          fontSize: 14,

          fontWeight: FontWeight.w700,

          color: _accent,
        ),
      ),
    );
  }

  Widget _actionButton(String label, Color color, VoidCallback onTap) {
    final filled = color == _accent;

    return GestureDetector(
      onTap: onTap,

      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

        decoration: BoxDecoration(
          color: filled ? _accent : _bgChip,

          borderRadius: BorderRadius.circular(8),
        ),

        child: Text(
          label,

          style: TextStyle(
            fontSize: 12,

            fontWeight: FontWeight.w700,

            color: filled ? Colors.white : _textMuted,
          ),
        ),
      ),
    );
  }

  Widget _emptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,

        children: [
          const Icon(Icons.people_outline, size: 56, color: _textMuted),

          const SizedBox(height: 16),

          Text(
            title,

            style: const TextStyle(
              fontSize: 16,

              fontWeight: FontWeight.w600,

              color: _textPri,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            subtitle,

            style: const TextStyle(fontSize: 13, color: _textMuted),
          ),
        ],
      ),
    );
  }
}
