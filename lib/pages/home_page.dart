import '../transitions/portal_transition.dart';
import '../widgets/custom_marathon_home_card.dart';
import 'package:chronowarp/data/marathon_catalog.dart';
import 'package:chronowarp/data/universe_configs.dart';
import 'package:chronowarp/models/marathon.dart';
import 'package:chronowarp/services/marathon_repository.dart';
import 'package:chronowarp/data/marvel_data.dart';
import 'package:chronowarp/data/lionking_data.dart';
import 'package:chronowarp/data/pixar_data.dart';
import 'package:chronowarp/models/media_item.dart';
import 'package:chronowarp/pages/account_page.dart';
import 'package:chronowarp/pages/create_marathon_page.dart';
import 'package:chronowarp/pages/friends_page.dart';
import 'package:chronowarp/pages/lionking_page.dart';
import 'package:chronowarp/pages/marvel_page.dart';
import 'package:chronowarp/pages/overall_ranking_page.dart';
import 'package:chronowarp/pages/pixar_page.dart';
import 'package:chronowarp/pages/starwars_page.dart';
import 'package:chronowarp/pages/watch_party_lobby_page.dart';
import 'package:chronowarp/pages/watch_party_page.dart';
import 'package:chronowarp/stores/progress_store.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chronowarp/pages/watch_party_discovery_page.dart';

class HomeUniverseEntry {
  final String key;
  final String backgroundImage;
  final List<MediaItem> items;
  final VoidCallback onTap;

  const HomeUniverseEntry({
    required this.key,
    required this.backgroundImage,
    required this.items,
    required this.onTap,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _store = ProgressStore.instance;
  late final PageController _pageController;
  int _currentPage = 0;
  late final _marathons = MarathonRepository.current();
  late final _savedMarathons = _marathons.marathons();
  List<MarathonDefinition> _savedDefinitions = [];
  String? _focusMarathonId;
  late final _releaseRuns = {
    for (final c in availableUniverses)
      c.title: _marathons.run(universeMarathon(c, ViewingOrder.release).id),
  };

  late final _personalLists = {
    for (final c in availableUniverses)
      c.title: _marathons.universeList(
        universeMarathon(c, ViewingOrder.release).id,
      ),
  };

  late final List<HomeUniverseEntry> _entries = [
    HomeUniverseEntry(
      key: 'Marvel Cinematic Universe',
      backgroundImage: "assets/cards/marvel.png",
      items: mcuReleaseOrder,
      onTap: () => Navigator.push(
        context,
        PortalPageRoute(
          builder: (context) => const MarvelPage(),
          primary: marvelConfig.accentPrimary,
          secondary: marvelConfig.accentSecondary,
        ),
      ),
    ),
    HomeUniverseEntry(
      key: 'Star Wars Universe',
      backgroundImage: "assets/cards/starwars.png",
      items: const [],
      onTap: () => Navigator.push(
        context,
        PortalPageRoute(
          builder: (context) => const StarwarsPage(),
          primary: starWarsConfig.accentPrimary,
          secondary: starWarsConfig.accentSecondary,
        ),
      ),
    ),
    HomeUniverseEntry(
      key: 'Lion King',
      backgroundImage: "assets/cards/lionking.png",
      items: lionKingReleaseOrder,
      onTap: () => Navigator.push(
        context,
        PortalPageRoute(
          builder: (context) => const LionKingPage(),
          primary: lionKingConfig.accentPrimary,
          secondary: lionKingConfig.accentSecondary,
        ),
      ),
    ),
    HomeUniverseEntry(
      key: 'Pixar',
      backgroundImage: "assets/cards/pixar.png",
      items: pixarOrder,
      onTap: () => Navigator.push(
        context,
        PortalPageRoute(
          builder: (context) => const PixarPage(),
          primary: pixarConfig.accentPrimary,
          secondary: pixarConfig.accentSecondary,
        ),
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    _pageController.addListener(() {
      final page = (_pageController.page ?? 0).round();
      if (page != _currentPage && mounted) {
        setState(() => _currentPage = page);
      }
    });
    _store.addListener(_onStoreChanged);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _store.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) => StreamBuilder(
    stream: _savedMarathons,
    builder: (context, snapshot) {
      _savedDefinitions =
          snapshot.data?.docs
              .map((d) => MarathonDefinition.fromJson(d.id, d.data()))
              .toList() ??
          [];
      _savedDefinitions.sort(
        (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
      );
      final focusIndex = _savedDefinitions.indexWhere(
        (m) => m.id == _focusMarathonId,
      );
      if (focusIndex >= 0) {
        _focusMarathonId = null;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _pageController.hasClients)
            _pageController.animateToPage(
              _entries.length + focusIndex,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
        });
      }
      return _buildHome(context, _savedDefinitions, snapshot.hasError);
    },
  );

  Widget _buildHome(
    BuildContext context,
    List<MarathonDefinition> saved,
    bool savedError,
  ) {
    final entries = _entries;
    final cardCount = entries.length + saved.length;
    if (_currentPage >= cardCount) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _pageController.hasClients)
          _pageController.jumpToPage(cardCount - 1);
      });
    }
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final screenWidth = MediaQuery.of(context).size.width;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(26, 41, 49, 1),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // ── Background ──────────────────────────────────────
            Positioned.fill(
              child: Image.asset(
                "assets/mainBck/mainBck.png",
                fit: BoxFit.fill,
                cacheWidth: (screenWidth * dpr).round(),
              ),
            ),

