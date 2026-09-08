import 'package:flutter/material.dart';
import '../models/marathon.dart';

class MarathonMediaPickerPage extends StatefulWidget {
  final Map<String, CatalogMedia> library;
  const MarathonMediaPickerPage({super.key, required this.library});
  @override
  State<MarathonMediaPickerPage> createState() =>
      _MarathonMediaPickerPageState();
}

class _MarathonMediaPickerPageState extends State<MarathonMediaPickerPage> {
  String _query = '';
  @override
  Widget build(BuildContext context) {
    final items =
        widget.library.values.where((m) {
          final searchable =
              '${m.title} ${m.showTitle ?? ''} ${m.universeId} ${m.kind.name} ${m.episodes.map((e) => e.title ?? '').join(' ')}'
                  .toLowerCase();
          return _query
              .toLowerCase()
              .trim()
              .split(RegExp(r'\s+'))
              .every(searchable.contains);
        }).toList()..sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
    return Scaffold(
      backgroundColor: const Color(0xFF1A2931),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A2931),
        foregroundColor: Colors.white,
        title: const Text('Add existing item'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                autofocus: false,
                onChanged: (value) => setState(() => _query = value),
                style: const TextStyle(color: Color(0xFF1A2931)),
                decoration: InputDecoration(
                  hintText: 'Search titles, universes or episodes',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: const Color(0xFFF2EADF),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'No matching items. Try another search or add a new entry.',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            Expanded(
              child: ListView.builder(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final m = items[index];
                  final kind = switch (m.kind) {
                    MediaKind.movie => 'Movie',
                    MediaKind.season => 'TV season',
                    MediaKind.game => 'Video game',
                  };
                  return ListTile(
                    leading: Icon(switch (m.kind) {
                      MediaKind.movie => Icons.movie_outlined,
                      MediaKind.season => Icons.tv,
                      MediaKind.game => Icons.sports_esports_outlined,
                    }, color: Colors.orangeAccent),
                    title: Text(
                      m.title,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      '${m.universeId == 'private' ? 'Your media' : m.universeId.replaceAll('-', ' ')} · $kind · ${m.dateLabel}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: const Icon(
                      Icons.add_circle_outline,
                      color: Colors.orangeAccent,
                    ),
                    onTap: () => Navigator.pop(context, m),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
