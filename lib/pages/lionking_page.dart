import 'package:chronowarp/data/universe_configs.dart';
import 'package:chronowarp/widgets/universe_watch_page.dart';
import 'package:flutter/material.dart';

class LionKingPage extends StatelessWidget {
  const LionKingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return UniverseWatchPage(config: lionKingConfig);
  }
}

// Option 1 — Balanced Lamp Theme
// bgPage:           const Color(0XFFB73A32),
// bgCard:           const Color(0XFFFFF2D2),
// bgChip:           const Color(0XFF2F5F8A),
// accentPrimary:    const Color(0XFFE0A735),
// accentSecondary:  const Color(0XFFC9342D),
// textPrimary:      const Color(0XFFFFFFFF),
// textMuted:        const Color(0XFFE8D6C2),
// textCard:         const Color(0XFF25384A),
// textCardMuted:    const Color(0XFF7A6646),
// Option 2 — Softer Retro Toy Theme
// bgPage:           const Color(0XFFA9463D),
// bgCard:           const Color(0XFFFFF6E2),
// bgChip:           const Color(0XFF557A9D),
// accentPrimary:    const Color(0XFFD9A23A),
// accentSecondary:  const Color(0XFFB93630),
// textPrimary:      const Color(0XFFFFF7EA),
// textMuted:        const Color(0XFFD9C6B8),
// textCard:         const Color(0XFF24313C),
// textCardMuted:    const Color(0XFF8B7352),
// Option 3 — Brighter Pixar-Lamp Style
// bgPage:           const Color(0XFFC73A32),
// bgCard:           const Color(0XFFFFFFFF),
// bgChip:           const Color(0XFF2F6FA3),
// accentPrimary:    const Color(0XFFF0B83E),
// accentSecondary:  const Color(0XFFD84435),
// textPrimary:      const Color(0XFFFFFFFF),
// textMuted:        const Color(0XFFFFE5C4),
// textCard:         const Color(0XFF25313A),
// textCardMuted:    const Color(0XFF8A6C43),
// Option 4 — Muted App-Friendly Version
// bgPage:           const Color(0XFF963F38),
// bgCard:           const Color(0XFFFFF1D6),
// bgChip:           const Color(0XFF496D8F),
// accentPrimary:    const Color(0XFFD19A35),
// accentSecondary:  const Color(0XFFB84335),
// textPrimary:      const Color(0XFFF8EFE4),
// textMuted:        const Color(0XFFDCC8B4),
// textCard:         const Color(0XFF2E3540),
// textCardMuted:    const Color(0XFF846B4B),

// My pick would be Option 4 for an app theme because it keeps the lamp/image feel but is easier on the eyes than the very bright red, blue, and yellow.
