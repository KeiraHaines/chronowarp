import 'package:flutter/material.dart';

const marvelAvatars = <String, String>{
  'avengers': 'Avengers',
  'infinity-gauntlet': 'Infinity Gauntlet',
  'shield': 'S.H.I.E.L.D.',
};

const lionKingAvatars = <String, String>{
  'rafiki-simba': "Rafiki’s Simba",
  'pride-rock': 'Pride Rock',
  'lion-guard': 'Lion Guard',
};

String? avatarAssetPath(String? id) {
  for (final group in {
    'marvel': marvelAvatars,
    'lionking': lionKingAvatars,
  }.entries) {
    for (final key in group.value.keys) {
      if (id == '${group.key}-$key')
        return 'assets/avatars/${group.key}/$key.png';
    }
  }
  return null;
}

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    this.avatarId,
    required this.name,
    this.radius = 18,
  });
  final String? avatarId;
  final String name;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final asset = avatarAssetPath(avatarId);
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFF344D59),
      child: asset != null
          ? ClipOval(
              child: Image.asset(
                asset,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                cacheWidth: (radius * 6).round(),
              ),
            )
          : Text(
              name.isEmpty ? '?' : name.characters.first.toUpperCase(),
              style: TextStyle(
                color: const Color(0xFFF5DEB3),
                fontSize: radius * .8,
              ),
            ),
    );
  }
}

class AvatarPicker extends StatefulWidget {
  const AvatarPicker({super.key, this.initialAvatarId});
  final String? initialAvatarId;
  @override
  State<AvatarPicker> createState() => _AvatarPickerState();
}

class _AvatarPickerState extends State<AvatarPicker> {
  late String? selected = widget.initialAvatarId;
  late String group = widget.initialAvatarId?.startsWith('lionking-') == true
      ? 'lionking'
      : 'marvel';
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF1A2931),
    appBar: AppBar(
      title: const Text('Choose your avatar'),
      backgroundColor: const Color(0xFF1A2931),
    ),
    body: SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  group == 'marvel' ? 'Marvel' : 'The Lion King',
                  style: TextStyle(
                    color: Color(0xFFF5DEB3),
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Choose a favourite for your profile.',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'marvel', label: Text('Marvel')),
                ButtonSegment(value: 'lionking', label: Text('The Lion King')),
              ],
              selected: {group},
              onSelectionChanged: (value) =>
                  setState(() => group = value.first),
              style: SegmentedButton.styleFrom(
                foregroundColor: Colors.white70,
                selectedForegroundColor: const Color(0xFF1A2931),
                selectedBackgroundColor: const Color(0xFFF5DEB3),
              ),
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: .95,
              children: (group == 'marvel' ? marvelAvatars : lionKingAvatars)
                  .entries
                  .map((entry) {
                    final id = '$group-${entry.key}';
                    final active = selected == id;
                    return Semantics(
                      selected: active,
                      button: true,
                      label: entry.value,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(22),
                        onTap: () => setState(() => selected = id),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: active
                                ? const Color(0xFF405866)
                                : const Color(0xFF253B46),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: active
                                  ? const Color(0xFFF5DEB3)
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                child: Center(
                                  child: LayoutBuilder(
                                    builder: (context, constraints) =>
                                        ProfileAvatar(
                                          avatarId: id,
                                          name: entry.value,
                                          radius: constraints.maxHeight / 2,
                                        ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                entry.value,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  })
                  .toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: selected == null
                    ? null
                    : () => Navigator.pop(context, selected),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFF5DEB3),
                  foregroundColor: const Color(0xFF1A2931),
                  padding: const EdgeInsets.all(16),
                ),
                child: const Text('Use avatar'),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
