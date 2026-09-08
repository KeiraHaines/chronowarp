import '../pages/create_marathon_page.dart';
import 'marathon_image.dart';
import 'package:chronowarp/pages/ranking_page.dart';
import 'media_rating_sheet.dart';
import 'package:chronowarp/models/media_item.dart';
import 'dart:async';
import '../data/marathon_catalog.dart';
import '../models/marathon.dart';
import '../services/marathon_repository.dart';
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
  final ViewingOrder initialOrder;

  const UniverseWatchPage({
    super.key,
    required this.config,
    this.initialOrder = ViewingOrder.release,
  });

  @override
  State<UniverseWatchPage> createState() => _UniverseWatchPageState();
}

class _UniverseWatchPageState extends State<UniverseWatchPage> {
  bool _isReleaseOrder = true;
  late final MarathonRepository _repository;
  late MarathonDefinition _marathon;
  List<MediaItem> _displayItems = [];
  StreamSubscription? _subscription;
  StreamSubscription? _listSubscription;
  bool _listReady = false;
  String? _listError;
  final Map<String, CategoryRating?> _ratings = {};
  RunProgress _progress = RunProgress.fromJson({});
  bool _ready = false;
  String? _syncError;
  final Set<String> _pending = {};

  UniverseConfig get c => widget.config;

  Set<int> get _watched => {
    for (var index = 0; index < _activeItems.length; index++)
      if (_progress.isComplete(
        _marathon.entries[index],
        _marathon.media[_marathon.entries[index].mediaId]!,
      ))
        _activeItems[index].number,
  };

  MarathonEntry _entry(MediaItem item) =>
      _marathon.entries[_activeItems.indexOf(item)];

  void _applyMarathon(MarathonDefinition marathon) {
    _marathon = marathon;

    _displayItems = [
      for (final (index, entry) in marathon.entries.indexed)
        MediaItem(
          number: index + 1,
          title: marathon.media[entry.mediaId]!.title,
          year:
              marathon.media[entry.mediaId]!.releaseYear ??
              int.tryParse(
                marathon.media[entry.mediaId]!.releaseDate?.substring(0, 4) ??
                    '',
              ) ??
              0,
          type: marathon.media[entry.mediaId]!.kind == MediaKind.season
              ? MediaType.show
              : MediaType.movie,
          runtime: marathon.media[entry.mediaId]!.durationLabel,
          episodes: marathon.media[entry.mediaId]!.kind == MediaKind.season
              ? entry.units(marathon.media[entry.mediaId]!).length
              : null,
          posterPath: marathon.media[entry.mediaId]!.poster,
          blurb: marathon.media[entry.mediaId]!.blurb,
          categoryRating: _ratings[entry.mediaId],
        ),
    ];
  }

  void _listen() {
    _subscription?.cancel();
    _listSubscription?.cancel();
    _listReady = false;
    _listError = null;
    _applyMarathon(
      universeMarathon(
        c,
        _isReleaseOrder ? ViewingOrder.release : ViewingOrder.chronological,
      ),
    );
    _progress = RunProgress.fromJson({});
    _ready = false;
    _syncError = null;
    final runId = _marathon.id;
    _listSubscription = _repository
        .universeList(runId)
        .listen(
          (snapshot) {
            if (!mounted || _marathon.id != runId) return;
            try {
              final definition = snapshot.exists
                  ? MarathonDefinition.fromJson(runId, snapshot.data()!)
                  : universeMarathon(
                      c,
                      _isReleaseOrder
                          ? ViewingOrder.release
                          : ViewingOrder.chronological,
                    );
              setState(() {
                _applyMarathon(definition);
                _listReady = true;
                _listError = null;
              });
            } catch (_) {
              setState(() {
                _listReady = false;
                _listError = 'Your saved list could not be read.';
              });
            }
          },
          onError: (Object error) {
            if (!mounted || _marathon.id != runId) return;
            setState(() {
              _listReady = false;
              _listError =
                  'Your saved list could not be loaded. Check your connection and account access.';
            });
          },
        );
    _subscription = _repository
        .run(runId)
        .listen(
          (snapshot) {
            if (!mounted || _marathon.id != runId) return;
            setState(() {
              _progress = MarathonRepository.progress(snapshot);
              _ready = true;
              _syncError = null;
            });
          },
          onError: (Object error) {
            if (!mounted || _marathon.id != runId) return;
            setState(() {
              _ready = false;
              _syncError =
                  'Progress unavailable. Check your connection and account access.';
            });
          },
        );
  }

