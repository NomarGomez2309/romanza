import 'package:flutter/material.dart';
import 'package:romanza/features/auth/presentation/login_screen.dart';

class CharacterScreen extends StatefulWidget {
  const CharacterScreen({super.key});

  @override
  State<CharacterScreen> createState() => _CharacterScreenState();
}

class _CharacterScreenState extends State<CharacterScreen> {

  int currentCharacter = 0;

  final List<String> characters = [

    "no se",
    "retro",
    "clasic",

  ];

  void nextCharacter() {

    setState(() {

      currentCharacter =
          (currentCharacter + 1) % characters.length;

    });
  }

  void previousCharacter() {

    setState(() {

      currentCharacter =
          (currentCharacter - 1 + characters.length)
              % characters.length;

    });
  }

  void continueToLogin() {

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            const Text(
              "Choose Your Character 🎮",
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            // CHARACTER PREVIEW
            Container(
              width: 220,
              height: 220,

              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(20),
              ),

              child: Center(
                child: Image.asset(
                  characters[currentCharacter],
                  width: 120,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // CONTROLS
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,

              children: [

                IconButton(
                  onPressed: previousCharacter,

                  icon: const Icon(
                    Icons.arrow_left,
                    size: 40,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(width: 30),

                IconButton(
                  onPressed: nextCharacter,

                  icon: const Icon(
                    Icons.arrow_right,
                    size: 40,
                    color: Colors.white,
                  ),
                ),

              ],
            ),

            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: continueToLogin,

              child: const Text("Continue"),
            ),

          ],
        ),
      ),
    );
  }
}