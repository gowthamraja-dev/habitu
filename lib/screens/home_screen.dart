import 'package:flutter/material.dart';
import 'package:habitu/core/app_constants.dart';
import 'package:habitu/models/habit.dart';
import 'package:habitu/screens/manage/manage_habits_screen.dart';
import 'package:habitu/screens/settings/settings_screen.dart';
import 'package:habitu/services/auth_service.dart';
import 'package:habitu/services/habit_service.dart';
import 'package:habitu/widgets/orbit_habit_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static final HabitService _habitService = HabitService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0C),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 180.0,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF0A0A0C),
            actions: [
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.white.withValues(alpha: 0.8)),
                color: const Color(0xFF141418),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onSelected: (value) {
                  if (value == 'sign_out') AuthService().signOut();
                  if (value == 'settings') {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
                    );
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'settings',
                    child: Row(
                      children: [
                        Icon(Icons.settings, size: 20, color: Colors.white70),
                        SizedBox(width: 12),
                        Text('Settings', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'sign_out',
                    child: Row(
                      children: [
                        Icon(Icons.logout, size: 20, color: Colors.white70),
                        SizedBox(width: 12),
                        Text('Sign out', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
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
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
            sliver: StreamBuilder<List<Habit>>(
              stream: _habitService.watchHabits(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Something went wrong',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                      ),
                    ),
                  );
                }
                if (!snapshot.hasData) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(48),
                      child: Center(child: CircularProgressIndicator(color: Colors.cyanAccent)),
                    ),
                  );
                }
                final habits = snapshot.data!;
                if (habits.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const SizedBox(height: 40),
                          Text(
                            'No habits yet',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap + to add your first habit',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.3),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                final grouped = _groupBySection(habits);
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final section = grouped.keys.elementAt(index);
                      final sectionHabits = grouped[section]!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionHeader(title: HabitSections.displayName(section)),
                          ...sectionHabits.map(
                            (h) => Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: OrbitHabitCard(
                                habit: h,
                                onComplete: () => _showCompletionToast(context),
                              ),
                            ),
                          ),
                          if (index < grouped.length - 1) const SizedBox(height: 24),
                        ],
                      );
                    },
                    childCount: grouped.length,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildAddButton(context),
    );
  }

  Map<String, List<Habit>> _groupBySection(List<Habit> habits) {
    final map = <String, List<Habit>>{};
    for (final section in HabitSections.all) {
      final list = habits.where((h) => h.section == section).toList()
        ..sort((a, b) => a.order.compareTo(b.order));
      if (list.isNotEmpty) map[section] = list;
    }
    return map;
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

  Widget _buildAddButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ManageHabitsScreen()),
      ),
      child: Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.1),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
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
