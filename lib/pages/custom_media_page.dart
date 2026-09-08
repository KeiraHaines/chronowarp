import 'package:flutter/material.dart';
import '../widgets/marathon_photo_field.dart';
import '../models/marathon.dart';
import '../services/marathon_repository.dart';

class CustomMediaPage extends StatefulWidget {
  const CustomMediaPage({super.key});
  @override
  State<CustomMediaPage> createState() => _CustomMediaPageState();
}

class _CustomMediaPageState extends State<CustomMediaPage> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController(),
      _date = TextEditingController(),
      _runtime = TextEditingController(),
      _director = TextEditingController(),
      _blurb = TextEditingController(),
      _show = TextEditingController(),
      _season = TextEditingController(text: '1'),
      _count = TextEditingController();
  late final _repository = MarathonRepository.current();
  late final _id = _repository.newId();
  MediaKind _kind = MediaKind.movie;
  bool _photoReady = true;
  String? _posterUrl;
  DateTime? _releaseDate;
  String? _error;
  final Map<int, String> _episodeTitles = {};
  final Map<int, int> _episodeDurations = {};
  @override
  void dispose() {
    for (final c in [
      _title,
      _date,
      _runtime,
      _director,
      _blurb,
      _show,
      _season,
      _count,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _positive(String? value) => value == null || value.isEmpty
      ? null
      : (int.tryParse(value) ?? 0) <= 0
      ? 'Enter a positive number'
      : null;
  Future<void> _pickDate() async {
    FocusScope.of(context).unfocus();
    final date = await showDatePicker(
      context: context,
      initialDate: _releaseDate ?? DateTime.now(),
      firstDate: DateTime(1880),
      lastDate: DateTime(DateTime.now().year + 20, 12, 31),
      initialDatePickerMode: DatePickerMode.year,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      helpText: 'Choose release date',
    );
    if (date == null || !mounted) return;
    setState(() {
      _releaseDate = date;
      _date.text = MaterialLocalizations.of(context).formatMediumDate(date);
    });
  }

  Future<void> _nameEpisodes() async {
    final count = int.tryParse(_count.text) ?? 0;
    if (count < 1 || count > 300) {
      setState(() => _error = 'Enter 1–300 episodes first.');
      return;
    }
    final controllers = {
      for (var i = 1; i <= count; i++)
        i: TextEditingController(text: _episodeTitles[i]),
    };
    final durations = {
      for (var i = 1; i <= count; i++)
        i: TextEditingController(text: _episodeDurations[i]?.toString()),
    };
    final episodeForm = GlobalKey<FormState>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.8,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Column(
              children: [
                const Text(
                  'Episode details (optional)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: Form(
                    key: episodeForm,
                    child: ListView(
                      children: [
                        for (final e in controllers.entries)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: e.value,
                                  maxLength: 160,
                                  decoration: InputDecoration(
                                    hintText: 'Episode ${e.key} name',
                                    counterText: '',
                                  ),
                                ),
                                TextFormField(
                                  controller: durations[e.key],
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    hintText: 'Duration (minutes)',
                                  ),
                                  validator: _positive,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                FilledButton(
                  onPressed: () {
                    if (!episodeForm.currentState!.validate()) return;
                    for (final e in controllers.entries) {
                      _episodeTitles[e.key] = e.value.text.trim();
                      final duration = int.tryParse(durations[e.key]!.text);
                      if (duration == null) {
                        _episodeDurations.remove(e.key);
                      } else {
                        _episodeDurations[e.key] = duration;
                      }
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Done'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    // The sheet's route animates out after its future completes.
    await Future<void>.delayed(const Duration(milliseconds: 350));
    for (final c in [...controllers.values, ...durations.values]) {
      c.dispose();
    }
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    final count = _kind == MediaKind.season ? int.parse(_count.text) : 0;
    final media = CatalogMedia(
      id: _id,
      universeId: 'private',
      kind: _kind,
      title: _title.text.trim(),
      releaseDate: _releaseDate?.toIso8601String().substring(0, 10),
      runtimeMinutes: int.tryParse(_runtime.text),
      director: _director.text.trim(),
      blurb: _blurb.text.trim(),
      poster: _posterUrl,
      showTitle: _kind == MediaKind.season ? _show.text.trim() : null,
      seasonNumber: _kind == MediaKind.season ? int.parse(_season.text) : null,
      episodes: List.generate(
        count,
        (i) => EpisodeRecord(
          id: '$_id-ep-${i + 1}',
          number: i + 1,
          runtimeMinutes: _episodeDurations[i + 1],
          title: _episodeTitles[i + 1]?.isNotEmpty == true
              ? _episodeTitles[i + 1]
              : null,
        ),
      ),
    );
    Navigator.pop(context, media);
  }

  Widget _field(
    TextEditingController c,
    String label, {
    bool required = false,
    bool numeric = false,
    int lines = 1,
    int? maxLength,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextFormField(
      controller: c,
      readOnly: readOnly,
      onTap: onTap,
      maxLength: maxLength,
      maxLines: lines,
      keyboardType: numeric ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Color(0xFF1A2931)),
      decoration: InputDecoration(
        hintText: label,
        suffixIcon: suffixIcon,
        hintStyle: const TextStyle(color: Color(0xFF68757A)),
        filled: true,
        fillColor: const Color(0xFFF2EADF),
        counterText: '',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (v) => required && (v == null || v.trim().isEmpty)
          ? 'Required'
          : validator?.call(v),
    ),
  );
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF1A2931),
    appBar: AppBar(
      backgroundColor: const Color(0xFF1A2931),
      foregroundColor: Colors.white,
      title: const Text('Add your media'),
    ),
    body: Form(
      key: _form,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Add details you know. Missing information can stay blank.',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 18),
          DropdownButtonFormField<MediaKind>(
            initialValue: _kind,
            borderRadius: BorderRadius.circular(20),
            dropdownColor: const Color(0xFFF2EADF),
            style: const TextStyle(color: Color(0xFF1A2931), fontSize: 16),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF2EADF),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
              ),
            ),
            items: const [
              DropdownMenuItem(value: MediaKind.movie, child: Text('Movie')),
              DropdownMenuItem(
                value: MediaKind.season,
                child: Text('TV show — one season'),
              ),
              DropdownMenuItem(
                value: MediaKind.game,
                child: Text('Video game'),
              ),
            ],
            onChanged: (value) => setState(() => _kind = value!),
          ),
          const SizedBox(height: 16),
          _field(
            _title,
            _kind == MediaKind.season ? 'Season entry title' : 'Title',
            required: true,
            maxLength: 160,
          ),
          if (_kind == MediaKind.season) ...[
            _field(_show, 'TV show name', required: true, maxLength: 160),
            _field(
              _season,
              'Season number',
              required: true,
              numeric: true,
              validator: _positive,
            ),
            _field(
              _count,
              'Number of episodes',
              required: true,
              numeric: true,
              validator: (v) {
                final value = int.tryParse(v ?? '') ?? 0;
                return value < 1 || value > 300 ? 'Enter 1–300 episodes' : null;
              },
            ),
            TextButton.icon(
              onPressed: _nameEpisodes,
              icon: const Icon(Icons.list),
              label: const Text('Add episode names and durations'),
            ),
          ],
          _field(
            _date,
            'Release date',
            readOnly: true,
            onTap: _pickDate,
            suffixIcon: _releaseDate == null
                ? const Icon(Icons.calendar_month_outlined)
                : IconButton(
                    tooltip: 'Clear release date',
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() {
                      _releaseDate = null;
                      _date.clear();
                    }),
                  ),
          ),
          _field(
            _runtime,
            _kind == MediaKind.game
                ? 'Average play time (minutes)'
                : _kind == MediaKind.season
                ? 'Average episode runtime (minutes)'
                : 'Runtime (minutes)',
            numeric: true,
            validator: _positive,
          ),
          _field(_director, 'Director', maxLength: 200),
          _field(_blurb, 'Blurb', lines: 4, maxLength: 3000),
          MarathonPhotoField(
            objectId: () => _id,
            label: 'Choose a photo from your phone',
            onChanged: (url) => _posterUrl = url,
            onReady: (ready) => setState(() => _photoReady = ready),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.orangeAccent),
              ),
            ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _photoReady ? _save : null,
            child: const Text('Add to marathon'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    ),
  );
}
