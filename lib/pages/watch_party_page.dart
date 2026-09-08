import '../widgets/media_rating_sheet.dart';
import '../widgets/profile_avatar.dart';
import 'package:chronowarp/data/universe_configs.dart';
import 'package:chronowarp/widgets/universe_watch_page.dart';
import 'package:chronowarp/data/marvel_data.dart';
import 'package:chronowarp/data/lionking_data.dart';
import 'package:chronowarp/models/media_item.dart';
import 'package:chronowarp/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// ── Universe item lookup ──────────────────────────────────────────────────────
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

class WatchPartyPage extends StatefulWidget {
  final String partyId;
  const WatchPartyPage({super.key, required this.partyId});

  @override
  State<WatchPartyPage> createState() => _WatchPartyPageState();
}

class _WatchPartyPageState extends State<WatchPartyPage> {
  final _service = FirestoreService.instance;
  final _uid = FirebaseAuth.instance.currentUser!.uid;
  bool _isReleaseOrder = true;
  UniverseConfig? _universeConfig;
  Color get _bgPage =>
      _universeConfig?.bgPage ?? const Color.fromRGBO(26, 41, 49, 1);
  Color get _bgCard =>
      _universeConfig?.bgCard ?? const Color.fromRGBO(40, 58, 68, 1);
  Color get _bgChip =>
      _universeConfig?.bgChip ?? const Color.fromRGBO(50, 72, 85, 1);
  Color get _accent =>
      _universeConfig?.accentPrimary ?? const Color(0xFFD4622A);
  Color get _accentAlt =>
      _universeConfig?.accentSecondary ?? const Color(0xFFFFB703);
  Color get _textPri => _universeConfig?.textPrimary ?? const Color(0xFFEEF1F4);
  Color get _textMuted => _universeConfig?.textMuted ?? const Color(0xFF8AABB4);
  Color get _textCard => _universeConfig?.textCard ?? const Color(0xFFEEF1F4);
  Color get _textCardMuted =>
      _universeConfig?.textCardMuted ?? const Color(0xFF8AABB4);

