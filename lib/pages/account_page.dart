import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  bool _savingAvatar = false;

  Future<void> _chooseAvatar(String uid, String? current) async {
    final selected = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => AvatarPicker(initialAvatarId: current)),
    );
    if (selected == null || selected == current || !mounted) return;
    setState(() => _savingAvatar = true);
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'avatarId': selected,
      }, SetOptions(merge: true));
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save your avatar. Please try again.'),
          ),
        );
    } finally {
      if (mounted) setState(() => _savingAvatar = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName =
        user?.displayName ?? user?.email?.split('@').first ?? "User";

    return Scaffold(
      backgroundColor: const Color.fromRGBO(26, 41, 49, 1),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 76,
        leadingWidth: 60,
        titleSpacing: 14,
        iconTheme: const IconThemeData(
          color: Colors.white, // back arrow colour
        ),
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 24),
          child: Center(
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Color(0xFF8AABB4)),
              style: IconButton.styleFrom(
                backgroundColor: const Color.fromRGBO(40, 58, 68, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.zero,
                minimumSize: const Size(36, 36),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            if (user != null)
              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  final avatarId =
                      snapshot.data?.data()?['avatarId'] as String?;
                  return Column(
                    children: [
                      GestureDetector(
                        onTap: _savingAvatar
                            ? null
                            : () => _chooseAvatar(user.uid, avatarId),
                        child: ProfileAvatar(
                          avatarId: avatarId,
                          name: displayName,
                          radius: 56,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _savingAvatar
                            ? null
                            : () => _chooseAvatar(user.uid, avatarId),
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: Text(
                          _savingAvatar ? 'Saving…' : 'Choose avatar',
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFF5DEB3),
                        ),
                      ),
                    ],
                  );
                },
              ),
            const SizedBox(height: 12),

            Text(
              displayName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              user?.email ?? "",
              style: const TextStyle(color: Colors.white70),
            ),

            const SizedBox(height: 30),

            // Watch Stats
            Row(
              children: [
                Expanded(child: _statCard("Movies Watched", "0", Icons.movie)),
                const SizedBox(width: 12),
                Expanded(child: _statCard("Episodes Watched", "0", Icons.tv)),
              ],
            ),

            const SizedBox(height: 30),

            // Account Section
            _sectionTitle("Account"),

            _settingTile(Icons.person_outline, "Edit Profile", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfilePage()),
              );
            }),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  static Widget _statCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(40, 58, 68, 1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFFD4622A)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  static Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  static Widget _settingTile(IconData icon, String title, VoidCallback onTap) {
    return Card(
      color: const Color.fromRGBO(40, 58, 68, 1),
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFD4622A)),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        trailing: const Icon(Icons.chevron_right, color: Colors.white54),
        onTap: onTap,
      ),
    );
  }
}

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final user = FirebaseAuth.instance.currentUser;

  late final TextEditingController _nameController;

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: user?.displayName ?? user?.email?.split('@').first ?? "",
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    try {
      await user?.updateDisplayName(_nameController.text.trim());
      await FirebaseAuth.instance.currentUser?.reload(); // ← add this

      if (_newPasswordController.text.isNotEmpty) {
        if (_newPasswordController.text != _confirmPasswordController.text) {
          throw Exception("Passwords do not match");
        }
        await user?.updatePassword(_newPasswordController.text);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(26, 41, 49, 1),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 24,
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: Container(
          margin: const EdgeInsets.only(left: 18, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(40, 58, 68, 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text("Display Name", style: TextStyle(color: Colors.white)),
          const SizedBox(height: 8),

          TextField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration(),
          ),

          const SizedBox(height: 24),

          const Text("Email", style: TextStyle(color: Colors.white)),
          const SizedBox(height: 8),

          TextField(
            enabled: false,
            controller: TextEditingController(text: user?.email ?? ""),
            decoration: _inputDecoration(),
          ),

          const SizedBox(height: 24),

          const Text(
            "Change Password",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          TextField(
            controller: _currentPasswordController,
            obscureText: true,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration(hint: "Current Password"),
          ),

          const SizedBox(height: 12),

          TextField(
            controller: _newPasswordController,
            obscureText: true,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration(hint: "New Password"),
          ),

          const SizedBox(height: 12),

          TextField(
            controller: _confirmPasswordController,
            obscureText: true,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration(hint: "Confirm Password"),
          ),

          const SizedBox(height: 30),

          ElevatedButton(
            onPressed: _saveChanges,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4622A),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text(
              "Save Changes",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: const Color.fromRGBO(40, 58, 68, 1),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
