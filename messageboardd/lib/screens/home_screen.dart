import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';
import '../servicestuff/auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  final List<Map<String, dynamic>> boards = const [
    {'id': 'general', 'name': 'General Chat', 'icon': Icons.chat},
    {'id': 'school', 'name': 'School Talk', 'icon': Icons.school},
    {'id': 'random', 'name': 'Random', 'icon': Icons.coffee},
  ];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Message Boards'),
      ),
      drawer: _buildDrawer(context),
      body: ListView.builder(
        itemCount: boards.length,
        itemBuilder: (context, index) {
          final board = boards[index];
          return ListTile(
            leading: Icon(board['icon'] as IconData),
            title: Text(board['name'] as String),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    boardId: board['id'] as String,
                    boardName: board['name'] as String,
                    displayName: user?.email ?? 'Unknown',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    final authService = AuthService();
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          ListTile(
            leading: const Icon(Icons.message),
            title: const Text('Message Boards'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/home');
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/profile');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/settings');
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              await authService.logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                    (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
