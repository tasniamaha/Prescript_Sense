import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 60),
            ),
            const SizedBox(height: 20),
            const Text(
              'Noshin Syara',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text('noshinsyara@iut-dhaka.edu.com'),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Edit profile placeholder
              },
              child: const Text('Edit Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
