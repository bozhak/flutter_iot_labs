import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final String username;
  final String email;

  const ProfilePage({required this.username, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile'), backgroundColor: Color(0xFF3B62FF)),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(radius: 50, backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=3')),
            SizedBox(height: 16),
            Text(username, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(email, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
            SizedBox(height: 16),
            Text(
              'Flutter enthusiast. Loves building beautiful and clean mobile apps.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