            // ── Main content column ─────────────────────────────
            Column(
              children: [
                _buildHeader(screenWidth, dpr),
                const SizedBox(height: 12),

                // Card carousel
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const ClampingScrollPhysics(),
                    itemCount: cardCount,
                    itemBuilder: (context, index) {
                      if (index < entries.length)
                        return _buildCard(entries[index]);
                      final marathon = saved[index - entries.length];
                      return CustomMarathonHomeCard(
                        key: ValueKey(marathon.id),
                        marathon: marathon,
                      );
                    },
                  ),
                ),

                const SizedBox(height: 14),

                // Page indicator dots
                if (savedError)
                  const Text(
                    'Your marathons could not be loaded.',
                    style: TextStyle(color: Colors.orangeAccent),
                  ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: screenWidth),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(cardCount, (index) {
                        final active = _currentPage == index;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: active ? 12 : 8,
                          height: active ? 12 : 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: active
                                ? const Color(0xFFD4622A)
                                : Colors.white54,
                          ),
                        );
                      }),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // ── Bottom nav bar ──────────────────────────────
                _buildNavBar(bottomPad),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Header: profile icon | logo | (empty space symmetry) ───────────────
  Widget _buildHeader(double screenWidth, double dpr) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Image.asset(
        "assets/LogoLightNoBck.png",
        fit: BoxFit.contain,
        height: 200,
        cacheWidth: (screenWidth * 0.65 * dpr).round(),
      ),
    );
  }

  // ── Bottom nav bar ──────────────────────────────────────────────────────
  //
  // Layout (5 slots):
  //   [?]  [Friends]  [+ CREATE]  [Rankings]  [Profile]
  //
  // The centre button is taller and orange, matching the mockup FAB-in-bar
  // style. The bar has a notch/arch effect via a taller centre container.
  Widget _buildNavBar(double bottomPad) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPad + 12),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(20, 32, 40, 0.97),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _navButton(
            icon: Icons.live_tv_outlined,
            label: 'Watch Parties',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WatchPartyDiscoverPage()),
            ),
          ),

          // 2 — Friends
          _navButton(
            icon: Icons.group_outlined,
            label: 'Friends',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FriendsPage()),
            ),
          ),

          // 3 — Create Marathon (prominent centre button)
          _createButton(),

          // 4 — Rankings
          _navButton(
            icon: Icons.leaderboard_outlined,
            label: 'Rankings',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const OverallRankingsPage()),
            ),
          ),

          // 5 — Profile
          _navButton(
            icon: Icons.person_outline,
            label: 'Profile',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AccountPage()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white60, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white54,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _createButton() {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push<MarathonDefinition>(
          context,
          MaterialPageRoute(
            builder: (_) => CreateMarathonPage(
              library: {for (final m in _savedDefinitions) ...m.media},
            ),
          ),
        );
        if (result != null && mounted)
          setState(() => _focusMarathonId = result.id);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFFD4622A),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD4622A).withValues(alpha: 0.45),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 4),
          const Text(
            'Create',
            style: TextStyle(
              fontSize: 10,
              color: Color(0xFFD4622A),
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  // ── Card ────────────────────────────────────────────────────────────────
  Widget _buildCard(HomeUniverseEntry entry) {
    final config = universeConfigFor(entry.key);
    if (config == null)
      return _buildCardContent(entry, const {}, 'List not added yet');
    final template = universeMarathon(config, ViewingOrder.release);
    return StreamBuilder(
      stream: _personalLists[config.title],
      builder: (context, listSnapshot) {
        final definition = listSnapshot.data?.exists == true
            ? MarathonDefinition.fromJson(
                template.id,
                listSnapshot.data!.data()!,
              )
            : template;
        final displayEntry = HomeUniverseEntry(
          key: entry.key,
          backgroundImage: entry.backgroundImage,
          onTap: entry.onTap,
          items: [
            for (final (index, e) in definition.entries.indexed)
              MediaItem(
                number: index + 1,
                title: definition.media[e.mediaId]!.title,
                year: definition.media[e.mediaId]!.releaseYear ?? 0,
                type: definition.media[e.mediaId]!.kind == MediaKind.season
                    ? MediaType.show
                    : MediaType.movie,
                runtime: definition.media[e.mediaId]!.durationLabel,
                episodes: definition.media[e.mediaId]!.kind == MediaKind.season
                    ? e.units(definition.media[e.mediaId]!).length
                    : null,
              ),
          ],
        );
        return StreamBuilder(
          stream: _releaseRuns[config.title],
          builder: (context, snapshot) {
            final progress = MarathonRepository.progress(snapshot.data);
            final watched = <int>{
              for (final (index, e) in definition.entries.indexed)
                if (progress.isComplete(e, definition.media[e.mediaId]!))
                  index + 1,
            };
            return _buildCardContent(
              displayEntry,
              watched,
              listSnapshot.hasError
                  ? 'Your saved list is unavailable'
                  : snapshot.hasError
                  ? 'Progress unavailable'
                  : !snapshot.hasData || !listSnapshot.hasData
                  ? 'Loading progress…'
                  : 'Release-order progress',
              definition: definition,
            );
          },
        );
      },
    );
  }

  Widget _buildCardContent(
    HomeUniverseEntry entry,
    Set<int> watched,
    String progressLabel, {
    MarathonDefinition? definition,
  }) {
    final total = entry.items.length;
    final watchedCount = entry.items
        .where((i) => watched.contains(i.number))
        .length;
    final progress = total > 0 ? watchedCount / total : 0.0;
    final movieCount = definition == null
        ? entry.items.where((i) => !i.isShow).length
        : definition.entries
              .where(
                (e) => definition.media[e.mediaId]!.kind == MediaKind.movie,
              )
              .length;
    final gameCount =
        definition?.entries
            .where((e) => definition.media[e.mediaId]!.kind == MediaKind.game)
            .length ??
        0;
    final episodeCount = entry.items.fold<int>(
      0,
      (sum, i) => sum + (i.episodes ?? 0),
    );

    MediaItem? nextUp;
    try {
      nextUp = entry.items.firstWhere((i) => !watched.contains(i.number));
    } catch (_) {
      nextUp = null;
    }

    final dpr = MediaQuery.of(context).devicePixelRatio;
    final cardWidth = MediaQuery.of(context).size.width * 0.85;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: entry.onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Card art
              Positioned.fill(
                child: Image.asset(
                  entry.backgroundImage,
                  fit: BoxFit.cover,
                  cacheWidth: (cardWidth * dpr).round(),
                ),
              ),

              // Bottom gradient + stats
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Color.fromRGBO(15, 24, 30, 0.97),
                      ],
                      stops: [0.0, 0.5],
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Next up
                      if (nextUp != null) ...[
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: const BoxDecoration(
                                color: Color(0xFFD4622A),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'NEXT UP',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFD4622A),
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  Text(
                                    nextUp.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  if (nextUp.runtime != null)
                                    Text(
                                      nextUp.runtime!,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFFC6D8F0),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],

                      Text(
                        progressLabel,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 5,
                          backgroundColor: const Color.fromRGBO(
                            255,
                            255,
                            255,
                            0.25,
                          ),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFFD4622A),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Stat row
                      Wrap(
                        alignment: WrapAlignment.center,
                        runSpacing: 8,
                        children: [
                          _statItem(
                            Icons.movie_outlined,
                            '$movieCount',
                            'MOVIES',
                          ),
                          const SizedBox(width: 20),
                          if (gameCount > 0) ...[
                            _statItem(
                              Icons.sports_esports_outlined,
                              '$gameCount',
                              'GAMES',
                            ),
                            const SizedBox(width: 12),
                          ],
                          if (episodeCount > 0)
                            _statItem(
                              Icons.play_circle_outline,
                              '$episodeCount',
                              'EPISODES',
                            ),
                        ],
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

  Widget _statItem(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white70),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: Colors.white60,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Keep sign-out reachable via the profile/account page instead.
void _showMenu(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color.fromRGBO(40, 58, 68, 1),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Menu",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.white),
              title: const Text(
                "Account Settings",
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AccountPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
                await FirebaseAuth.instance.signOut();
              },
            ),
            ListTile(
              leading: const Icon(Icons.people, color: Colors.white),
              title: const Text(
                'Friends',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FriendsPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_movies, color: Colors.white),
              title: const Text(
                'Watch Parties',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const WatchPartyLobbyPage(),
                  ),
                );
              },
            ),
          ],
        ),
      );
    },
  );
}
