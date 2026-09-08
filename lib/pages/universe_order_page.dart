import 'package:flutter/material.dart';
import '../models/marathon.dart';
import '../data/marathon_catalog.dart';
import '../services/marathon_repository.dart';
import '../widgets/universe_watch_page.dart';
import 'marathon_run_page.dart';

class UniverseOrderPage extends StatefulWidget {
  final UniverseConfig config;
  const UniverseOrderPage({super.key, required this.config});
  @override
  State<UniverseOrderPage> createState() => _UniverseOrderPageState();
}

class _UniverseOrderPageState extends State<UniverseOrderPage> {
  late final repository = MarathonRepository.current();
  late final choices = [
    universeMarathon(widget.config, ViewingOrder.release),
    universeMarathon(widget.config, ViewingOrder.chronological),
  ];
  late final streams = {for (final m in choices) m.id: repository.run(m.id)};
  @override
  Widget build(BuildContext context) {
    final c = widget.config;
    return Scaffold(
      backgroundColor: c.bgPage,
      appBar: AppBar(
        backgroundColor: c.bgPage,
        foregroundColor: c.textPrimary,
        title: Text(c.title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'How would you like to watch?',
            style: TextStyle(
              color: c.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Each order remembers its own progress, synced to your account.',
            style: TextStyle(color: c.textMuted),
          ),
          const SizedBox(height: 24),
          for (final m in choices)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: StreamBuilder(
                stream: streams[m.id],
                builder: (context, snapshot) {
                  final progress = MarathonRepository.progress(snapshot.data);
                  final done = m.entries
                      .where((e) => progress.isComplete(e, m.media[e.mediaId]!))
                      .length;
                  final title = m.order == ViewingOrder.release
                      ? 'Release order'
                      : 'Chronological order';
                  return Material(
                    color: c.bgCard,
                    borderRadius: BorderRadius.circular(16),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      leading: Icon(
                        m.order == ViewingOrder.release
                            ? Icons.calendar_month
                            : Icons.timeline,
                        color: c.accentPrimary,
                      ),
                      title: Text(
                        title,
                        style: TextStyle(
                          color: c.textCard,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        m.entries.isEmpty
                            ? 'This list has not been added yet'
                            : snapshot.hasError
                            ? 'Progress unavailable — tap to retry'
                            : !snapshot.hasData
                            ? 'Loading progress…'
                            : '$done of ${m.entries.length} completed',
                        style: TextStyle(color: c.textCardMuted),
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: c.accentPrimary,
                      ),
                      onTap: m.entries.isEmpty
                          ? null
                          : () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    MarathonRunPage(marathon: m, config: c),
                              ),
                            ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
