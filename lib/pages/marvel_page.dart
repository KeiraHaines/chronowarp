import 'package:chronowarp/data/marvel_data.dart';
import 'package:chronowarp/widgets/universe_watch_page.dart';
import 'package:flutter/material.dart';

class MarvelPage extends StatelessWidget {
  const MarvelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return UniverseWatchPage(
      config: UniverseConfig(
        title: 'Marvel Cinematic Universe',
        releaseItems: mcuReleaseOrder,
        chronologicalItems: mcuChronologicalOrder,
        bgPage: const Color(0XFFF7FAFC),
        bgCard: const Color(0XFFFFFFFF),
        bgChip: const Color(0XFFD9ECF7),
        accentPrimary: const Color(0XFFF0141A),
        accentSecondary: const Color(0XFF0499D7),
        textPrimary: const Color(0XFF052451),
        textMuted: const Color(0XFF6E7F93),
        textCard: const Color(0XFF102A43),
        textCardMuted: const Color(0XFF8FA8B8),
      ),
    );
  }
}
