import '../services/marathon_photo_store.dart';
import 'marathon_image.dart';
import 'package:flutter/material.dart';
import '../models/marathon.dart';
import '../services/marathon_repository.dart';
import '../pages/marathon_run_page.dart';

class CustomMarathonHomeCard extends StatefulWidget {
  final MarathonDefinition marathon;
  const CustomMarathonHomeCard({super.key, required this.marathon});
  @override
  State<CustomMarathonHomeCard> createState() => _CustomMarathonHomeCardState();
}

class _CustomMarathonHomeCardState extends State<CustomMarathonHomeCard> {
  late final _run = MarathonRepository.current().run(widget.marathon.id);
  @override
  Widget build(BuildContext context) {
    final m = widget.marathon;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MarathonRunPage(marathon: m)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF517E86),
                      Color(0xFF283A44),
                      Color(0xFFD4622A),
                    ],
                  ),
                ),
              ),
              MarathonImage(
                source: MarathonPhotoStore.reference('cover-${m.id}'),
                placeholder: const Center(
                  child: Icon(
                    Icons.movie_filter_outlined,
                    size: 84,
                    color: Colors.white54,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Color(0xF20F181E)],
                      stops: [0, 0.45],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'YOUR MARATHON',
                        style: TextStyle(
                          color: Color(0xFFF8AE72),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        m.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      StreamBuilder(
                        stream: _run,
                        builder: (context, snapshot) {
                          final progress = MarathonRepository.progress(
                            snapshot.data,
                          );
                          final done = m.entries
                              .where(
                                (e) =>
                                    progress.isComplete(e, m.media[e.mediaId]!),
                              )
                              .length;
                          final remaining = m.entries.where(
                            (e) => !progress.isComplete(e, m.media[e.mediaId]!),
                          );
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                snapshot.hasError
                                    ? 'Progress unavailable'
                                    : !snapshot.hasData
                                    ? 'Loading progress…'
                                    : '$done of ${m.entries.length} entries completed',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(99),
                                child: LinearProgressIndicator(
                                  value: m.entries.isEmpty
                                      ? 0
                                      : done / m.entries.length,
                                  color: const Color(0xFFD4622A),
                                  backgroundColor: Colors.white24,
                                  minHeight: 5,
                                ),
                              ),
                              if (snapshot.hasData &&
                                  !snapshot.hasError &&
                                  remaining.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Text(
                                  'Next up: ${m.media[remaining.first.mediaId]!.title}',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
