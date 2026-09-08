import 'package:flutter/material.dart';

class CreateMarathonPage extends StatelessWidget {
  const CreateMarathonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(26, 41, 49, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(26, 41, 49, 1),
        foregroundColor: Colors.white,
        title: const Text('Create Marathon'),
      ),
      body: const Center(
        child: Text(
          'Create Marathon — coming soon',
          style: TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}
