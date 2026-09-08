import 'package:flutter/material.dart';

class StarwarsPage extends StatelessWidget {
  const StarwarsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Star Wars")),
      body: const Center(child: Text("Star Wars Page")),
    );
  }
}
