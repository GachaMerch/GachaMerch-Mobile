import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'LoginPage.dart';
import 'services/auth_service.dart';

class HomePage extends StatelessWidget {
  final Map<String, dynamic> user;

  const HomePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1F1F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F1F1F),
        title: const Text(
          'GachaMerch',
          style: TextStyle(color: Colors.white, fontFamily: 'Alexandria'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await AuthService.logout();
              await GoogleSignIn().signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (_) => false,
                );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (user['avatar'] != null)
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(user['avatar']),
              ),
            const SizedBox(height: 16),
            Text(
              'Welcome, ${user['username'] ?? user['email']}!',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontFamily: 'Alexandria',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              user['email'] ?? '',
              style: const TextStyle(
                color: Color(0xFF88888A),
                fontSize: 14,
                fontFamily: 'Alexandria',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
