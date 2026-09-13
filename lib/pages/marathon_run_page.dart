import '../widgets/tap_sound_feedback.dart';
import '../services/rating_store.dart';
import 'dart:async';
import '../services/completion_sound.dart';
import '../widgets/media_poster.dart';
import 'create_marathon_page.dart';
import 'package:flutter/material.dart';
import '../widgets/marathon_colours.dart';
import '../models/marathon.dart';
import '../services/marathon_repository.dart';
import '../widgets/universe_watch_page.dart';
import '../data/marathon_catalog.dart';
import '../widgets/media_rating_sheet.dart';
import 'ranking_page.dart';

class MarathonRunPage extends StatefulWidget {
  final MarathonDefinition marathon;
  final UniverseConfig? config;
  const MarathonRunPage({super.key, required this.marathon, this.config});
  @override
  State<MarathonRunPage> createState() => _MarathonRunPageState();
}

class _MarathonRunPageState extends State<MarathonRunPage> {
  late MarathonDefinition _marathon = widget.marathon;
  late final _repository = MarathonRepository.current();
  late final _run = _repository.run(_marathon.id);
  final _pending = <String>{};
  bool _deleting = false;
  MarathonColours get palette => MarathonColours.forId(_marathon.colourTheme);
  Color get bg => widget.config?.bgPage ?? palette.background;
  Color get card => widget.config?.bgCard ?? palette.card;
  Color get text => widget.config?.textPrimary ?? const Color(0xFFF2EADF);
  Color get cardText => widget.config?.textCard ?? const Color(0xFFF2EADF);
  Color get muted => widget.config?.textCardMuted ?? const Color(0xFF8AABB4);
  Color get accent => widget.config?.accentPrimary ?? palette.accent;
  Color get secondary => widget.config?.accentSecondary ?? palette.secondary;