  // ── Leave party ─────────────────────────────────────────────────────────────
  Future<void> _confirmLeave(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _bgCard,
        title: Text(
          'Leave party?',
          style: TextStyle(color: _textCard, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'You will be removed from this watch party.',
          style: TextStyle(color: _textCardMuted, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: TextStyle(color: _textCardMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Leave',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await _service.leaveParty(widget.partyId);
      if (mounted) Navigator.pop(context);
    }
  }

  // ── Back button ──────────────────────────────────────────────────────────────
  Widget _iconBtn(BuildContext context, IconData icon, VoidCallback onTap) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: _accent),
      style: IconButton.styleFrom(
        backgroundColor: _bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: EdgeInsets.zero,
        minimumSize: const Size(36, 36),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _service.partyStream(widget.partyId),
      builder: (context, partySnap) {
        final data = partySnap.data?.data() as Map<String, dynamic>?;
        _universeConfig = universeConfigFor(
          data?['universeKey'] as String? ?? '',
        );
        return Scaffold(
          backgroundColor: _bgPage,
          body: SafeArea(
            child: Builder(
              builder: (context) {
                // Loading — always show back button
                if (!partySnap.hasData) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                        child: Row(
                          children: [
                            _iconBtn(
                              context,
                              Icons.arrow_back,
                              () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: CircularProgressIndicator(color: _accent),
                        ),
                      ),
                    ],
                  );
                }

                final party = partySnap.data!.data() as Map<String, dynamic>;
                final universeKey = party['universeKey'] as String;
                final leaderUid = party['leaderUid'] as String;
                final memberIds = List<String>.from(party['memberIds'] ?? []);
                final watchedNums = List<int>.from(
                  (party['watchedNumbers'] as List).map((e) => e as int),
                );
                final isLeader = _uid == leaderUid;
                final allItems = _itemsForUniverse(universeKey);

                // Release vs chronological — for now both point to the same list
                // since party data only stores one universe key. You can extend
                // this once chronological lists are wired per universe.
                final items = allItems;

                final movieCount = items.where((i) => !i.isShow).length;
                final showCount = items.where((i) => i.isShow).length;
                final episodeCount = items.fold<int>(
                  0,
                  (sum, i) => sum + (i.episodes ?? 0),
                );
                final total = items.length;
                final progress = total > 0 ? watchedNums.length / total : 0.0;
                final percent = (progress * 100).round();

                MediaItem? nextUp;
                try {
                  nextUp = items.firstWhere(
                    (i) => !watchedNums.contains(i.number),
                  );
                } catch (_) {
                  nextUp = null;
                }

                return StreamBuilder<QuerySnapshot>(
                  stream: _service.partyRatingsStream(widget.partyId),
                  builder: (context, ratingsSnap) {
                    final ratingDocs = ratingsSnap.data?.docs ?? [];

                    return ScrollbarTheme(
                      data: ScrollbarThemeData(
                        thumbColor: WidgetStateProperty.all(_accentAlt),
                        radius: const Radius.circular(99),
                        thickness: WidgetStateProperty.all(4),
                        crossAxisMargin: 8,
                        mainAxisMargin: 12,
                      ),
                      child: Scrollbar(
                        thumbVisibility: false,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 20,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── Header (mirrors solo UI) ──────────────────────
                              SizedBox(
                                height: 40,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Text(
                                      party['title'] ?? universeKey,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: _textPri,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        _iconBtn(
                                          context,
                                          Icons.arrow_back,
                                          () => Navigator.pop(context),
                                        ),
                                        const Spacer(),
                                        _iconBtn(
                                          context,
                                          Icons.logout_rounded,
                                          () => _confirmLeave(context),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),

                              // ── Member avatars ────────────────────────────────
                              _buildMemberRow(memberIds),
                              const SizedBox(height: 16),

                              // ── Stat row ──────────────────────────────────────
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _statChip(
                                    Icons.movie_outlined,
                                    '$movieCount movies',
                                  ),
                                  const SizedBox(width: 8),
                                  _statChip(
                                    Icons.tv_outlined,
                                    '$showCount shows',
                                  ),
                                  const SizedBox(width: 8),
                                  if (episodeCount > 0)
                                    _statChip(
                                      Icons.play_circle_outline,
                                      '$episodeCount episodes',
                                    ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // ── Progress bar ──────────────────────────────────
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${watchedNums.length} of $total watched',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: _textMuted,
                                    ),
                                  ),
                                  Text(
                                    '$percent%',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: _accentAlt,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(99),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 6,
                                  backgroundColor: _bgChip,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _accentAlt,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),

                              // ── Order toggle ──────────────────────────────────
                              Container(
                                decoration: BoxDecoration(
                                  color: _bgCard,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.all(3),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _toggleOption(
                                        'Release Order',
                                        _isReleaseOrder,
                                        () => setState(
                                          () => _isReleaseOrder = true,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: _toggleOption(
                                        'Chronological Order',
                                        !_isReleaseOrder,
                                        () => setState(
                                          () => _isReleaseOrder = false,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // ── Item list ─────────────────────────────────────
                              if (items.isEmpty)
                                Center(
                                  child: Text(
                                    'No items found for "$universeKey"',
                                    style: TextStyle(
                                      color: _textMuted,
                                      fontSize: 14,
                                    ),
                                  ),
                                )
                              else
                                Column(
                                  children: items.map((item) {
                                    final isNextUp = item == nextUp;
                                    final isWatched = watchedNums.contains(
                                      item.number,
                                    );
                                    final itemRatings = ratingDocs
                                        .where(
                                          (d) => d['itemNumber'] == item.number,
                                        )
                                        .toList();
                                    return _buildItemCard(
                                      context: context,
                                      item: item,
                                      isNextUp: isNextUp,
                                      isWatched: isWatched,
                                      isLeader: isLeader,
                                      ratings: itemRatings,
                                    );
                                  }).toList(),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  // ── Member avatar row ────────────────────────────────────────────────────────
  Widget _buildMemberRow(List<String> memberIds) {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: memberIds.length,
        itemBuilder: (context, i) {
          final uid = memberIds[i];
          return StreamBuilder<Map<String, dynamic>?>(
            stream: _service
                .userStream(uid)
                .map((doc) => doc.data() as Map<String, dynamic>?),
            builder: (context, snap) {
              final name = snap.data?['displayName'] ?? '?';
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Tooltip(
                  message: name,
                  child: ProfileAvatar(
                    radius: 18,
                    name: name,
                    avatarId: snap.data?['avatarId'] as String?,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ── Stat chip ────────────────────────────────────────────────────────────────
  Widget _statChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _bgChip,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: _textMuted),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _textMuted,
            ),
          ),
        ],
      ),
    );
  }

  // ── Toggle option ────────────────────────────────────────────────────────────
  Widget _toggleOption(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _bgChip : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? _textPri : _textCardMuted,
          ),
        ),
      ),
    );
  }

  // ── Item card (mirrors solo UI + party extras) ────────────────────────────────
  Widget _buildItemCard({
    required BuildContext context,
    required MediaItem item,
    required bool isNextUp,
    required bool isWatched,
    required bool isLeader,
    required List<QueryDocumentSnapshot> ratings,
  }) {
    // Group average across all member ratings
    double? groupAvg;
    if (ratings.isNotEmpty) {
      final avgs = ratings
          .map((r) {
            final vals = [
              r['story'],
              r['acting'],
              r['action'],
              r['visuals'],
              r['sound'],
            ].whereType<num>().map((n) => n.toDouble()).toList();
            return vals.isEmpty
                ? null
                : vals.reduce((a, b) => a + b) / vals.length;
          })
          .whereType<double>()
          .toList();
      if (avgs.isNotEmpty) {
        groupAvg = avgs.reduce((a, b) => a + b) / avgs.length;
      }
    }

    final myRating = ratings.where((r) => r['uid'] == _uid).firstOrNull;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _bgCard,
        borderRadius: BorderRadius.circular(12),
        border: isNextUp ? Border.all(color: _accentAlt, width: 1.5) : null,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        // Leader taps the whole card to toggle watched
        onTap: isLeader
            ? () =>
                  _service.toggleWatched(widget.partyId, item.number, isWatched)
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Main card row ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  // Number / check badge
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: isWatched ? _accent : _accentAlt,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: isWatched
                          ? const Icon(
                              Icons.check,
                              size: 14,
                              color: Colors.white,
                            )
                          : Text(
                              '${item.number}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Title + meta
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isWatched ? _textCardMuted : _textCard,
                            decoration: isWatched
                                ? TextDecoration.lineThrough
                                : null,
                            decorationColor: _textCardMuted,
                          ),
                        ),
                        const SizedBox(height: 3),
                        if (item.isShow)
                          _buildShowMeta(item)
                        else
                          _buildMovieMeta(item),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Group avg + rate button (replaces solo rate)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (groupAvg != null)
                        Text(
                          '★ ${groupAvg.toStringAsFixed(1)}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _accentAlt,
                          ),
                        ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () => _showRatingSheet(item, myRating),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: myRating != null ? _accent : _bgChip,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            myRating != null ? 'Rated' : 'Rate',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: myRating != null
                                  ? Colors.white
                                  : _textMuted,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Poster (next up only — matches solo UI ratio) ──
            if (isNextUp)
              Padding(
                padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AspectRatio(
                    aspectRatio: 2 / 3,
                    child: item.posterPath != null
                        ? Image.asset(item.posterPath!, fit: BoxFit.cover)
                        : Container(
                            color: _bgChip,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_outlined,
                                  size: 48,
                                  color: _textMuted,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Poster coming soon',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: _textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
              ),

            // ── Blurb (next up only) ──────────────────────────
            if (isNextUp && item.blurb != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                child: Text(
                  item.blurb!,
                  style: TextStyle(
                    fontSize: 13,
                    color: _textCardMuted,
                    height: 1.5,
                  ),
                ),
              )
            else if (isNextUp)
              const SizedBox(height: 12),

            // ── Per-member ratings (watched items only) ────────
            if (ratings.isNotEmpty && isWatched)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                child: Column(
                  children: ratings
                      .map((r) => _buildMemberRatingRow(r))
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Per-member rating row ────────────────────────────────────────────────────
  Widget _buildMemberRatingRow(QueryDocumentSnapshot r) {
    final uid = r['uid'] as String;
    final vals = [
      r['story'],
      r['acting'],
      r['action'],
      r['visuals'],
      r['sound'],
    ].whereType<num>().map((n) => n.toDouble()).toList();
    final avg = vals.isEmpty
        ? null
        : vals.reduce((a, b) => a + b) / vals.length;

    return StreamBuilder<Map<String, dynamic>?>(
      stream: _service
          .userStream(uid)
          .map((doc) => doc.data() as Map<String, dynamic>?),
      builder: (context, snap) {
        final name = snap.data?['displayName'] ?? '…';
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              ProfileAvatar(
                radius: 10,
                name: name,
                avatarId: snap.data?['avatarId'] as String?,
              ),
              const SizedBox(width: 8),
              Text(name, style: TextStyle(fontSize: 12, color: _textCardMuted)),
              const Spacer(),
              if (avg != null)
                Text(
                  '${avg.toStringAsFixed(1)}/10',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _accentAlt,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // ── Movie meta ───────────────────────────────────────────────────────────────
  Widget _buildMovieMeta(MediaItem item) {
    return Row(
      children: [
        Icon(Icons.calendar_today_outlined, size: 12, color: _textCardMuted),
        const SizedBox(width: 4),
        Text(
          '${item.year}',
          style: TextStyle(fontSize: 12, color: _textCardMuted),
        ),
        if (item.runtime != null) ...[
          const SizedBox(width: 8),
          Icon(Icons.access_time_outlined, size: 12, color: _textCardMuted),
          const SizedBox(width: 4),
          Text(
            item.runtime!,
            style: TextStyle(fontSize: 12, color: _textCardMuted),
          ),
        ],
      ],
    );
  }

  // ── Show meta ────────────────────────────────────────────────────────────────
  Widget _buildShowMeta(MediaItem item) {
    return Row(
      children: [
        Icon(Icons.calendar_today_outlined, size: 12, color: _textCardMuted),
        const SizedBox(width: 4),
        Text(
          '${item.year}',
          style: TextStyle(fontSize: 12, color: _textCardMuted),
        ),
        const SizedBox(width: 8),
        Icon(Icons.layers_outlined, size: 13, color: _textCardMuted),
        const SizedBox(width: 4),
        Text(
          '${item.seasons} season${(item.seasons ?? 0) > 1 ? 's' : ''}',
          style: TextStyle(fontSize: 12, color: _textCardMuted),
        ),
        const SizedBox(width: 8),
        Icon(Icons.play_circle_outline, size: 13, color: _textCardMuted),
        const SizedBox(width: 4),
        Text(
          '${item.episodes} episodes',
          style: TextStyle(fontSize: 12, color: _textCardMuted),
        ),
      ],
    );
  }

  void _showRatingSheet(MediaItem item, QueryDocumentSnapshot? existing) {
    showMediaRatingSheet(
      context: context,
      title: item.title,
      initialRating: CategoryRating(
        story: existing?['story']?.toDouble(),
        acting: existing?['acting']?.toDouble(),
        action: existing?['action']?.toDouble(),
        visuals: existing?['visuals']?.toDouble(),
        sound: existing?['sound']?.toDouble(),
      ),
      bgCard: _bgCard,
      bgChip: _bgChip,
      textCard: _textCard,
      textCardMuted: _textCardMuted,
      accentPrimary: _accent,
      accentSecondary: _accentAlt,
      onSave: (rating) => _service.savePartyRating(
        partyId: widget.partyId,
        itemNumber: item.number,
        story: rating.story,
        acting: rating.acting,
        action: rating.action,
        visuals: rating.visuals,
        sound: rating.sound,
      ),
    );
  }
}
