import 'package:flutter/material.dart';
import '../data/universe_configs.dart';
import '../widgets/universe_watch_page.dart';

class StarwarsPage extends StatelessWidget {
  const StarwarsPage({super.key});
  @override
  Widget build(BuildContext context) =>
      UniverseWatchPage(config: starWarsConfig);
}
