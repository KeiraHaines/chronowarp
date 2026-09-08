import 'package:chronowarp/data/pixar_data.dart';
import 'package:chronowarp/data/lionking_data.dart';
import 'package:chronowarp/widgets/universe_watch_page.dart';
import 'package:flutter/material.dart';

class PixarPage extends StatelessWidget {
  const PixarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return UniverseWatchPage(
      config: UniverseConfig(
        title: 'Pixar',
        releaseItems: pixarOrder,
        chronologicalItems: lionKingChronologicalOrder,
        bgPage: const Color(0XFFA9463D),
        bgCard: const Color(0XFFFFF6E2),
        bgChip: const Color(0XFF557A9D),
        accentPrimary: const Color(0XFFD9A23A),
        accentSecondary: const Color(0XFFB93630),
        textPrimary: const Color(0XFFFFF7EA),
        textMuted: const Color(0XFFD9C6B8),
        textCard: const Color(0XFF24313C),
        textCardMuted: const Color(0XFF8B7352),
      ),
    );
  }
}
