import 'package:flutter/material.dart';

const marvelAvatars = <String, String>{
  "iron-man-badge": "Iron Man",
  "captain-america-badge": "Captain America",
  "thor-badge": "Thor",
  "hulk-badge": "Hulk",
  "black-widow-badge": "Black Widow",
  "hawkeye-badge": "Hawkeye",
};

const lionKingAvatars = <String, String>{
  "simba-badge": "Simba",
  "pride-rock-badge": "Pride Rock",
  "scar-badge": "Scar",
  "hakuna-matata-badge": "Timon & Pumbaa",
  "sun-badge": "Circle of Life",
  "elephants-badge": "Elephants",
};

const starWarsAvatars = <String, String>{
  "jedi-badge": "Jedi Order",
  "empire-badge": "Galactic Empire",
  "rebel-badge": "Rebel Alliance",
  "mandalorian-badge": "Mandalorian",
  "bb8-badge": "BB-8",
  "clone-badge": "Clone Trooper",
};

const pixarAvatars = <String, String>{
  "ball-badge": "Star Ball",
  "rocket-badge": "Rocket",
  "mike-badge": "Mike Wazowski",
  "nemo-badge": "Nemo",
  "plant-badge": "WALL-E’s Plant",
  "up-badge": "Up House",
};

const wizardingAvatars = <String, String>{
  "hogwarts": "Hogwarts",
  "hedwig": "Hedwig",
  "deathly-hallows": "Deathly Hallows",
  "gryffindor": "Gryffindor",
  "slytherin": "Slytherin",
  "ravenclaw": "Ravenclaw",
  "hufflepuff": "Hufflepuff",
};

const princessAvatars = <String, String>{
  "cinderella": "Cinderella",
  "belle": "Belle",
  "ariel": "Ariel",
  "snow-white": "Snow White",
  "rapunzel": "Rapunzel",
  "jasmine": "Jasmine",
};

const hungerAvatars = <String, String>{
  "mockingjay": "Mockingjay",
  "capitol": "Capitol",
  "arrows": "Arrows",
  "flames": "Flames",
  "district-12": "District 12",
  "trident": "Trident",
};
const bondAvatars = <String, String>{
  "gun-barrel": "Gun Barrel",
  "007": "007",
  "london": "London",
  "tuxedo": "Tuxedo",
  "alpine-mission": "Alpine Mission",
  "secret-service": "Secret Service",
};
const indianaAvatars = <String, String>{
  "fedora-and-whip": "Fedora and Whip",
  "jungle-temple": "Jungle Temple",
  "golden-idol": "Golden Idol",
  "compass": "Compass",
  "canyon-explorer": "Canyon Explorer",
  "adventure-plane": "Adventure Plane",
  "explorer-hat": "Explorer Hat",
  "canyon-silhouette": "Canyon Silhouette",
  "temple-idol": "Temple Idol",
  "map-and-compass": "Map and Compass",
  "whip-swing": "Whip Swing",
  "ancient-door": "Ancient Door",
};
const missionAvatars = <String, String>{
  "vault-heist": "Vault Heist",
  "target-map": "Target Map",
  "secret-device": "Secret Device",
  "voiceprint": "Voiceprint",
  "laser-corridor": "Laser Corridor",
  "disguise": "Disguise",
};
const piratesAvatars = <String, String>{
  "pirate-captain": "Pirate Captain",
  "black-pearl": "Black Pearl",
  "treasure-cove": "Treasure Cove",
  "treasure-map": "Treasure Map",
  "moonlit-pirate": "Moonlit Pirate",
  "pirate-flag": "Pirate Flag",
};
const lotrAvatars = <String, String>{
  "the-one-ring": "The One Ring",
  "gandalf": "Gandalf",
  "white-tree": "White Tree",
  "the-fellowship": "The Fellowship",
  "barad-dur": "Barad-dur",
  "elven-archer": "Elven Archer",
};
const jurassicAvatars = <String, String>{
  "t-rex": "T-Rex",
  "moonlit-dinosaur": "Moonlit Dinosaur",
  "park-gates": "Park Gates",
  "dinosaur-eye": "Dinosaur Eye",
  "footprint": "Footprint",
  "raptor": "Raptor",
};
const dragonsAvatars = <String, String>{
  "hiccup": "Hiccup",
  "dragon-rider": "Dragon Rider",
  "toothless-and-hiccup": "Toothless and Hiccup",
  "dragon-flight": "Dragon Flight",
  "viking-shield": "Viking Shield",
  "berk-warrior": "Berk Warrior",
};

const avatarGroups = {

  'marvel': marvelAvatars,
  'lionking': lionKingAvatars,
  'starwars': starWarsAvatars,
  'pixar': pixarAvatars,
  'princess': princessAvatars,
  'wizarding': wizardingAvatars,
  'hunger': hungerAvatars,
  'bond': bondAvatars,
  'indiana': indianaAvatars,
  'mission': missionAvatars,
  'pirates': piratesAvatars,
  'lotr': lotrAvatars,
  'jurassic': jurassicAvatars,
  'dragons': dragonsAvatars,
};
const avatarGroupNames = {

  'marvel': 'Marvel',
  'lionking': 'The Lion King',
  'starwars': 'Star Wars',
  'pixar': 'Pixar',
  'princess': 'Disney Princess',
  'wizarding': 'Wizarding World',
  'hunger': 'The Hunger Games',
  'bond': 'James Bond',
  'indiana': 'Indiana Jones',
  'mission': 'Mission: Impossible',
  'pirates': 'Pirates of the Caribbean',
  'lotr': 'The Lord of the Rings',
  'jurassic': 'Jurassic World',
  'dragons': 'How to Train Your Dragon',
};

String? avatarAssetPath(String? id) {
  for (final group in avatarGroups.entries) {
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
  late String? selected = avatarAssetPath(widget.initialAvatarId) == null
      ? null
      : widget.initialAvatarId;
  late String group = avatarGroups.keys.firstWhere(
    (key) => widget.initialAvatarId?.startsWith('$key-') == true,
    orElse: () => 'marvel',
  );
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF1A2931),
    appBar: AppBar(
      title: const Text('Choose your avatar'),
      foregroundColor: Colors.white,
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
                  avatarGroupNames[group]!,
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
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SegmentedButton<String>(
                segments: [
                  for (final entry in avatarGroupNames.entries)
                    ButtonSegment(value: entry.key, label: Text(entry.value)),
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
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: .95,
              children: avatarGroups[group]!.entries.map((entry) {
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
              }).toList(),
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
