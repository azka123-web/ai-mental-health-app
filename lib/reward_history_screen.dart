import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RewardHistoryScreen extends StatefulWidget {
  const RewardHistoryScreen({super.key});

  @override
  State<RewardHistoryScreen> createState() =>
      _RewardHistoryScreenState();
}

class _RewardHistoryScreenState
    extends State<RewardHistoryScreen> {

  final firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  bool loading = true;

  List<QueryDocumentSnapshot> rewards = [];

  @override
  void initState() {
    super.initState();
    loadRewards();
  }

  // ================= LOAD REWARDS =================

  Future<void> loadRewards() async {

    final user = auth.currentUser;

    if (user == null) {
      setState(() => loading = false);
      return;
    }

    try {

      final snapshot = await firestore
          .collection('users')
          .doc(user.uid)
          .collection('habit_rewards')
          .orderBy('completedAt', descending: true)
          .get();

      rewards = snapshot.docs;

    } catch (e) {
      debugPrint("Reward History Error: $e");
    }

    setState(() => loading = false);
  }

  // ================= PARSE WEEKLY =================

  List<List<int>> parseWeekly(dynamic data) {

    try {

      return List<List<int>>.from(
        (data as List).map(
              (e) => List<int>.from(e['habits']),
        ),
      );

    } catch (e) {

      return List.generate(
        7,
            (_) => List.filled(3, 0),
      );
    }
  }

  // ================= TOTAL COMPLETED =================

  int totalCompleted(List<List<int>> weeklyHabits) {

    int count = 0;

    for (var day in weeklyHabits) {
      for (var h in day) {
        if (h == 1) count++;
      }
    }

    return count;
  }

  // ================= TOTAL HABITS =================

  int totalHabits(List<List<int>> weeklyHabits) {

    int count = 0;

    for (var day in weeklyHabits) {
      count += day.length;
    }

    return count;
  }

  // ================= BADGE =================

  String getBadge(int completed, int total) {

    double percent = completed / total;

    if (percent >= 0.9) {
      return "🏆 Gold Consistency";
    }

    if (percent >= 0.7) {
      return "🥈 Silver Progress";
    }

    if (percent >= 0.5) {
      return "🥉 Bronze Effort";
    }

    return "⚠️ Plan Incomplete";
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFFF5F7FF),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF5B8CFF),
        centerTitle: true,

        iconTheme: const IconThemeData(
          color: Colors.white,
        ),

        title: const Text(
          "Saved Rewards 🎁",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),

      body: loading

          ? const Center(
        child: CircularProgressIndicator(),
      )

          : rewards.isEmpty

          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Icon(
              Icons.emoji_events_outlined,
              size: 90,
              color: Colors.grey.shade400,
            ),

            const SizedBox(height: 20),

            const Text(
              "No rewards yet 🎁",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              "Complete your 7-day journey to earn rewards",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      )

          : ListView.builder(

        padding: const EdgeInsets.all(18),

        itemCount: rewards.length,

        itemBuilder: (context, index) {

          final data =
          rewards[index].data()
          as Map<String, dynamic>;

          final weeklyHabits =
          parseWeekly(data['weeklyHabits']);

          final habits =
          List<String>.from(
            data['habitNames'] ?? [],
          );

          final completed =
          totalCompleted(weeklyHabits);

          final total =
          totalHabits(weeklyHabits);

          final badge =
          getBadge(completed, total);

          final percent = completed / total;

          final bool isSuccessful = percent >= 0.5;

          Timestamp? timestamp =
          data['completedAt'];

          String date = "";

          if (timestamp != null) {

            final d = timestamp.toDate();

            date =
            "${d.day}/${d.month}/${d.year}";
          }

          return Container(

            margin: const EdgeInsets.only(bottom: 22),

            decoration: BoxDecoration(

              borderRadius:
              BorderRadius.circular(30),

              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFFFFF),
                  Color(0xFFF8FBFF),
                ],
              ),

              boxShadow: [

                BoxShadow(
                  color: Colors.blue.withOpacity(0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),

            child: Padding(
              padding: const EdgeInsets.all(22),

              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  // ================= TOP =================

                  Row(
                    children: [

                      Container(
                        height: 68,
                        width: 68,

                        decoration: BoxDecoration(
                          shape: BoxShape.circle,

                          gradient: LinearGradient(
                            colors: isSuccessful
                                ? [
                              const Color(0xFF5B8CFF),
                              const Color(0xFF6C63FF),
                            ]
                                : [
                              const Color(0xFFFF8A65),
                              const Color(0xFFFF7043),
                            ],
                          ),
                        ),

                        child: Icon(
                          isSuccessful
                              ? Icons.workspace_premium
                              : Icons.warning_amber_rounded,
                          color: Colors.white,
                          size: 34,
                        ),
                      ),

                      const SizedBox(width: 16),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,

                          children: [

                            Text(
                              "${data['disease']} • ${data['severity']}",
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight:
                                FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              "Completed on $date",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // ================= MESSAGE =================

                  Container(
                    padding: const EdgeInsets.all(16),

                    decoration: BoxDecoration(
                      borderRadius:
                      BorderRadius.circular(20),

                      color: isSuccessful
                          ? const Color(0xFFEFF6FF)
                          : const Color(0xFFFFF7ED),
                    ),

                    child: Row(
                      children: [

                        Icon(
                          isSuccessful
                              ? Icons.favorite
                              : Icons.warning_amber_rounded,
                          color: isSuccessful
                              ? const Color(0xFFEC4899)
                              : Colors.deepOrange,
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Text(
                            isSuccessful
                                ? "Every small healthy step matters 💙"
                                : "Your progress was below 50%. Follow the recovery plan more consistently to reduce symptoms and improve your condition.",
                            style: const TextStyle(
                              fontWeight:
                              FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // ================= PROGRESS =================

                  Row(
                    children: [

                      Expanded(
                        child: buildInfoCard(
                          title: "Progress",
                          value: "$completed/$total",
                          icon: Icons.show_chart,
                          color:
                          const Color(0xFF22C55E),
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: buildInfoCard(
                          title: "Badge",
                          value: badge,
                          icon: Icons.emoji_events,
                          color:
                          const Color(0xFFF59E0B),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ================= HABITS =================

                  const Text(
                    "Habit History",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),

                  const SizedBox(height: 14),

                  Column(
                    children: List.generate(
                      habits.length,
                          (i) {

                        int completedDays =
                            weeklyHabits
                                .where((day) =>
                            i < day.length &&
                                day[i] == 1)
                                .length;

                        return Container(

                          margin:
                          const EdgeInsets.only(
                            bottom: 12,
                          ),

                          padding:
                          const EdgeInsets.all(16),

                          decoration: BoxDecoration(

                            color: Colors.white,

                            borderRadius:
                            BorderRadius.circular(
                                20),

                            border: Border.all(
                              color: Colors.grey
                                  .shade200,
                            ),
                          ),

                          child: Row(
                            children: [

                              Container(
                                height: 48,
                                width: 48,

                                decoration:
                                BoxDecoration(
                                  color: completedDays >= 4
                                      ? const Color(0xFFDCFCE7)
                                      : const Color(0xFFFFEDD5),
                                  shape:
                                  BoxShape.circle,
                                ),

                                child: Icon(
                                  completedDays >= 4
                                      ? Icons.check_circle
                                      : Icons.warning_amber_rounded,
                                  color: completedDays >= 4
                                      ? const Color(0xFF22C55E)
                                      : Colors.deepOrange,
                                ),
                              ),

                              const SizedBox(width: 14),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,

                                  children: [

                                    Text(
                                      habits[i],
                                      style:
                                      const TextStyle(
                                        fontWeight:
                                        FontWeight
                                            .w600,
                                        fontSize: 15,
                                      ),
                                    ),

                                    const SizedBox(
                                        height: 4),

                                    Text(
                                      "$completedDays / 7 days completed",
                                      style: TextStyle(
                                        color: Colors
                                            .grey
                                            .shade600,
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ================= INFO CARD =================

  Widget buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {

    return Container(

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),

        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 12,
          )
        ],
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          Container(
            padding: const EdgeInsets.all(10),

            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius:
              BorderRadius.circular(14),
            ),

            child: Icon(
              icon,
              color: color,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}