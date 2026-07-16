import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'habitchoice.dart';
import 'habit_tracker_screen.dart';

class HabitHomeScreen extends StatefulWidget {
  const HabitHomeScreen({super.key});

  @override
  State<HabitHomeScreen> createState() => _HabitHomeScreenState();
}

class _HabitHomeScreenState extends State<HabitHomeScreen> {
  @override
  void initState() {
    super.initState();
    check();
  }

  Future<void> check() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final firestore = FirebaseFirestore.instance;

    final doc = await firestore
        .collection('users')
        .doc(user.uid)
        .collection('habit_tracker')
        .doc('active_plan')
        .get();

    if (!mounted) return;

    if (doc.exists) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HabitTrackerScreen(),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>  HabitChoiceScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}