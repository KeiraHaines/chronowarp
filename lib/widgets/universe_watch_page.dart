import 'package:chronowarp/pages/ranking_page.dart';
import 'package:chronowarp/pages/rating_page.dart';
import 'package:chronowarp/models/media_item.dart';
import 'package:chronowarp/stores/progress_store.dart';
import 'package:flutter/material.dart';

class UniverseConfig {
  final String title;
  final List<MediaItem> releaseItems;
  final List<MediaItem> chronologicalItems;
  final Color bgPage;
  final Color bgCard;
  final Color bgChip;
  final Color accentPrimary;
  final Color accentSecondary;
  final Color textPrimary;
  final Color textMuted;
  final Color textCard;
  final Color textCardMuted;

  const UniverseConfig({
    required this.title,
    required this.releaseItems,
    required this.chronologicalItems,
    required this.bgPage,
    required this.bgCard,
    required this.bgChip,
    required this.accentPrimary,
    required this.accentSecondary,
    required this.textPrimary,
    required this.textMuted,
    required this.textCard,
    required this.textCardMuted,
  });

  String get key => title;
}

class UniverseWatchPage extends StatefulWidget {
  final UniverseConfig config;

  const UniverseWatchPage({super.key, required this.config});

  @override
  State<UniverseWatchPage> createState() => _UniverseWatchPageState();
}

class _UniverseWatchPageState extends State<UniverseWatchPage> {
  bool _isReleaseOrder = true;
  final _store = ProgressStore.instance;

  UniverseConfig get c => widget.config;

  Set<int> get _watched => _store.watchedFor(c.key);

  List<MediaItem> get _activeItems =>
      _isReleaseOrder ? c.releaseItems : c.chronologicalItems;

  int get _movieCount => _activeItems.where((i) => !i.isShow).length;
  int get _showCount => _activeItems.where((i) => i.isShow).length;
  int get _totalEpisodes =>
      _activeItems.fold(0, (sum, i) => sum + (i.episodes ?? 0));

  MediaItem? get _nextUp {
    try {
      return _activeItems.firstWhere((i) => !_watched.contains(i.number));
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _store.addListener(_onStoreChanged);
  }

  @override
  void dispose() {
    _store.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: c.bgPage,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ScrollbarTheme(
                data: ScrollbarThemeData(
                  thumbColor: WidgetStateProperty.all(c.accentSecondary),
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
                        _buildHeader(context),
                        const SizedBox(height: 16),
                        _buildStatRow(),
                        const SizedBox(height: 16),
                        _buildProgressBar(),
                        _buildOrderToggle(),
                        const SizedBox(height: 16),
                        _buildItemList(context),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            c.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: c.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back, color: c.accentPrimary),
                style: IconButton.styleFrom(
                  backgroundColor: c.bgCard,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(36, 36),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RankingsPage(
                      universeTitle: c.title,
                      items: c.releaseItems,
                      bgPage: c.bgPage,
                      bgCard: c.bgCard,
                      bgChip: c.bgChip,
                      accentPrimary: c.accentPrimary,
                      accentSecondary: c.accentSecondary,
                      textPrimary: c.textPrimary,
                      textMuted: c.textMuted,
                      textCard: c.textCard,
                      textCardMuted: c.textCardMuted,
                    ),
                  ),
                ),
                icon: Icon(Icons.leaderboard_outlined, color: c.accentPrimary),
                style: IconButton.styleFrom(
                  backgroundColor: c.bgCard,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(36, 36),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _statChip(Icons.movie_outlined, '$_movieCount movies'),
        const SizedBox(width: 8),
        _statChip(Icons.tv_outlined, '$_showCount shows'),
        const SizedBox(width: 8),
        _statChip(Icons.play_circle_outline, '$_totalEpisodes episodes'),
      ],
    );
  }

