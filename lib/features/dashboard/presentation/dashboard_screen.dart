import 'package:flutter/material.dart';
import '../widgets/modules/couple_module.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE2F4ED),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),

          child: Column(
            children: [

              // =========================
              // APP BAR
              // =========================

              Container(
                height: 50,
                width: double.infinity,
                color: Colors.grey,
              ),

              const SizedBox(height: 24),

              // =========================
              // MAIN CONTAINER (DAYS)
              // =========================

              Container(
                height: 170,
                width: double.infinity,
                color: Colors.grey,
              ),

              const SizedBox(height: 24),

              // =========================
              // MODULE SECTION
              // =========================

              Expanded(
                child: Row(
                  children: [

                    // =========================
                    // LEFT COLUMN
                    // =========================

                    Expanded(
                      child: Column(
                        children: [

                          // CONNECT
                          Container(
                            height: 70,
                            color: Colors.green,
                          ),

                          const SizedBox(height: 24),

                          // MUSIC
                          Container(
                            height: 170,
                            color: Colors.grey,
                          ),

                          const SizedBox(height: 24),

                          // CALENDAR
                          Container(
                            height: 150,
                            color: Colors.blueGrey,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 24),

                    // =========================
                    // RIGHT COLUMN
                    // =========================

                    Expanded(
                      child: Column(
                        children: [

                          // LIST
                          Container(
                            height: 150,
                            color: Colors.amber,
                          ),

                          const SizedBox(height: 24),

                          // WEDDING
                          Container(
                            height: 170,
                            color: Colors.greenAccent,
                          ),

                          const SizedBox(height: 24),

                          // MOVIES
                          Container(
                            height: 150,
                            color: Colors.teal,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}