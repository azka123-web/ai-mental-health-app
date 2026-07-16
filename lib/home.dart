import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'chat_screen.dart';
import 'exercise_video_screen.dart';
import 'signup.dart';
import 'habitchoice.dart';
import 'habit_tracker_screen.dart';
import 'reward_history_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PageController _pageController = PageController();

  int currentPage = 0;

  bool get isLoggedIn => _auth.currentUser != null;

  // ================= PROFESSIONAL COLOR PALETTE =================
  static const Color primaryDark = Color(0xFF1E293B);
  static const Color accentBlue = Color(0xFF0891B2); // Mostly Blue with a touch of Green// Professional Teal (Green-Blue mix)
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color textMain = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);

  final List<Map<String, String>> exerciseCards = [
    {"title": "Stress", "image": "assets/stress_low.png"},
    {"title": "Depression", "image": "assets/depression_low.png"},
  ];

  // ================= LOGIC (UNCHANGED) =================

  void _openDiagnosis() {
    if (!isLoggedIn) {
      showDialog(
        context: context,
        builder: (_) => const SignupPage(),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChatScreen()),
    );
  }

  Future<void> _openHabitTracker() async {
    if (!isLoggedIn) {
      showDialog(
        context: context,
        builder: (_) => const SignupPage(),
      );
      return;
    }
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final doc = await firestore
          .collection('users')
          .doc(user.uid)
          .collection('habit_tracker')
          .doc('active_plan')
          .get();

      if (!doc.exists || doc.data() == null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => HabitChoiceScreen()),
        );
        return;
      }

      final data = doc.data()!;
      bool isCompleted = data['isCompleted'] ?? false;

      if (isCompleted == true) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => HabitChoiceScreen()),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const HabitTrackerScreen()),
      );
    } catch (e) {
      debugPrint("Habit Tracker Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Something went wrong")),
      );
    }
  }

  Future<void> _logout() async {
    await _auth.signOut();
    setState(() {});
  }

  // ================= MODERN UI HELPERS =================

  Widget _buildActionButton({required String text, required VoidCallback onTap}) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: accentBlue.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: accentBlue,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required String image,
    required String buttonText,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accentBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: accentBlue, size: 24),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: textMain,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(fontSize: 13, color: textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset(
                image,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildActionButton(text: buttonText, onTap: onTap),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: background,
        centerTitle: false,
        title: const Text(
          "MindEase+",
          style: TextStyle(
            color: textMain,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              onPressed: () => _scaffoldKey.currentState!.openEndDrawer(),
              // FIXED ICON NAME: Changed align_right_rounded to notes_rounded
              icon: const Icon(Icons.notes_rounded, color: textMain, size: 28),
            ),
          ),
        ],
      ),
      endDrawer: _buildDrawer(user),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // FIXED CONST ERROR: Removed 'const' because user data is dynamic
              Text(
                "Welcome",
                style: TextStyle(fontSize: 16, color: textMuted, fontWeight: FontWeight.w500),
              ),
              Text(
                user?.email?.split('@')[0] ?? "Guest User",
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: textMain),
              ),
              const SizedBox(height: 25),

              _buildFeatureCard(
                title: "AI Diagnosis",
                subtitle: "How are you feeling today?",
                image: 'assets/diagnosispic.png',
                buttonText: "Begin Analysis",
                icon: Icons.psychology_rounded,
                onTap: _openDiagnosis,
              ),

              _buildFeatureCard(
                title: "Habit Tracker",
                subtitle: "Maintain your mental balance",
                image: 'assets/habitpic.png',
                buttonText: "Maintain Healthy Habits",
                icon: Icons.auto_graph_rounded,
                onTap: _openHabitTracker,
              ),

              const Padding(
                padding: EdgeInsets.only(bottom: 2, top: 10), // Reduced bottom padding from 16 to 2
                child: Text(
                  "Therapeutic Sessions",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textMain),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 0, bottom: 16), // Removed top padding
                child: Text(
                  "If you don't know your disease then diagnose first.",
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF0891B2), // Professional Navy Blue
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              SizedBox(
                height: 280,
                child: Column(
                  children: [
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (i) => setState(() => currentPage = i),
                        itemCount: exerciseCards.length,
                        itemBuilder: (context, index) {
                          final card = exerciseCards[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ExerciseVideoScreen(
                                    title: card["title"]!,
                                    image: card["image"]!,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                image: DecorationImage(
                                  image: AssetImage(card["image"]!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.8),
                                    ],
                                  ),
                                ),
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      card["title"]!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text(
                                      "Click to start session",
                                      style: TextStyle(color: Colors.white70, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        exerciseCards.length,
                            (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 6,
                          width: currentPage == index ? 24 : 6,
                          decoration: BoxDecoration(
                            color: currentPage == index ? accentBlue : Colors.grey.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(User? user) {
    return Drawer(
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          bottomLeft: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(24, 80, 24, 40),
            width: double.infinity,
            // Professional Medium-Navy (Slate)
            decoration: const BoxDecoration(
              color: Color(0xFFB0BEC5),
            ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Bold Dark Navy Email
                  Text(
                    user?.email ?? "Guest Access",
                    style: const TextStyle(
                      color: Color(0xFF0F172A), // Dark Navy Blue
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Bold Dark Navy Subtext
                  Text(
                    "MindEase+ Member",
                    style: TextStyle(
                      color: const Color(0xFF0F172A).withOpacity(0.85),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
          ),
          const SizedBox(height: 20),
          _drawerItem(Icons.dashboard_rounded, "Dashboard", () => Navigator.pop(context)),
          _drawerItem(Icons.history_rounded, "Progress History", () {
            Navigator.pop(context); // Close drawer before navigating
            Navigator.push(context, MaterialPageRoute(builder: (_) => const RewardHistoryScreen()));
          }),
          const Spacer(),
          if (user != null)
            _drawerItem(Icons.logout_rounded, "Sign Out", () {
              _logout();
              Navigator.pop(context);
            }, isExit: true),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap, {bool isExit = false}) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: isExit ? Colors.redAccent : textMain),
      title: Text(
        title,
        style: TextStyle(
          color: isExit ? Colors.redAccent : textMain,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
    );
  }
}