  Widget _statChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c.bgChip,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: c.textMuted),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: c.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final watchedCount = _watched.length;
    final total = _activeItems.length;
    final progress = total > 0 ? watchedCount / total : 0.0;
    final percent = (progress * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$watchedCount of $total watched',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: c.textMuted,
              ),
            ),
            Text(
              '$percent%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: c.accentSecondary,
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
            backgroundColor: c.bgChip,
            valueColor: AlwaysStoppedAnimation<Color>(c.accentSecondary),
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget _buildOrderToggle() {
    return Container(
      decoration: BoxDecoration(
        color: c.bgCard,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: [
          Expanded(
            child: _toggleOption('Release Order', _isReleaseOrder, () {
              setState(() => _isReleaseOrder = true);
            }),
          ),
          Expanded(
            child: _toggleOption('Chronological Order', !_isReleaseOrder, () {
              setState(() => _isReleaseOrder = false);
            }),
          ),
        ],
      ),
    );
  }

  Widget _toggleOption(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? c.bgChip : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? c.textPrimary : c.textCardMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildItemList(BuildContext context) {
    final nextUp = _nextUp;
    return Column(
      children: _activeItems
          .map((item) => _buildItemCard(context, item, item == nextUp))
          .toList(),
    );
  }

  Widget _buildItemCard(BuildContext context, MediaItem item, bool isNextUp) {
    final isWatched = _watched.contains(item.number);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: c.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: isNextUp
            ? Border.all(color: c.accentSecondary, width: 1.5)
            : null,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _store.toggle(c.key, item.number);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Standard card row ──────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  // Number badge
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: isWatched ? c.accentPrimary : c.accentSecondary,
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
                  // Item info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isWatched ? c.textCardMuted : c.textCard,
                            decoration: isWatched
                                ? TextDecoration.lineThrough
                                : null,
                            decorationColor: c.textCardMuted,
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
                  // Rate button
                  GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RatingPage(
                            item: item,
                            onRated: (rating) {
                              setState(() => item.categoryRating = rating);
                            },
                            bgPage: c.bgPage,
                            bgCard: c.bgCard,
                            bgChip: c.bgChip,
                            accentPrimary: c.accentPrimary,
                            accentSecondary: c.accentSecondary,
                            textPrimary: c.textPrimary,
                            textMuted: c.textMuted,
                            textCard: c.textCard,
                            textCardMuted: c.textCardMuted,
                          ),
                        ),
                      );
                    },
                    child: item.rating != null
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: c.accentPrimary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${item.rating!.toStringAsFixed(1)}/10',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: c.bgChip,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Rate',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: c.textMuted,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),

            // ── Poster (next up only) — standard 2:3 movie poster ratio ───
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
                            color: c.bgChip,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_outlined,
                                  size: 48,
                                  color: c.textMuted,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Poster coming soon',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: c.textMuted,
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
                    color: c.textCardMuted,
                    height: 1.5,
                  ),
                ),
              )
            else if (isNextUp)
              const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildMovieMeta(MediaItem item) {
    return Row(
      children: [
        Icon(Icons.calendar_today_outlined, size: 12, color: c.textCardMuted),
        const SizedBox(width: 4),
        Text(
          '${item.year}',
          style: TextStyle(fontSize: 12, color: c.textCardMuted),
        ),
        if (item.runtime != null) ...[
          const SizedBox(width: 8),
          Icon(Icons.access_time_outlined, size: 12, color: c.textCardMuted),
          const SizedBox(width: 4),
          Text(
            item.runtime!,
            style: TextStyle(fontSize: 12, color: c.textCardMuted),
          ),
        ],
      ],
    );
  }

  Widget _buildShowMeta(MediaItem item) {
    return Row(
      children: [
        Icon(Icons.calendar_today_outlined, size: 12, color: c.textCardMuted),
        const SizedBox(width: 4),
        Text(
          '${item.year}',
          style: TextStyle(fontSize: 12, color: c.textCardMuted),
        ),
        const SizedBox(width: 8),
        Icon(Icons.layers_outlined, size: 13, color: c.textCardMuted),
        const SizedBox(width: 4),
        Text(
          '${item.seasons} season${(item.seasons ?? 0) > 1 ? 's' : ''}',
          style: TextStyle(fontSize: 12, color: c.textCardMuted),
        ),
        const SizedBox(width: 8),
        Icon(Icons.play_circle_outline, size: 13, color: c.textCardMuted),
        const SizedBox(width: 4),
        Text(
          '${item.episodes} episodes',
          style: TextStyle(fontSize: 12, color: c.textCardMuted),
        ),
      ],
    );
  }
}
