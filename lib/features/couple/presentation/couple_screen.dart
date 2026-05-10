import 'package:flutter/material.dart';
import '../../../services/couple_service.dart';

class CoupleScreen extends StatefulWidget {
  const CoupleScreen({super.key});

  @override
  State<CoupleScreen> createState() => _CoupleScreenState();
}

class _CoupleScreenState extends State<CoupleScreen> {
  final CoupleService _service = CoupleService();
  final TextEditingController codeController = TextEditingController();

  String? inviteCode;
  String? inviteLink;
  bool isConnected = false;

  void createCouple() async {
    final couple = await _service.createCouple();

    if (couple != null) {
      setState(() {
        inviteCode = couple.inviteCode;
        inviteLink = couple.inviteLink;
      });
    }
  }

  void joinCouple() async {
    final success = await _service.joinCouple(codeController.text);

    setState(() {
      isConnected = success;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? "Conectado ❤️" : "Código inválido"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Couple 💑")),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // 🔥 CREATE COUPLE
            ElevatedButton(
              onPressed: createCouple,
              child: const Text("Crear pareja"),
            ),

            const SizedBox(height: 20),

            if (inviteCode != null) ...[
              Text("Código: $inviteCode"),
              const SizedBox(height: 5),
              Text("Link: $inviteLink"),
            ],

            const Divider(height: 40),

            // 🔗 JOIN COUPLE
            TextField(
              controller: codeController,
              decoration: const InputDecoration(
                labelText: "Código de pareja",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: joinCouple,
              child: const Text("Unirse"),
            ),

            const SizedBox(height: 30),

            // ❤️ STATUS
            Text(
              isConnected ? "Estado: Conectado ❤️" : "Estado: Sin pareja",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}