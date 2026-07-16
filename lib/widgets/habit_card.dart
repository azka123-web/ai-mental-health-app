import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class HabitList extends StatelessWidget {
  const HabitList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Today's Habits",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView(
            children: const [
              HabitCard(
                icon: Icons.bedtime,
                title: "Sleep",
                percent: 0.6,
                color: Colors.purple,
              ),
              HabitCard(
                icon: Icons.menu_book,
                title: "Read Book",
                percent: 0.4,
                color: Colors.blue,
              ),
              HabitCard(
                icon: Icons.fitness_center,
                title: "Exercise",
                percent: 0.3,
                color: Colors.orange,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class HabitCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final double percent;
  final Color color;

  const HabitCard({
    super.key,
    required this.icon,
    required this.title,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: percent,
                  color: color,
                  backgroundColor: Colors.grey.shade200,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text("${(percent * 100).toInt()}%"),
        ],
      ),
    );
  }
}
