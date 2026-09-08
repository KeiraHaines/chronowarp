import 'package:chronowarp/data/universe_configs.dart';
import 'package:chronowarp/widgets/universe_watch_page.dart';
import 'package:flutter/material.dart';

class MarvelPage extends StatelessWidget {
  const MarvelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return UniverseWatchPage(config: marvelConfig);
  }
}
