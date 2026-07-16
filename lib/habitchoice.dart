import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'habit_tracker_screen.dart';

class HabitChoiceScreen extends StatelessWidget {
  HabitChoiceScreen({super.key});

  // ================= AUTHENTIC CBT-BASED HABITS =================

  final List<String> stressLow = const [
    "10–15 min light walk",
    "5 min box breathing (4-4-4-4)",
    "Reduce screen time before sleep",
  ];

  final List<String> stressModerate = const [
    "15–20 min brisk walk",
    "10 min guided mindfulness",
    "Limit caffeine after afternoon",
  ];

  final List<String> stressHigh = const [
    "Grounding technique (5-4-3-2-1)",
    "Progressive muscle relaxation",
    "Slow deep breathing (long exhale focus)",
  ];

  final List<String> depLow = const [
    "Morning sunlight exposure (10–20 min)",
    "Light physical activity",
    "Write 3 gratitude points",
  ];

  final List<String> depModerate = const [
    "20 min walk outside",
    "Talk to trusted person",
    "Emotion journaling (CBT method)",
  ];

  final List<String> depHigh = const [
    "Contact trusted person",
    "Structured routine task (small goal)",
    "Breathing + grounding exercise",
  ];

  // ================= GET HABITS =================

  List<String> getHabits(String disease, String severity) {
    if (disease == "Stress" && severity == "Low") return stressLow;
    if (disease == "Stress" && severity == "Moderate") return stressModerate;
    if (disease == "Stress" && severity == "High") return stressHigh;
    if (disease == "Depression" && severity == "Low") return depLow;
    if (disease == "Depression" && severity == "Moderate") return depModerate;
    if (disease == "Depression" && severity == "High") return depHigh;

    return stressLow;
  }

  // ================= CREATE PLAN =================

  Future<void> createPlan(
      BuildContext context,
      String disease,
      String severity,
      ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final firestore = FirebaseFirestore.instance;
    final habits = getHabits(disease, severity);

    Map<String, List<int>> progress = {
      for (int i = 0; i < 7; i++) "day$i": List.filled(habits.length, 0),
    };

    await firestore
        .collection('users')
        .doc(user.uid)
        .collection('habit_tracker')
        .doc('active_plan')
        .set({
      "disease": disease,
      "severity": severity,
      "habitNames": habits,
      "currentDay": 0,
      "progress": progress,
      "startDate": Timestamp.now(),
    });

    if (!context.mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const HabitTrackerScreen(),
      ),
    );
  }

  // ================= PLAN CARD (SMALL BUTTON STYLE) =================

  Widget buildPlanCard({
    required BuildContext context,
    required String disease,
    required String severity,
    required String emoji,
    required Color color1,
    required Color color2,
  }) {
    return GestureDetector(
      onTap: () => createPlan(context, disease, severity),

      child: Container(
        width: 120,
        height: 85,

        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color1, color2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: color1.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 6),
            Text(
              severity,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= SECTION (UPDATED LAYOUT) =================

  Widget buildSection({
    required BuildContext context,
    required String title,
    required String quote,
    required IconData icon,
    required Color iconColor,
    required List<Widget> cards,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 26),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10)
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [
              CircleAvatar(
                backgroundColor: iconColor.withOpacity(0.15),
                radius: 28,
                child: Icon(icon, color: iconColor, size: 30),
              ),
              const SizedBox(width: 14),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2A37),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Text(
            quote,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 15,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 22),

          // ================= NEW LAYOUT (NO OVERFLOW + BUTTON STYLE) =================
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  cards[0],
                  cards[1],
                ],
              ),
              const SizedBox(height: 14),
              Center(child: cards[2]),
            ],
          ),
        ],
      ),
    );
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF4F7FB),
        iconTheme: const IconThemeData(color: Color(0xFF1F2A37)),
        title: const Text(
          "Choose Your Plan ✨",
          style: TextStyle(
            color: Color(0xFF1F2A37),
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
      ),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),

          children: [

            // ================= HEADER (ONLY BLUE GRADIENT FIXED) =================

            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF2F80ED),
                    Color(0xFF1E5EFF),
                  ],
                ),
                borderRadius: BorderRadius.all(Radius.circular(24)),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    "🌿 Your Mental Wellness Journey",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Small healthy habits every day can create powerful positive changes in your mind and body 💙",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 18),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(16),
                    ),

                    child: const Row(
                      children: [
                        Icon(Icons.auto_awesome,
                            color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Healing begins with one small step ✨",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 22),

            // ================= DIAGNOSE LINE =================

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 6)
                ],
              ),

              child: const Row(
                children: [
                  Icon(Icons.psychology_alt_rounded,
                      color: Color(0xFF6A8DFF)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "If you don't know your condition, diagnose first using the AI chatbot 💡",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ================= STRESS =================

            buildSection(
              context: context,
              title: "Stress",
              icon: Icons.spa_rounded,
              iconColor: const Color(0xFF4A90E2),
              quote: "Take a deep breath 🌸 Calm your mind and reconnect with yourself.",
              cards: [
                buildPlanCard(
                  context: context,
                  disease: "Stress",
                  severity: "Low",
                  emoji: "🌱",
                  color1: const Color(0xFF56CCF2),
                  color2: const Color(0xFF2F80ED),
                ),
                buildPlanCard(
                  context: context,
                  disease: "Stress",
                  severity: "Moderate",
                  emoji: "🌤",
                  color1: const Color(0xFF43CEA2),
                  color2: const Color(0xFF185A9D),
                ),
                buildPlanCard(
                  context: context,
                  disease: "Stress",
                  severity: "High",
                  emoji: "🔥",
                  color1: const Color(0xFFFF9966),
                  color2: const Color(0xFFFF5E62),
                ),
              ],
            ),

            // ================= DEPRESSION =================

            buildSection(
              context: context,
              title: "Depression",
              icon: Icons.favorite_rounded,
              iconColor: const Color(0xFFFF7EB3),
              quote: "You are stronger than you think 💖 One small step every day matters.",
              cards: [
                buildPlanCard(
                  context: context,
                  disease: "Depression",
                  severity: "Low",
                  emoji: "🌸",
                  color1: const Color(0xFFFF9A9E),
                  color2: const Color(0xFFFAD0C4),
                ),
                buildPlanCard(
                  context: context,
                  disease: "Depression",
                  severity: "Moderate",
                  emoji: "💙",
                  color1: const Color(0xFFA18CD1),
                  color2: const Color(0xFFFBC2EB),
                ),
                buildPlanCard(
                  context: context,
                  disease: "Depression",
                  severity: "High",
                  emoji: "🌈",
                  color1: const Color(0xFF667EEA),
                  color2: const Color(0xFF764BA2),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}