import 'package:chronowarp/data/universe_configs.dart';
import 'package:chronowarp/widgets/universe_watch_page.dart';
import 'package:flutter/material.dart';

class PixarPage extends StatelessWidget {
  const PixarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return UniverseWatchPage(config: pixarConfig);
  }
}
