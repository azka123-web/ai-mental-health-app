import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class RewardScreen extends StatefulWidget {
  final String disease;
  final String severity;

  final List<List<int>> weeklyHabits;
  final List<String> habitNames;

  const RewardScreen({
    super.key,
    required this.disease,
    required this.severity,
    required this.weeklyHabits,
    required this.habitNames,
  });

  @override
  State<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen> {
  bool loading = false;

  final user = FirebaseAuth.instance.currentUser;

  // ================= SCORE =================

  int calculateScore() {
    int score = 0;

    for (var day in widget.weeklyHabits) {
      for (var h in day) {
        if (h == 1) score++;
      }
    }

    return score;
  }

  // ================= PERCENT =================

  double calculatePercent() {
    int total =
        widget.weeklyHabits.length * widget.habitNames.length;

    if (total == 0) return 0;

    return calculateScore() / total;
  }

  // ================= BADGE =================

  String getBadge() {
    double percent = calculatePercent();

    if (percent >= 0.9) {
      return "🏆 Gold Wellness Champion";
    }

    if (percent >= 0.7) {
      return "🥈 Silver Consistency Star";
    }

    if (percent >= 0.5) {
      return "🥉 Bronze Progress Builder";
    }

    return "🌱 New Beginning Badge";
  }

  // ================= SAVE =================

  Future<void> claimReward() async {
    setState(() => loading = true);

    try {
      if (user == null) return;

      final firestore = FirebaseFirestore.instance;

      final score = calculateScore();

      final safeWeeklyHabits = widget.weeklyHabits
          .map((e) => {"habits": e})
          .toList();

      await firestore
          .collection('users')
          .doc(user!.uid)
          .collection('habit_rewards')
          .add({
        "disease": widget.disease,
        "severity": widget.severity,
        "score": score,
        "completionPercent":
        (calculatePercent() * 100).toInt(),
        "habitNames": widget.habitNames,
        "weeklyHabits": safeWeeklyHabits,
        "badge": getBadge(),
        "completedAt": Timestamp.now(),
      });

      await firestore
          .collection('users')
          .doc(user!.uid)
          .collection('habit_tracker')
          .doc('active_plan')
          .delete();

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),

          title: const Text(
            "Reward Saved 🎉",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          content: const Text(
            "Your progress history and weekly report have been saved successfully 💙",
          ),

          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B8CFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              onPressed: () {
                Navigator.pop(context);

                Navigator.popUntil(
                  context,
                      (route) => route.isFirst,
                );
              },

              child: const Text(
                "Continue",
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
      );
    } catch (e) {
      debugPrint(e.toString());
    }

    setState(() => loading = false);
  }

  // ================= DAY PERCENT =================

  double getDayPercent(int day) {
    final habits = widget.weeklyHabits[day];

    int done = habits.where((e) => e == 1).length;

    return done / habits.length;
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    final score = calculateScore();

    final percent = calculatePercent();

    final bool isSuccessful = percent >= 0.5;

    final name = user?.displayName ?? "User";

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF5B8CFF),

        iconTheme: const IconThemeData(
          color: Colors.white,
        ),

        title: const Text(
          "Your Reward 🎉",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: loading
          ? const Center(
        child: CircularProgressIndicator(),
      )

          : SingleChildScrollView(
        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ================= RESULT CARD =================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),

              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isSuccessful
                      ? [
                    const Color(0xFF6C63FF),
                    const Color(0xFF5B8CFF),
                  ]
                      : [
                    const Color(0xFFFF8A65),
                    const Color(0xFFFF7043),
                  ],
                ),

                borderRadius: BorderRadius.circular(28),

                boxShadow: [
                  BoxShadow(
                    color: (isSuccessful
                        ? Colors.blue
                        : Colors.deepOrange)
                        .withOpacity(0.25),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  )
                ],
              ),

              child: Column(
                children: [

                  Icon(
                    isSuccessful
                        ? Icons.workspace_premium_rounded
                        : Icons.warning_amber_rounded,
                    color: isSuccessful
                        ? Colors.amber
                        : Colors.white,
                    size: 90,
                  ),

                  const SizedBox(height: 18),

                  Text(
                    isSuccessful
                        ? "Congratulations, $name 🎉"
                        : "Recovery Plan Incomplete ⚠️",
                    textAlign: TextAlign.center,

                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    isSuccessful
                        ? "You successfully completed your ${widget.severity} ${widget.disease} recovery plan 💙"
                        : "Your weekly progress is below 50%.\n\nIf you do not follow this recovery plan regularly, your symptoms may continue or become harder to manage.\n\nPlease follow this plan again consistently to improve your condition 💙\n\nIf your symptoms still do not improve even after following the plan properly, you should consult a psychiatrist or mental health professional.",
                    textAlign: TextAlign.center,

                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 24),

                  if (isSuccessful)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),

                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(18),
                      ),

                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          const Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                          ),

                          const SizedBox(width: 10),

                          Text(
                            getBadge(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ================= STATS =================

            Row(
              children: [

                Expanded(
                  child: statCard(
                    title: "Score",
                    value: "$score",
                    icon:
                    Icons.local_fire_department_rounded,
                    color: const Color(0xFFFF7A59),
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: statCard(
                    title: "Completion",
                    value:
                    "${(percent * 100).toInt()}%",
                    icon: Icons.check_circle_rounded,
                    color: const Color(0xFF22C55E),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 26),

            // ================= GRAPH =================

            const Text(
              "Weekly Progress",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),

                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                  )
                ],
              ),

              child: SizedBox(
                height: 250,

                child: BarChart(
                  BarChartData(
                    maxY: 100,

                    gridData: FlGridData(show: false),

                    borderData:
                    FlBorderData(show: false),

                    titlesData: FlTitlesData(

                      topTitles: AxisTitles(
                        sideTitles:
                        SideTitles(showTitles: false),
                      ),

                      rightTitles: AxisTitles(
                        sideTitles:
                        SideTitles(showTitles: false),
                      ),

                      leftTitles: AxisTitles(
                        sideTitles:
                        SideTitles(showTitles: false),
                      ),

                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,

                          getTitlesWidget:
                              (value, meta) {
                            return Padding(
                              padding:
                              const EdgeInsets.only(
                                top: 8,
                              ),

                              child: Text(
                                "Day ${value.toInt() + 1}",
                                style: const TextStyle(
                                  fontWeight:
                                  FontWeight.w600,
                                  fontSize: 11,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    barGroups: List.generate(
                      7,
                          (i) {
                        return BarChartGroupData(
                          x: i,

                          barRods: [
                            BarChartRodData(
                              toY:
                              getDayPercent(i) *
                                  100,

                              width: 18,

                              borderRadius:
                              BorderRadius.circular(
                                  8),

                              gradient:
                              const LinearGradient(
                                colors: [
                                  Color(0xFF6C63FF),
                                  Color(0xFF5B8CFF),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ================= HABIT HISTORY =================

            const Text(
              "Habit History",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            Column(
              children: List.generate(
                widget.habitNames.length,
                    (i) {

                  int completed = widget.weeklyHabits
                      .where((e) => e[i] == 1)
                      .length;

                  return Container(
                    margin:
                    const EdgeInsets.only(bottom: 14),

                    padding: const EdgeInsets.all(18),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.circular(22),

                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                        )
                      ],
                    ),

                    child: Row(
                      children: [

                        Container(
                          height: 54,
                          width: 54,

                          decoration: BoxDecoration(
                            color:
                            const Color(0xFFE0E7FF),
                            borderRadius:
                            BorderRadius.circular(
                                16),
                          ),

                          child: const Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFF5B8CFF),
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                            children: [

                              Text(
                                widget.habitNames[i],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                  FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                "Completed on $completed out of 7 days",
                                style: const TextStyle(
                                  color:
                                  Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 28),

            // ================= BUTTON =================

            SizedBox(
              width: double.infinity,
              height: 58,

              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(0xFF5B8CFF),

                  elevation: 8,

                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(18),
                  ),
                ),

                onPressed: claimReward,

                icon: const Icon(
                  Icons.card_giftcard_rounded,
                  color: Colors.white,
                ),

                label: const Text(
                  "Save Progress",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ================= STAT CARD =================

  Widget statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),

        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
          )
        ],
      ),

      child: Column(
        children: [

          Container(
            padding: const EdgeInsets.all(12),

            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),

            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            title,
            style: const TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}