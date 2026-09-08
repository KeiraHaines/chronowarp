import 'package:flutter/material.dart';
import '../models/marathon.dart';
import '../services/marathon_repository.dart';
import 'custom_media_page.dart';
import '../data/marathon_catalog.dart';
import '../widgets/marathon_photo_field.dart';
import 'marathon_media_picker_page.dart';

class CreateMarathonPage extends StatelessWidget {
  final Map<String, CatalogMedia> library;
  const CreateMarathonPage({super.key, this.library = const {}});
  @override
  Widget build(BuildContext context) => MarathonDraftPage(library: library);
}

class MarathonDraftPage extends StatefulWidget {
  final Map<String, CatalogMedia> library;
  final MarathonDefinition? initialMarathon;
  final Future<void> Function(MarathonDefinition)? saveChanges;
  const MarathonDraftPage({
    super.key,
    this.library = const {},
    this.initialMarathon,
    this.saveChanges,
  });
  @override
  State<MarathonDraftPage> createState() => _MarathonDraftPageState();
}

class _MarathonDraftPageState extends State<MarathonDraftPage> {
  final _title = TextEditingController();
  late final _repository = MarathonRepository.current();
  late final _id = widget.initialMarathon?.id ?? _repository.newId();
  final _entries = <MarathonEntry>[];
  final _media = <String, CatalogMedia>{};
  bool _saving = false;
  bool _loadingLibrary = false;
  bool _addingEntries = false;
  bool _photoReady = true;
  final _setupForm = GlobalKey<FormState>();
  String? _error;
  bool get _editing => widget.initialMarathon != null;
  @override
  void initState() {
    super.initState();
    final initial = widget.initialMarathon;
    if (initial != null) {
      _title.text = initial.title;
      _entries.addAll(initial.entries);
      _media.addAll(initial.media);
      _addingEntries = true;
    }
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<List<String>?> _chooseEpisodes(CatalogMedia media) async {
    final selected = media.episodes.map((e) => e.id).toSet();
    return showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, update) => SafeArea(
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.75,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Text(
                    'Choose episodes: ${media.title}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => update(
                        () => selected.addAll(media.episodes.map((e) => e.id)),
                      ),
                      child: const Text('Select all'),
                    ),
                    TextButton(
                      onPressed: () => update(selected.clear),
                      child: const Text('Clear'),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView(
                    children: [
                      for (final ep in media.episodes)
                        CheckboxListTile(
                          title: Text(ep.detailsLabel),
                          value: selected.contains(ep.id),
                          onChanged: (value) => update(() {
                            if (value == true) {
                              selected.add(ep.id);
                            } else {
                              selected.remove(ep.id);
                            }
                          }),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: FilledButton(
                    onPressed: selected.isEmpty
                        ? null
                        : () => Navigator.pop(
                            context,
                            media.episodes
                                .where((e) => selected.contains(e.id))
                                .map((e) => e.id)
                                .toList(),
                          ),
                    child: Text('Add ${selected.length} episodes'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _add(CatalogMedia media) async {
    if (_entries.length >= 100) {
      setState(() => _error = 'A marathon can contain up to 100 entries.');
      return;
    }
    List<String>? episodes;
    if (media.kind == MediaKind.season) {
      episodes = await _chooseEpisodes(media);
      if (episodes == null || !mounted) return;
      if (episodes.length == media.episodes.length) episodes = null;
    }
    if (!mounted) return;
    setState(() {
      _media[media.id] = media;
      _entries.add(
        MarathonEntry(
          id: _repository.newId(),
          mediaId: media.id,
          episodeIds: episodes,
        ),
      );
    });
  }

  Future<void> _newMedia() async {
    final media = await Navigator.push<CatalogMedia>(
      context,
      MaterialPageRoute(builder: (_) => const CustomMediaPage()),
    );
    if (media != null && mounted) await _add(media);
  }

  Future<void> _reuse() async {
    if (_loadingLibrary) return;
    setState(() => _loadingLibrary = true);
    Map<String, CatalogMedia> saved = {};
    try {
      saved = await _repository.mediaLibrary().timeout(
        const Duration(seconds: 10),
      );
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Saved media is unavailable. You can still search the built-in catalogue.',
            ),
          ),
        );
    }
    if (!mounted) return;
    setState(() => _loadingLibrary = false);
    final library = {
      for (final config in availableUniverses) ...catalogFor(config),
      ...widget.library,
      ...saved,
      ..._media,
    };
    final result = await Navigator.push<CatalogMedia>(
      context,
      MaterialPageRoute(
        builder: (_) => MarathonMediaPickerPage(library: library),
      ),
    );
    if (result != null && mounted) await _add(result);
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty || _entries.isEmpty) {
      setState(() => _error = 'Name your marathon and add at least one entry.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final marathon = MarathonDefinition(
      id: _id,
      title: _title.text.trim(),
      order: widget.initialMarathon?.order ?? ViewingOrder.custom,
      universeId: widget.initialMarathon?.universeId,
      entries: _entries,
      media: {
        for (final id in _entries.map((e) => e.mediaId).toSet())
          id: _media[id]!,
      },
    );
    try {
      await (widget.saveChanges?.call(marathon) ?? _repository.save(marathon))
          .timeout(const Duration(seconds: 20));
      if (mounted) {
        setState(() {
          _addingEntries = false;
          _saving = false;
        });
        Navigator.pop(context, marathon);
      }
    } catch (_) {
      if (mounted)
        setState(
          () => _error =
              'Could not confirm cloud save. Check your connection and try again; your draft is still here.',
        );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _subtitle(MarathonEntry e) {
    final m = _media[e.mediaId]!;
    if (m.kind != MediaKind.season)
      return m.kind == MediaKind.game
          ? 'Video game · ${m.durationLabel}'
          : 'Movie · ${m.durationLabel}';
    return e.episodeIds == null
        ? 'Full season · ${m.episodes.length} episodes'
        : 'Episodes ${m.episodes.where((ep) => e.episodeIds!.contains(ep.id)).map((ep) => ep.number).join(', ')}';
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: (_editing || !_addingEntries) && !_saving,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop && !_saving && !_editing)
        setState(() => _addingEntries = false);
    },
    child: Scaffold(
      backgroundColor: const Color(0xFF1A2931),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A2931),
        foregroundColor: Colors.white,
        title: Text(
          _editing
              ? 'Edit order and entries'
              : _addingEntries
              ? 'Add entries'
              : 'Create marathon',
        ),
        leading: BackButton(
          onPressed: _saving
              ? null
              : () {
                  if (_addingEntries && !_editing) {
                    setState(() => _addingEntries = false);
                  } else {
                    Navigator.pop(context);
                  }
                },
        ),
      ),
      body: IndexedStack(
        index: _addingEntries ? 1 : 0,
        children: [
          _editing ? const SizedBox.shrink() : _buildSetup(),
          !_addingEntries
              ? const SizedBox.shrink()
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _title.text.trim(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (!_editing)
                                IconButton(
                                  tooltip: 'Edit name and cover',
                                  onPressed: _saving
                                      ? null
                                      : () => setState(
                                          () => _addingEntries = false,
                                        ),
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    color: Colors.white70,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            children: [
                              FilledButton.icon(
                                onPressed: _saving ? null : _newMedia,
                                icon: const Icon(Icons.add),
                                label: const Text('Add new entry'),
                              ),
                              OutlinedButton(
                                onPressed: _saving || _loadingLibrary
                                    ? null
                                    : _reuse,
                                child: const Text('Add existing item'),
                              ),
                            ],
                          ),
                          const Text(
                            'Drag entries to set the order. Add a season again to place another group of episodes later.',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ReorderableListView.builder(
                        buildDefaultDragHandles: false,
                        itemCount: _entries.length,
                        onReorder: (oldIndex, newIndex) {
                          if (_saving) return;
                          setState(() {
                            if (newIndex > oldIndex) newIndex--;
                            _entries.insert(
                              newIndex,
                              _entries.removeAt(oldIndex),
                            );
                          });
                        },
                        itemBuilder: (context, i) {
                          final e = _entries[i];
                          return Card(
                            key: ValueKey(e.id),
                            color: const Color(0xFF283A44),
                            child: ListTile(
                              leading: ReorderableDragStartListener(
                                index: i,
                                enabled: !_saving,
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Icon(
                                    Icons.drag_handle,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                              title: Text(
                                '${i + 1}. ${_media[e.mediaId]!.title}',
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                _subtitle(e),
                                style: const TextStyle(color: Colors.white70),
                              ),
                              trailing: IconButton(
                                onPressed: _saving
                                    ? null
                                    : () =>
                                          setState(() => _entries.removeAt(i)),
                                tooltip: 'Remove from draft',
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.orangeAccent),
                        ),
                      ),
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _saving ? null : _save,
                            child: Text(
                              _saving
                                  ? 'Saving to your account…'
                                  : _editing
                                  ? 'Save changes'
                                  : 'Save marathon',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    ),
  );

  Widget _buildSetup() => Form(
    key: _setupForm,
    child: ListView(
      padding: const EdgeInsets.all(24),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        const Text(
          'Make it your marathon',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Give it a name and choose a cover. Next, build your viewing order.',
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _title,
          maxLength: 120,
          style: const TextStyle(color: Color(0xFF1A2931)),
          decoration: InputDecoration(
            hintText: 'Marathon name',
            counterText: '',
            filled: true,
            fillColor: const Color(0xFFF2EADF),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
          ),
          validator: (value) => value == null || value.trim().isEmpty
              ? 'Give your marathon a name'
              : null,
        ),
        const SizedBox(height: 20),
        const Text(
          'Cover image',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        MarathonPhotoField(
          objectId: () => 'cover-$_id',
          label: 'Choose a photo from your phone',
          onChanged: (_) {},
          onReady: (ready) => setState(() => _photoReady = ready),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: !_photoReady
              ? null
              : () {
                  if (!_setupForm.currentState!.validate()) return;
                  FocusScope.of(context).unfocus();
                  setState(() => _addingEntries = true);
                },
          child: const Text('Next: add entries'),
        ),
      ],
    ),
  );
}
