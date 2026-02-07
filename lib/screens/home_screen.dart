import 'package:flutter/material.dart';
import 'package:habitu/widgets/orbit_habit_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The background color should be the deep Obsidian we defined
      backgroundColor: const Color(0xFF0A0A0C),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. The Cosmic Header
          SliverAppBar(
            expandedHeight: 180.0,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF0A0A0C),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              title: const Text(
                "ORBIT",
                style: TextStyle(
                  letterSpacing: 6,
                  fontWeight: FontWeight.w200,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              background: _buildHeaderStats(),
            ),
          ),

          // 2. The Habit Feed
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const _SectionHeader(title: "MORNING SYSTEM"),
                OrbitHabitCard(
                  habitName: "Meditate",
                  onComplete: () => _showCompletionToast(context),
                ),
                const SizedBox(height: 20),
                OrbitHabitCard(
                  habitName: "Hydrate",
                  onComplete: () => _showCompletionToast(context),
                ),
                const SizedBox(height: 40),
                const _SectionHeader(title: "AFTERNOON SYSTEM"),
                OrbitHabitCard(
                  habitName: "Deep Work",
                  onComplete: () => _showCompletionToast(context),
                ),
                const SizedBox(height: 20),
                OrbitHabitCard(
                  habitName: "Reading",
                  onComplete: () => _showCompletionToast(context),
                ),
              ]),
            ),
          ),
        ],
      ),

      // 3. Floating Action Button (Glass Style)
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildAddButton(),
    );
  }

  Widget _buildHeaderStats() {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "92%",
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          const Text(
            "MOMENTUM ALIGNED",
            style: TextStyle(color: Colors.cyanAccent, fontSize: 10, letterSpacing: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return Container(
      height: 60,
      width: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.1),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: const Icon(Icons.add, color: Colors.white, size: 30),
    );
  }

  void _showCompletionToast(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Momentum Increased +5%"),
        backgroundColor: Colors.cyan,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 24),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.4),
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
    );
  }
}
