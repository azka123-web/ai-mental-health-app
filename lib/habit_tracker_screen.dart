import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'reward_screen.dart';
import 'notification_service.dart';

class HabitTrackerScreen extends StatefulWidget {
  const HabitTrackerScreen({super.key});

  @override
  State<HabitTrackerScreen> createState() => _State();
}

class _State extends State<HabitTrackerScreen> {
  final user = FirebaseAuth.instance.currentUser!;
  final firestore = FirebaseFirestore.instance;

  bool loading = true;
  bool notificationsScheduled = false;

  List<String> habits = [];

  // -1 = Nothing Selected
  // 0 = Not Done
  // 1 = Done
  Map<String, List<int>> progressMap = {};

  int currentDay = 0;
  String disease = "";
  String severity = "";

  @override
  void initState() {
    super.initState();
    load();
  }

  // ================= POPUP =================

  void showPopup(String message) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Popup",
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) => const SizedBox(),
      transitionBuilder: (context, animation, secondary, child) {
        return Transform.scale(
          scale: Curves.easeOutBack.transform(animation.value),
          child: Opacity(
            opacity: animation.value,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              backgroundColor: Colors.white,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 80,
                    width: 80,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFDCFCE7),
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF22C55E),
                      size: 50,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Progress Saved",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5B8CFF),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        "Continue",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ================= STRESS LOW =================

  final List<List<String>> stressLow = List.generate(
    7,
        (_) => [
      "10 min slow relaxing walk in a quiet place (7:00 AM)",

      "5 min box breathing: inhale 4 sec → hold 4 sec → exhale 4 sec calmly while sitting comfortably (8:30 PM)",

      "Write 3 things that made you stressed today and one small solution for each (9:15 PM)",
    ],
  );

  // ================= STRESS MODERATE =================

  final List<List<String>> stressModerate = List.generate(
    7,
        (_) => [
      "10 min guided meditation: sit quietly, close eyes, and listen to a calming audio (7:00 AM)",

      "15 min stretching routine: slowly move neck, move arms up and try to touch toe, stretch legs slowly without rushing (6:30 PM)",

      "5-4-3-2-1 grounding exercise: notice 5 things you see, 4 touch, 3 hear, 2 smell, and 1 taste to calm anxiety (9:00 PM)",
    ],
  );

  // ================= STRESS HIGH =================

  final List<List<String>> stressHigh = List.generate(
    7,
        (_) => [
      "5-4-3-2-1 grounding exercise: focus on surroundings to reduce panic and bring attention to present moment (7:00 AM)",

      "15 min muscle relaxation: tighten body muscles for few seconds then slowly relax them one by one (8:00 PM)",

      "10 min calming breathing: inhale slowly through nose and exhale slowly while sitting in quiet place (9:30 PM)",
    ],
  );

  // ================= DEPRESSION LOW =================

  final List<List<String>> depLow = List.generate(
    7,
        (_) => [
      "Complete one small productive task like organizing desk, folding clothes, or cleaning small area (6:00 PM)",

      "15 min brisk walk: walk slightly faster than normal pace to improve mood and energy (7:00 AM)",

      "Write one positive thing you did today and one goal for tomorrow (9:00 PM)",
    ],
  );

  // ================= DEPRESSION MODERATE =================

  final List<List<String>> depModerate = List.generate(
    7,
        (_) => [
      "20 min morning walk in fresh air to improve mood and body activation (7:00 AM)",

      "10 min sunlight + breathing exercise: sit in sunlight and slowly inhale/exhale deeply to relax mind (8:00 AM)",

      "Write 3 feelings you experienced today and what caused them (8:45 PM)",
    ],
  );

  // ================= DEPRESSION HIGH =================

  final List<List<String>> depHigh = List.generate(
    7,
        (_) => [
      "10 min light stretching: gently move neck, shoulders, arms, and legs to reduce heaviness in body (7:00 AM)",

      "Sit quietly in fresh air or sunlight for 10 mins while breathing slowly and calmly (5:30 PM)",

      "Calming breathing before sleep: inhale slowly for 4 sec and exhale slowly for 6 sec repeatedly (10:00 PM)",
    ],
  );

  // ================= GET HABITS =================

  List<String> getHabits() {
    final d = disease.toLowerCase().trim();
    final s = severity.toLowerCase().trim();

    if (d == "stress") {
      if (s == "low") return stressLow[currentDay];
      if (s == "moderate") return stressModerate[currentDay];
      return stressHigh[currentDay];
    }

    if (d == "depression") {
      if (s == "low") return depLow[currentDay];
      if (s == "moderate") return depModerate[currentDay];
      return depHigh[currentDay];
    }

    return [];
  }

  // ================= LOAD =================

  Future<void> load() async {
    try {
      final doc = await firestore
          .collection('users')
          .doc(user.uid)
          .collection('habit_tracker')
          .doc('active_plan')
          .get();

      if (!doc.exists) {
        setState(() => loading = false);
        debugPrint("DOC DOES NOT EXIST");
        return;
      }

      final data = doc.data() ?? {};

      // normalize strings (VERY IMPORTANT FIX)
      disease = (data['disease'] ?? "").toString().trim();
      severity = (data['severity'] ?? "").toString().trim();
      currentDay = (data['currentDay'] ?? 0).clamp(0, 6);

      debugPrint("DISEASE: '$disease'");
      debugPrint("SEVERITY: '$severity'");
      debugPrint("DAY: $currentDay");

      // get habits
      habits = getHabits();

      debugPrint("HABITS COUNT: ${habits.length}");

      setState(() {
        loading = false;
      });

      // IMPORTANT: schedule AFTER data is ready
      if (habits.isNotEmpty) {
        await scheduleHabitNotifications();
        debugPrint("NOTIFICATIONS SCHEDULED");
      } else {
        debugPrint("NO HABITS FOUND → NOT SCHEDULING");
      }

    } catch (e) {
      debugPrint("LOAD ERROR: $e");
      setState(() => loading = false);
    }
  }
  // ================= SET STATUS =================

  void setStatus(int index, int value) {
    final key = "day$currentDay";

    setState(() {
      progressMap.putIfAbsent(
        key,
            () => List.filled(habits.length, -1),
      );

      progressMap[key]![index] = value;
    });
  }

  // ================= SCHEDULE NOTIFICATIONS =================

  Future<void> scheduleHabitNotifications() async {

    await NotificationService.cancelAllNotifications();

    for (int i = 0; i < habits.length; i++) {

      final habit = habits[i];

      final regex = RegExp(r'\((.*?)\)');
      final match = regex.firstMatch(habit);

      if (match == null) continue;

      final timeString = match.group(1)!;

      try {

        final parts = timeString.split(" ");

        final timeParts = parts[0].split(":");

        int hour = int.parse(timeParts[0]);
        int minute = int.parse(timeParts[1]);

        final period = parts[1];

        if (period == "PM" && hour != 12) {
          hour += 12;
        }

        if (period == "AM" && hour == 12) {
          hour = 0;
        }

        await NotificationService.scheduleNotification(
          id: i,
          title: "Habit Reminder 💙",
          body: habit,
          hour: hour,
          minute: minute,
        );

      } catch (e) {
        debugPrint("Notification Parse Error: $e");
      }
    }
  }

  // ================= SAVE =================

  Future<void> save() async {

    final key = "day$currentDay";

    bool hasUnselected = progressMap[key]!.contains(-1);

    if (hasUnselected) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: const Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Selection Required",
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            content: const Text(
              "Please choose Done or Not Done for all habits before saving progress.",
              style: TextStyle(height: 1.4),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "OK",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        },
      );
      return;
    }

    await firestore
        .collection('users')
        .doc(user.uid)
        .collection('habit_tracker')
        .doc('active_plan')
        .update({
      "progress": progressMap,
    });

    final int oldDay = currentDay;

    if (currentDay >= 6) {

      List<List<int>> weeklyHabits = [];

      for (int i = 0; i < 7; i++) {
        weeklyHabits.add(
          progressMap["day$i"] ?? List.filled(habits.length, -1),
        );
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RewardScreen(
            disease: disease,
            severity: severity,
            habitNames: habits,
            weeklyHabits: weeklyHabits,
          ),
        ),
      );

      return;
    }

    currentDay++;

    await firestore
        .collection('users')
        .doc(user.uid)
        .collection('habit_tracker')
        .doc('active_plan')
        .update({
      "currentDay": currentDay,
    });

    showPopup("Day ${oldDay + 1} completed successfully ✅");

    await load();
  }
  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final key = "day$currentDay";

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF5F7FF),
        foregroundColor: Colors.black,
        centerTitle: true,
        title: Text(
          "Day ${currentDay + 1}",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: Column(
        children: [
          // ================= TOP CARD =================
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 18),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF6C63FF),
                  Color(0xFF5B8CFF),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.track_changes_rounded,
                  color: Colors.white,
                  size: 40,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$disease • $severity",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      "Improve your wellness 💙",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ================= HABIT LIST =================
          Expanded(
            child: ListView.builder(
              itemCount: habits.length,
              itemBuilder: (context, i) {
                int status = progressMap[key]?[i] ?? -1;

                Color borderColor = Colors.grey.shade200;
                if (status == 1) {
                  borderColor = const Color(0xFF22C55E);
                } else if (status == 0) {
                  borderColor = const Color(0xFFE11D48);
                }

                Color iconBg = Colors.grey.shade100;
                if (status == 1) {
                  iconBg = const Color(0xFFDCFCE7);
                } else if (status == 0) {
                  iconBg = const Color(0xFFFFF1F2);
                }

                Color iconColor = Colors.grey;
                if (status == 1) {
                  iconColor = const Color(0xFF22C55E);
                } else if (status == 0) {
                  iconColor = const Color(0xFFE11D48);
                }

                IconData statusIcon = Icons.radio_button_unchecked;
                if (status == 1) {
                  statusIcon = Icons.check_circle_rounded;
                } else if (status == 0) {
                  statusIcon = Icons.close_rounded;
                }

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: borderColor,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: iconBg,
                            ),
                            child: Icon(
                              statusIcon,
                              color: iconColor,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              habits[i],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      Row(
                        children: [
                          // DONE BUTTON
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: ElevatedButton.icon(
                                onPressed: () => setStatus(i, 1),
                                icon: const Icon(Icons.check),
                                label: const Text("Done"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: status == 1
                                      ? const Color(0xFF22C55E)
                                      : Colors.white,
                                  foregroundColor: status == 1
                                      ? Colors.white
                                      : const Color(0xFF22C55E),
                                  elevation: status == 1 ? 0 : 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: const BorderSide(
                                      color: Color(0xFF22C55E),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // NOT DONE BUTTON
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: ElevatedButton.icon(
                                onPressed: () => setStatus(i, 0),
                                icon: const Icon(Icons.close),
                                label: const Text("Not Done"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: status == 0
                                      ? const Color(0xFFE11D48)
                                      : Colors.white,
                                  foregroundColor: status == 0
                                      ? Colors.white
                                      : const Color(0xFFE11D48),
                                  elevation: status == 0 ? 0 : 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: BorderSide(
                                      color: status == 0
                                          ? const Color(0xFFE11D48)
                                          : Colors.grey.shade300,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // ================= SAVE BUTTON =================
          Padding(
            padding: const EdgeInsets.all(18),
            child: SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B8CFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  "Save Progress",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}