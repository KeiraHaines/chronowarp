import 'package:chronowarp/models/media_item.dart';
import 'package:flutter/material.dart';

class RankingsPage extends StatefulWidget {
  final String universeTitle;
  final List<MediaItem> items;
  final Color bgPage;
  final Color bgCard;
  final Color bgChip;
  final Color accentPrimary;
  final Color accentSecondary;
  final Color textPrimary;
  final Color textMuted;
  final Color textCard;
  final Color textCardMuted;

  const RankingsPage({
    super.key,
    required this.universeTitle,
    required this.items,
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

  @override
  State<RankingsPage> createState() => _RankingsPageState();
}

class _RankingsPageState extends State<RankingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _categories = [
    'Overall',
    'Story',
    'Acting',
    'Action',
    'Visuals',
    'Sound',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Cache ranked results per category so re-renders (e.g. switching tabs,
  // parent rebuilds) don't re-filter/re-sort the full item list every time.
  final Map<String, List<MapEntry<MediaItem, double>>> _rankedCache = {};

  double? _scoreFor(MediaItem item, String category) {
    final cr = item.categoryRating;
    switch (category) {
      case 'Overall':
        return cr?.average;
      case 'Story':
        return cr?.story;
      case 'Acting':
        return cr?.acting;
      case 'Action':
        return cr?.action;
      case 'Visuals':
        return cr?.visuals;
      case 'Sound':
        return cr?.sound;
    }
    return null;
  }

  List<MapEntry<MediaItem, double>> _rankedItems(String category) {
    final cached = _rankedCache[category];
    if (cached != null) return cached;

    final rated = <MapEntry<MediaItem, double>>[];
    for (final item in widget.items) {
      final score = _scoreFor(item, category);
      if (score != null) rated.add(MapEntry(item, score));
    }
    rated.sort((a, b) => b.value.compareTo(a.value));

    _rankedCache[category] = rated;
    return rated;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.bgPage,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back, color: widget.accentPrimary),
                    style: IconButton.styleFrom(
                      backgroundColor: widget.bgCard,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(36, 36),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rankings',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: widget.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          widget.universeTitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: widget.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Category tabs ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: widget.bgCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: widget.accentPrimary.withValues(alpha: 0.3),
                  ),
                ),
                padding: const EdgeInsets.all(4),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  dividerColor: Colors.transparent,
                  dividerHeight: 0,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorPadding: const EdgeInsets.all(2),
                  labelPadding: EdgeInsets.zero,
                  automaticIndicatorColorAdjustment: false,
                  overlayColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.pressed) ||
                        states.contains(WidgetState.focused) ||
                        states.contains(WidgetState.hovered)) {
                      return widget.accentPrimary.withValues(alpha: 0.15);
                    }
                    return Colors.transparent;
                  }),
                  splashBorderRadius: BorderRadius.circular(12),
                  indicator: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.accentPrimary,
                        Color.lerp(widget.accentPrimary, Colors.white, 0.35)!,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelColor: Colors.black,
                  unselectedLabelColor: widget.textCard,
                  labelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: _categories
                      .map((c) => Tab(
                        height: 48,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(c),
                        ),
                      ))
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Ranked lists ──────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _categories.map((category) {
                  final ranked = _rankedItems(category);
                  if (ranked.isEmpty) {
                    return Center(
                      child: Text(
                        'No ratings yet',
                        style: TextStyle(fontSize: 14, color: widget.textMuted),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    itemCount: ranked.length,
                    itemBuilder: (context, index) {
                      final entry = ranked[index];
                      final item = entry.key;
                      final score = entry.value;
                      final cr = item.categoryRating!;
                      return _buildRankCard(
                        index + 1,
                        item,
                        score,
                        cr,
                        category,
                      );
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankCard(
    int rank,
    MediaItem item,
    double score,
    CategoryRating cr,
    String activeCategory,
  ) {
    final isTop3 = rank <= 3;
    final medalColors = [
      const Color(0xFFFFD700), // gold
      const Color(0xFFC0C0C0), // silver
      const Color(0xFFCD7F32), // bronze
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: widget.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: isTop3
            ? Border.all(color: medalColors[rank - 1], width: 1.5)
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Rank badge
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: isTop3 ? medalColors[rank - 1] : widget.bgChip,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$rank',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isTop3 ? Colors.black : widget.textMuted,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Title
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: widget.textCard,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${item.year}',
                        style: TextStyle(
                          fontSize: 12,
                          color: widget.textCardMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                // Score
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: widget.accentSecondary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    score.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: widget.accentSecondary,
                    ),
                  ),
                ),
              ],
            ),
            // Category breakdown (only on Overall tab)
            if (activeCategory == 'Overall' && cr.average != null) ...[
              const SizedBox(height: 10),
              _buildCategoryBreakdown(cr),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdown(CategoryRating cr) {
    final categories = {
      'Story': cr.story,
      'Acting': cr.acting,
      'Action': cr.action,
      'Visuals': cr.visuals,
      'Sound': cr.sound,
    };

    return Column(
      children: categories.entries.map((entry) {
        final value = entry.value;
        final progress = value != null ? value / 10 : 0.0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              SizedBox(
                width: 52,
                child: Text(
                  entry.key,
                  style: TextStyle(
                    fontSize: 11,
                    color: widget.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    backgroundColor: widget.bgChip,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      widget.accentSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 24,
                child: Text(
                  value != null ? value.toInt().toString() : '—',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 11,
                    color: widget.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
