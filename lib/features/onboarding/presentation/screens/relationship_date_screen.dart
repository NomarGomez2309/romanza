import 'package:flutter/material.dart';
import 'character_screen.dart';

class RelationshipDateScreen extends StatefulWidget {
  const RelationshipDateScreen({super.key});

  @override
  State<RelationshipDateScreen> createState() =>
      _RelationshipDateScreenState();
}

class _RelationshipDateScreenState
    extends State<RelationshipDateScreen> {

  DateTime? selectedDate;

  Future<void> pickDate() async {

    final picked = await showDatePicker(
      context: context,

      initialDate: DateTime.now(),

      firstDate: DateTime(2000),

      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void continueToCharacterScreen() {

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CharacterScreen(),
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
              "When did your story begin? 💑",
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: pickDate,

              child: Text(
                selectedDate == null
                    ? "Select Date"
                    : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed:
                  selectedDate == null
                      ? null
                      : continueToCharacterScreen,

              child: const Text("Continue"),
            ),

          ],
        ),
      ),
    );
  }
}