import 'package:chronowarp/data/marvel_data.dart';
import 'package:chronowarp/data/lionking_data.dart';
import 'package:chronowarp/data/pixar_data.dart';
import 'package:chronowarp/models/media_item.dart';
import 'package:flutter/material.dart';

// ── Palette ──────────────────────────────────────────────────────────────────
const _bgPage = Color.fromRGBO(26, 41, 49, 1);
const _bgCard = Color.fromRGBO(40, 58, 68, 1);
const _bgChip = Color.fromRGBO(50, 72, 85, 1);
const _accent = Color(0xFFD4622A);
const _accentAlt = Color(0xFFFF7A00);
const _textPri = Color(0xFFEEF1F4);
const _textMuted = Color(0xFF8AABB4);

/// A rated item with its universe label attached.
class _RankedEntry {
  final MediaItem item;
  final String universe;
  final double score;

  const _RankedEntry({
    required this.item,
    required this.universe,
    required this.score,
  });
}

/// All universes registered here — add new ones as you build them.
final _allUniverses = <String, List<MediaItem>>{
  'Marvel': mcuReleaseOrder,
  // 'Star Wars': starWarsItems,
  'Lion King': lionKingReleaseOrder,
  'Pixar': pixarOrder,
};

class OverallRankingsPage extends StatefulWidget {
  const OverallRankingsPage({super.key});

  @override
  State<OverallRankingsPage> createState() => _OverallRankingsPageState();
}

class _OverallRankingsPageState extends State<OverallRankingsPage>
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

  List<_RankedEntry> _rankedEntries(String category) {
    final entries = <_RankedEntry>[];

    for (final universe in _allUniverses.entries) {
      for (final item in universe.value) {
        if (item.categoryRating == null) continue;
        final cr = item.categoryRating!;
        double? score;
        switch (category) {
          case 'Overall':
            score = cr.average;
            break;
          case 'Story':
            score = cr.story;
            break;
          case 'Acting':
            score = cr.acting;
            break;
          case 'Action':
            score = cr.action;
            break;
          case 'Visuals':
            score = cr.visuals;
            break;
          case 'Sound':
            score = cr.sound;
            break;
        }
        if (score == null) continue;
        entries.add(
          _RankedEntry(item: item, universe: universe.key, score: score),
        );
      }
    }

    entries.sort((a, b) => b.score.compareTo(a.score));
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgPage,
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
                          'Overall Rankings',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: _textPri,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Your favourites, ranked across universes',
                          style: TextStyle(fontSize: 13, color: _textMuted),
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
                  color: _bgCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _accent.withValues(alpha: 0.3)),
                ),
                padding: const EdgeInsets.all(4),
                child: Scrollbar(
                  thumbVisibility: false,
                  interactive: true,
                  thickness: 2,

                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    dividerColor: Colors.transparent,
                    dividerHeight: 0,
                    indicatorPadding: const EdgeInsets.all(2),
                    automaticIndicatorColorAdjustment: false,
                    overlayColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.pressed) ||
                          states.contains(WidgetState.focused) ||
                          states.contains(WidgetState.hovered)) {
                        return _accent.withValues(alpha: 0.15);
                      }
                      return Colors.transparent;
                    }),
                    splashBorderRadius: BorderRadius.circular(12),

                    labelPadding: EdgeInsets.zero,

                    indicator: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF39A55), Color(0xFFFFB703)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),

                    indicatorSize: TabBarIndicatorSize.tab,

                    labelColor: _bgPage,
                    unselectedLabelColor: const Color(0xFFE3D7C6),

                    labelStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),

                    unselectedLabelStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),

                    tabs: _categories
                        .map(
                          (category) => Tab(
                            height: 48,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(category),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 26),

            // ── Ranked lists ──────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _categories.map((category) {
                  final ranked = _rankedEntries(category);
                  if (ranked.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_outline_rounded,
                            size: 48,
                            color: _textMuted,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No ratings yet',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: _textPri,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Rate some movies to see them here',
                            style: const TextStyle(
                              fontSize: 13,
                              color: _textMuted,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    itemCount: ranked.length,
                    itemBuilder: (context, index) {
                      return _buildRankCard(index + 1, ranked[index], category);
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

  Widget _buildRankCard(int rank, _RankedEntry entry, String category) {
    final isTop3 = rank <= 3;
    final medalColors = [
      const Color(0xFFFFD700),
      const Color(0xFFC0C0C0),
      const Color(0xFFCD7F32),
    ];
    final cr = entry.item.categoryRating!;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _bgCard,
        borderRadius: BorderRadius.circular(12),
        border: isTop3
            ? Border.all(
                color: medalColors[rank - 1].withOpacity(0.4),
                width: 1.5,
              )
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
                    color: isTop3 ? medalColors[rank - 1] : _bgChip,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$rank',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isTop3 ? Colors.black : _textMuted,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Title + universe
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.item.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: _textPri,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _accent.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              entry.universe,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: _accent,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${entry.item.year}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: _textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Score badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _accentAlt.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    entry.score.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _accentAlt,
                    ),
                  ),
                ),
              ],
            ),

            // Category breakdown on Overall tab
            if (category == 'Overall') ...[
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
                  style: const TextStyle(
                    fontSize: 11,
                    color: _textMuted,
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
                    backgroundColor: _bgChip,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _accentAlt.withOpacity(0.7),
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
                  style: const TextStyle(
                    fontSize: 11,
                    color: _textMuted,
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
