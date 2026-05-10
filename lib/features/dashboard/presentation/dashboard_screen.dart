import 'package:flutter/material.dart';
import '../../couple/presentation/couple_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(91, 126, 60, 100),

      appBar: AppBar(
        title: const Text(
         "Dashboard",
         style: TextStyle(
         color: Colors.white,
         fontSize: 24,
       ),
      ),
      backgroundColor: Color.fromRGBO(162, 203, 139, 1.0),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [

            // 💑 COUPLE BUTTON
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CoupleScreen(),
                  ),
                );
              },
              child: Image.asset(
                "assets/images/Couple.png",
                  width: 200,
              ),
            ),

            // 📅 DAYS
            Image.asset(
                 "assets/images/Calendar.png",
                  width: 200,
              ),

            // 🎵 MUSIC
            Image.asset(
                 "assets/images/Spotify.png",
                  width: 200,
              ),

            // 📸 ALBUM
            Image.asset(
                 "assets/images/Album.png",
                  width: 200,
              ),
          ],
        ),
      ),
    );
  }
}