  Future<void> _mark(
    MarathonEntry entry,
    List<String> units,
    bool value,
  ) async {
    final runId = _marathon.id;
    final key = '$runId/${entry.id}';
    if (!_ready || !_listReady || _pending.contains(key)) return;
    setState(() => _pending.add(key));
    try {
      await _repository
          .setCompleted(runId, entry, units, value)
          .timeout(const Duration(seconds: 20));
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not confirm progress sync. Please try again.'),
          ),
        );
    } finally {
      if (mounted) setState(() => _pending.remove(key));
    }
  }

  List<MediaItem> get _activeItems => _displayItems;

  int get _movieCount => _marathon.entries
      .where((e) => _marathon.media[e.mediaId]!.kind == MediaKind.movie)
      .length;
  int get _gameCount => _marathon.entries
      .where((e) => _marathon.media[e.mediaId]!.kind == MediaKind.game)
      .length;
  int get _showCount => _activeItems.where((i) => i.isShow).length;
  int get _totalEpisodes => _marathon.entries.fold(
    0,
    (sum, entry) =>
        sum +
        (_marathon.media[entry.mediaId]!.kind == MediaKind.season
            ? entry.units(_marathon.media[entry.mediaId]!).length
            : 0),
  );

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
    _isReleaseOrder = widget.initialOrder != ViewingOrder.chronological;
    _repository = MarathonRepository.current();
    for (final item in c.releaseItems) {
      _ratings[mediaIdFor(universeIdFor(c.title), item)] = item.categoryRating;
    }
    _listen();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _listSubscription?.cancel();
    super.dispose();
  }

  Future<void> _editList() async {
    final result = await Navigator.push<MarathonDefinition>(
      context,
      MaterialPageRoute(
        builder: (_) => MarathonDraftPage(
          initialMarathon: _marathon,
          saveChanges: _repository.saveUniverseList,
        ),
      ),
    );
    if (result != null && mounted && result.id == _marathon.id) {
      setState(() => _applyMarathon(result));
    }
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
                        if (!_ready)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              _syncError ?? 'Loading account progress…',
                              style: TextStyle(color: c.textMuted),
                            ),
                          ),
                        _buildOrderToggle(),
                        if (!_listReady)
                          Text(
                            _listError ?? 'Loading your list…',
                            style: TextStyle(color: c.textMuted),
                          ),
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
                tooltip: 'Edit this order',
                onPressed: _listReady && _pending.isEmpty ? _editList : null,
                icon: Icon(Icons.edit_outlined, color: c.accentPrimary),
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
              const SizedBox(width: 6),
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
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        _statChip(Icons.movie_outlined, '$_movieCount movies'),
        const SizedBox(width: 8),
        _statChip(Icons.tv_outlined, '$_showCount shows'),
        const SizedBox(width: 8),
        _statChip(Icons.play_circle_outline, '$_totalEpisodes episodes'),
        if (_gameCount > 0)
          _statChip(Icons.sports_esports_outlined, '$_gameCount games'),
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
              setState(() {
                _isReleaseOrder = true;
                _listen();
              });
            }),
          ),
          Expanded(
            child: _toggleOption('Chronological Order', !_isReleaseOrder, () {
              setState(() {
                _isReleaseOrder = false;
                _listen();
              });
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
    if (_activeItems.isEmpty)
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'This order has not been added yet.',
          style: TextStyle(color: c.textPrimary),
        ),
      );
    final nextUp = _nextUp;
    return Column(
      children: _activeItems
          .map((item) => _buildItemCard(context, item, item == nextUp))
          .toList(),
    );
  }

  Widget _buildItemCard(BuildContext context, MediaItem item, bool isNextUp) {
    final isWatched = _watched.contains(item.number);
    final entry = _entry(item);
    final media = _marathon.media[entry.mediaId]!;
    final units = entry.units(media);
    final enabled =
        _ready &&
        _listReady &&
        !_pending.contains('${_marathon.id}/${entry.id}');

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
        onTap: enabled ? () => _mark(entry, units, !isWatched) : null,
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
                        _buildMediaMeta(media),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Rate button
                  GestureDetector(
                    onTap: () async {
                      await showMediaRatingSheet(
                        context: context,
                        title: item.title,
                        initialRating: item.categoryRating,
                        onSave: (rating) {
                          setState(() {
                            item.categoryRating = rating;
                            _ratings[media.id] = rating;
                            for (final original in c.releaseItems) {
                              if (mediaIdFor(
                                    universeIdFor(c.title),
                                    original,
                                  ) ==
                                  media.id)
                                original.categoryRating = rating;
                            }
                          });
                        },
                        bgCard: c.bgCard,
                        bgChip: c.bgChip,
                        accentPrimary: c.accentPrimary,
                        accentSecondary: c.accentSecondary,
                        textCard: c.textCard,
                        textCardMuted: c.textCardMuted,
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

            if (media.kind == MediaKind.season)
              Theme(
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  key: PageStorageKey('${_marathon.id}/${entry.id}'),
                  iconColor: c.accentPrimary,
                  collapsedIconColor: c.accentPrimary,
                  title: Text(
                    'Episodes · ${_progress.count(entry, media)} of ${units.length} watched',
                    style: TextStyle(fontSize: 12, color: c.textCardMuted),
                  ),
                  children: [
                    for (final unit in units)
                      CheckboxListTile(
                        dense: true,
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: c.accentPrimary,
                        title: Text(
                          media.episodes
                              .firstWhere((e) => e.id == unit)
                              .detailsLabel,
                          style: TextStyle(color: c.textCard, fontSize: 13),
                        ),
                        value:
                            _progress.completed[entry.id]?.contains(unit) ??
                            false,
                        onChanged: enabled
                            ? (value) => _mark(entry, [unit], value ?? false)
                            : null,
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
                        ? MarathonImage(
                            source: item.posterPath!,
                            fit: BoxFit.cover,
                          )
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

  Widget _buildMediaMeta(CatalogMedia media) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: '${media.dateLabel} · ${media.durationLabel}'),
          TextSpan(
            text:
                ' · Director: ${media.director?.trim().isNotEmpty == true ? media.director : 'Not added yet'}',
          ),
          if (media.kind == MediaKind.season)
            TextSpan(text: ' · ${media.episodes.length} episodes'),
        ],
      ),
      style: TextStyle(fontSize: 12, color: c.textCardMuted, height: 1.4),
    );
  }
}