  Widget _mediaCountChip(MediaKind kind) {
    final count = _marathon.entries
        .where((e) => _marathon.media[e.mediaId]?.kind == kind)
        .length;
    final (icon, noun) = switch (kind) {
      MediaKind.movie => (Icons.movie_outlined, 'movie'),
      MediaKind.season => (Icons.tv_outlined, 'show'),
      MediaKind.game => (Icons.sports_esports_outlined, 'game'),
    };
    final foreground = card.computeLuminance() > 0.179
        ? Colors.black
        : Colors.white;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: foreground),
          const SizedBox(width: 5),
          Text(
            '$count $noun${count == 1 ? '' : 's'}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _mark(
    MarathonEntry entry,
    List<String> units,
    bool value,
  ) async {
    if (_deleting || _pending.contains(entry.id)) return;
    setState(() => _pending.add(entry.id));
    try {
      await _repository
          .setCompleted(_marathon.id, entry, units, value)
          .timeout(const Duration(seconds: 20));
      if (mounted &&
          value &&
          _marathon.media[entry.mediaId]?.kind == MediaKind.movie) {
        unawaited(CompletionSound.play());
      }
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not confirm cloud sync. Check your connection and try again.',
            ),
          ),
        );
    } finally {
      if (mounted) setState(() => _pending.remove(entry.id));
    }
  }

  Future<void> _editMarathon() async {
    final result = await Navigator.push<MarathonDefinition>(
      context,
      MaterialPageRoute(
        builder: (_) => MarathonDraftPage(initialMarathon: _marathon),
      ),
    );
    if (result != null && mounted) setState(() => _marathon = result);
  }

  Future<void> _deleteMarathon() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: card,
        title: Text('Delete marathon?', style: TextStyle(color: cardText)),
        content: Text(
          'Delete “${_marathon.title}” and its watched progress from your account? This cannot be undone.',
          style: TextStyle(color: cardText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFB84232),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _deleting = true);
    try {
      await _repository.delete(_marathon);
      if (!mounted) return;
      if (ModalRoute.of(context)?.isCurrent == true) Navigator.pop(context);
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not delete the marathon. Check your connection and try again.',
            ),
          ),
        );
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  Future<void> _episodes(MarathonEntry entry, CatalogMedia media) async {
    final units = entry.units(media);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: card,
      builder: (context) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.72,
          child: StreamBuilder(
            stream: _run,
            builder: (context, snapshot) {
              final progress = MarathonRepository.progress(snapshot.data);
              if (snapshot.hasError)
                return Center(
                  child: Text(
                    'Unable to load progress',
                    style: TextStyle(color: cardText),
                  ),
                );
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      media.title,
                      style: TextStyle(
                        color: cardText,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: [
                        for (final episode in media.episodes.where(
                          (e) => units.contains(e.id),
                        ))
                          CheckboxListTile(
                            value:
                                progress.completed[entry.id]?.contains(
                                  episode.id,
                                ) ??
                                false,
                            activeColor: accent,
                            title: Text(
                              episode.detailsLabel,
                              style: TextStyle(color: cardText),
                            ),
                            subtitle: episode.releaseDate == null
                                ? null
                                : Text(
                                    episode.releaseDate!,
                                    style: TextStyle(color: muted),
                                  ),
                            onChanged: snapshot.hasData
                                ? (value) =>
                                      _mark(entry, [episode.id], value ?? false)
                                : null,
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _rankings() {
    final c = widget.config!;
    Navigator.push(
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
    );
  }

  Future<void> _rate(CatalogMedia media) async {
    await showMediaRatingSheet(
      context: context,
      title: media.title,
      initialRating: RatingStore.read(media.id),
      onSave: (rating) async {
        await RatingStore.save(media.id, rating);
        if (mounted) setState(() {});
      },
      bgCard: card,
      bgChip: bg,
      textCard: cardText,
      textCardMuted: muted,
      accentPrimary: accent,
      accentSecondary: secondary,
    );
  }

  Widget _ratingButton(CatalogMedia media) {
    final rating = RatingStore.read(media.id)?.average;
    final background = rating == null ? bg : accent;
    return RateSound(
      child: GestureDetector(
        onTap: () => _rate(media),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            rating == null ? 'Rate' : '${rating.toStringAsFixed(1)}/10',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: background.computeLuminance() > 0.179
                  ? Colors.black
                  : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => widget.config != null
      ? UniverseWatchPage(config: widget.config!, initialOrder: _marathon.order)
      : Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
            backgroundColor: bg,
            foregroundColor: text,
            centerTitle: true,
            title: Text(
              _marathon.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: text,
                letterSpacing: -0.5,
              ),
            ),
            actions: [
              if (_marathon.order == ViewingOrder.custom)
                IconButton(
                  tooltip: 'Edit marathon',
                  onPressed: _deleting || _pending.isNotEmpty
                      ? null
                      : _editMarathon,
                  icon: const Icon(Icons.edit_outlined),
                ),
              if (_marathon.order == ViewingOrder.custom)
                IconButton(
                  tooltip: 'Delete marathon',
                  onPressed: _deleting || _pending.isNotEmpty
                      ? null
                      : _deleteMarathon,
                  icon: _deleting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.delete_outline),
                ),
              if (widget.config != null)
                IconButton(
                  onPressed: _rankings,
                  tooltip: 'Rankings',
                  icon: const Icon(Icons.leaderboard_outlined),
                ),
            ],
          ),
          body: StreamBuilder(
            stream: _run,
            builder: (context, snapshot) {
              if (snapshot.hasError)
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Your progress could not be loaded. Check your connection and account access.',
                      style: TextStyle(color: text),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              if (!snapshot.hasData)
                return Center(child: CircularProgressIndicator(color: accent));
              final progress = MarathonRepository.progress(snapshot.data);
              final entries = _marathon.entries;
              final done = entries
                  .where(
                    (e) => progress.isComplete(e, _marathon.media[e.mediaId]!),
                  )
                  .length;
              final next = entries
                  .where(
                    (e) => !progress.isComplete(e, _marathon.media[e.mediaId]!),
                  )
                  .firstOrNull;
              return ListView(
                padding: EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  24 + MediaQuery.paddingOf(context).bottom,
                ),
                children: [
                  Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (final kind in MediaKind.values) ...[
                            if (kind != MediaKind.movie)
                              const SizedBox(width: 6),
                            _mediaCountChip(kind),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$done of ${entries.length} watched',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: muted,
                        ),
                      ),
                      Text(
                        '${entries.isEmpty ? 0 : (done / entries.length * 100).round()}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: secondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: entries.isEmpty ? 0 : done / entries.length,
                      minHeight: 6,
                      valueColor: AlwaysStoppedAnimation<Color>(secondary),
                      backgroundColor: card,
                    ),
                  ),
                  if (snapshot.data!.metadata.hasPendingWrites ||
                      snapshot.data!.metadata.isFromCache)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        snapshot.data!.metadata.hasPendingWrites
                            ? 'Syncing…'
                            : 'Offline cache',
                        style: TextStyle(fontSize: 12, color: muted),
                      ),
                    ),
                  const SizedBox(height: 18),
                  for (final (index, entry) in entries.indexed)
                    Builder(
                      builder: (context) {
                        final media = _marathon.media[entry.mediaId]!;
                        final complete = progress.isComplete(entry, media),
                            units = entry.units(media);
                        final count = progress.count(entry, media);
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: card,
                            borderRadius: BorderRadius.circular(12),
                            border: entry == next
                                ? Border.all(color: secondary, width: 1.5)
                                : null,
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: _pending.contains(entry.id)
                                ? null
                                : () => _mark(entry, units, !complete),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    children: [
                                      Semantics(
                                        label: complete
                                            ? 'Mark ${media.title} unwatched'
                                            : 'Mark ${media.title} watched',
                                        button: true,
                                        child: Container(
                                          width: 30,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: complete
                                                ? accent
                                                : secondary,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: complete
                                                ? const Icon(
                                                    Icons.check,
                                                    size: 14,
                                                    color: Colors.black,
                                                  )
                                                : Text(
                                                    '${index + 1}',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              media.title,
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: complete
                                                    ? muted
                                                    : cardText,
                                                decoration: complete
                                                    ? TextDecoration.lineThrough
                                                    : null,
                                              ),
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              '${media.dateLabel} · ${media.durationLabel} · ${media.kind == MediaKind.game ? 'Developer: ${media.developer ?? 'Not added yet'}' : 'Director: ${media.director?.isNotEmpty == true ? media.director : 'Not added yet'}'}${media.kind == MediaKind.season ? ' · ${units.length} episodes' : ''}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: muted,
                                                height: 1.4,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      _ratingButton(media),
                                    ],
                                  ),
                                ),
                                if (entry.note?.isNotEmpty == true)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 6,
                                    ),
                                    child: Text(
                                      entry.note!,
                                      style: TextStyle(
                                        color: muted,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                if (media.kind == MediaKind.season)
                                  Theme(
                                    data: Theme.of(context).copyWith(
                                      dividerColor: Colors.transparent,
                                    ),
                                    child: ExpansionTile(
                                      key: PageStorageKey(
                                        '${_marathon.id}/${entry.id}',
                                      ),
                                      title: Text(
                                        '$count / ${units.length} episodes watched',
                                        style: TextStyle(
                                          color: cardText,
                                          fontSize: 13,
                                        ),
                                      ),
                                      iconColor: secondary,
                                      collapsedIconColor: secondary,
                                      children: [
                                        for (final unit in units)
                                          CheckboxListTile(
                                            dense: true,
                                            activeColor: accent,
                                            title: Text(
                                              media.episodes
                                                  .firstWhere(
                                                    (e) => e.id == unit,
                                                  )
                                                  .detailsLabel,
                                              style: TextStyle(
                                                color: cardText,
                                                fontSize: 13,
                                              ),
                                            ),
                                            value:
                                                progress.completed[entry.id]
                                                    ?.contains(unit) ??
                                                false,
                                            onChanged:
                                                _pending.contains(entry.id)
                                                ? null
                                                : (value) => _mark(entry, [
                                                    unit,
                                                  ], value ?? false),
                                          ),
                                      ],
                                    ),
                                  ),
                                if (entry == next) MediaPoster(media: media),
                                if (entry == next &&
                                    media.blurb?.isNotEmpty == true)
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      14,
                                      10,
                                      14,
                                      12,
                                    ),
                                    child: Text(
                                      media.blurb!,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: muted,
                                        height: 1.5,
                                      ),
                                    ),
                                  )
                                else if (entry == next)
                                  const SizedBox(height: 12),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              );
            },
          ),
        );
}
