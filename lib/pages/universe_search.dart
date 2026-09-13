import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class UniverseSearchEntry {
  final String title;
  final String? id;
  final bool isCustom;
  final List<String> titles;
  const UniverseSearchEntry({
    required this.title,
    this.titles = const [],
    this.id,
    this.isCustom = false,
  });
}

List<UniverseSearchEntry> searchUniverses(
  List<UniverseSearchEntry> entries,
  String query,
) {
  final words = query
      .toLowerCase()
      .trim()
      .split(RegExp(r'\s+'))
      .where((s) => s.isNotEmpty);
  return entries.where((entry) {
      final text = [entry.title, ...entry.titles].join(' ').toLowerCase();
      return words.every(text.contains);
    }).toList()
    ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
}

class UniverseSearch extends SearchDelegate<String> {
  final List<UniverseSearchEntry> entries;
  UniverseSearch(this.entries)
    : super(searchFieldLabel: 'Search universes or marathons');

  @override
  ThemeData appBarTheme(BuildContext context) => ThemeData.dark().copyWith(
    scaffoldBackgroundColor: const Color(0xFF1A2931),
    appBarTheme: const AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle.light,
      backgroundColor: Color(0xFF1A2931),
      foregroundColor: Colors.white,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: InputBorder.none,
      hintStyle: TextStyle(color: Colors.white60),
    ),
  );
  @override
  Widget buildLeading(BuildContext context) => IconButton(
    tooltip: 'Back',
    icon: const Icon(Icons.arrow_back),
    onPressed: () => close(context, ''),
  );
  @override
  List<Widget> buildActions(BuildContext context) => [
    if (query.isNotEmpty)
      IconButton(
        tooltip: 'Clear search',
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
  ];
  @override
  Widget buildSuggestions(BuildContext context) => _results(context);
  @override
  Widget buildResults(BuildContext context) => _results(context);
  Widget _results(BuildContext context) {
    final matches = searchUniverses(entries, query);
    if (matches.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No universes or marathons found. Try another name or title.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }
    return ListView.builder(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final entry = matches[index];
        return ListTile(
          leading: const Icon(
            Icons.movie_filter_outlined,
            color: Color(0xFFD4622A),
          ),
          title: Text(entry.title, style: const TextStyle(color: Colors.white)),
          subtitle: Text(
            entry.isCustom
                ? 'Custom marathon · ${entry.titles.length} entries'
                : entry.titles.isEmpty
                ? 'List coming soon'
                : '${entry.titles.length} entries',
            style: const TextStyle(color: Colors.white70),
          ),
          trailing: const Icon(Icons.chevron_right, color: Colors.white70),
          onTap: () => close(context, entry.id ?? entry.title),
        );
      },
    );
  }
}
