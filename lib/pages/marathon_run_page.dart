import 'create_marathon_page.dart';
import '../widgets/marathon_image.dart';
import 'package:flutter/material.dart';
import '../models/marathon.dart';
import '../services/marathon_repository.dart';
import '../widgets/universe_watch_page.dart';
import '../data/marathon_catalog.dart';
import 'rating_page.dart';
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
  Color get bg => widget.config?.bgPage ?? const Color(0xFF1A2931);
  Color get card => widget.config?.bgCard ?? const Color(0xFF283A44);
  Color get text => widget.config?.textPrimary ?? const Color(0xFFF2EADF);
  Color get cardText => widget.config?.textCard ?? const Color(0xFFF2EADF);
  Color get muted => widget.config?.textCardMuted ?? const Color(0xFF8AABB4);
  Color get accent => widget.config?.accentPrimary ?? const Color(0xFFE86D1F);
  Color get secondary =>
      widget.config?.accentSecondary ?? const Color(0xFFFFB703);

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
    final c = widget.config!;
    final legacy = c.releaseItems.firstWhere(
      (i) => mediaIdFor(media.universeId, i) == media.id,
    );
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RatingPage(
          item: legacy,
          onRated: (rating) => legacy.categoryRating = rating,
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
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) => widget.config != null
      ? UniverseWatchPage(config: widget.config!, initialOrder: _marathon.order)
      : Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
            backgroundColor: bg,
            foregroundColor: text,
            title: Text(_marathon.title),
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
              final orderLabel = switch (_marathon.order) {
                ViewingOrder.release => 'Release order',
                ViewingOrder.chronological => 'Chronological order',
                ViewingOrder.custom => 'Your custom order',
              };
              return ListView(
                padding: EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  24 + MediaQuery.paddingOf(context).bottom,
                ),
                children: [
                  Text(
                    orderLabel,
                    style: TextStyle(
                      color: text,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$done of ${entries.length} entries completed · ${snapshot.data!.metadata.hasPendingWrites
                        ? 'Syncing…'
                        : snapshot.data!.metadata.isFromCache
                        ? 'Offline cache'
                        : 'Synced to your account'}',
                    style: TextStyle(color: text),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: entries.isEmpty ? 0 : done / entries.length,
                    color: accent,
                    backgroundColor: card,
                  ),
                  const SizedBox(height: 20),
                  for (final (index, entry) in entries.indexed)
                    Builder(
                      builder: (context) {
                        final media = _marathon.media[entry.mediaId]!;
                        final complete = progress.isComplete(entry, media),
                            units = entry.units(media);
                        final count = progress.count(entry, media);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: card,
                            borderRadius: BorderRadius.circular(14),
                            border: entry == next
                                ? Border.all(color: secondary, width: 1.5)
                                : null,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Checkbox(
                                    value: complete,
                                    activeColor: accent,
                                    onChanged: _pending.contains(entry.id)
                                        ? null
                                        : (value) => _mark(
                                            entry,
                                            units,
                                            value ?? false,
                                          ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (entry == next)
                                          Text(
                                            'NEXT UP',
                                            style: TextStyle(
                                              color: secondary,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        Text(
                                          '${index + 1}. ${media.title}',
                                          style: TextStyle(
                                            color: cardText,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            decoration: complete
                                                ? TextDecoration.lineThrough
                                                : null,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          media.dateLabel,
                                          style: TextStyle(
                                            color: muted,
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          media.kind == MediaKind.season
                                              ? '${units.length} episodes${entry.episodeIds == null ? ' · Full season' : ' · Selected episodes'} · $count completed'
                                              : media.durationLabel,
                                          style: TextStyle(
                                            color: muted,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (media.kind == MediaKind.season)
                                Text(
                                  '${media.episodes.length} episodes in season · ${media.durationLabel}',
                                  style: TextStyle(color: muted, fontSize: 12),
                                ),
                              Text(
                                'Director: ${media.director?.isNotEmpty == true ? media.director : 'Not added'}',
                                style: TextStyle(color: muted, fontSize: 12),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                media.blurb?.isNotEmpty == true
                                    ? media.blurb!
                                    : 'Blurb not added yet.',
                                style: TextStyle(color: cardText, height: 1.45),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: [
                                  if (media.kind == MediaKind.season)
                                    TextButton.icon(
                                      onPressed: () => _episodes(entry, media),
                                      icon: const Icon(Icons.playlist_play),
                                      label: const Text('Episodes'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: cardText,
                                      ),
                                    ),
                                  if (widget.config != null)
                                    TextButton.icon(
                                      onPressed: () => _rate(media),
                                      icon: const Icon(Icons.star_outline),
                                      label: const Text('Rate'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: cardText,
                                      ),
                                    ),
                                ],
                              ),
                              if (entry == next &&
                                  media.poster?.isNotEmpty == true)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: SizedBox(
                                    height: 240,
                                    width: double.infinity,
                                    child: MarathonImage(
                                      source: media.poster!,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                            ],
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
