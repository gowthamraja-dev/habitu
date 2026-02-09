import 'package:flutter/material.dart';
import 'package:habitu/core/ist_time.dart';
import 'package:habitu/core/app_constants.dart';
import 'package:habitu/models/habit.dart';
import 'package:habitu/screens/manage/add_habits_screen.dart';
import 'package:habitu/screens/manage/habit_form_sheet.dart';
import 'package:habitu/screens/manage/habit_reminder_sheet.dart';
import 'package:habitu/services/habit_service.dart';

class ManageHabitsScreen extends StatelessWidget {
  const ManageHabitsScreen({super.key});

  static final HabitService _habitService = HabitService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0C),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'MANAGE HABITS',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            letterSpacing: 3,
            fontWeight: FontWeight.w300,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Habit>>(
        stream: _habitService.watchHabits(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Something went wrong',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.cyanAccent),
            );
          }
          final habits = snapshot.data!;
          if (habits.isEmpty) {
            return _EmptyState(
              onAdd: () => _openAddHabitsScreen(context),
            );
          }
          final grouped = _groupBySection(habits);
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
            itemCount: grouped.length,
            itemBuilder: (context, index) {
              final section = grouped.keys.elementAt(index);
              final sectionHabits = grouped[section]!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12, top: 8),
                    child: Text(
                      HabitSections.displayName(section),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  ...sectionHabits.map(
                    (h) => _HabitTile(
                      habit: h,
                      onEdit: () => _openEditSheet(context, h),
                      onDelete: () => _confirmDelete(context, h),
                      onSetReminder: () => _openReminderSheet(context, h),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: _AddButton(onPressed: () => _openAddHabitsScreen(context)),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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

  void _openAddHabitsScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const AddHabitsScreen()),
    );
  }

  void _openEditSheet(BuildContext context, Habit habit) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => HabitFormSheet(
        habit: habit,
        onSave: (name, section, order) async {
          final now = DateTime.now();
          await _habitService.update(habit.copyWith(
            name: name,
            section: section,
            order: order,
            updatedAt: now,
          ));
          if (ctx.mounted) Navigator.of(ctx).pop();
        },
      ),
    );
  }

  void _openReminderSheet(BuildContext context, Habit habit) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => HabitReminderSheet(
        habit: habit,
        onSaved: () {},
      ),
    );
  }

  void _confirmDelete(BuildContext context, Habit habit) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141418),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete habit?', style: TextStyle(color: Colors.white)),
        content: Text(
          '"${habit.name}" will be removed.',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: TextStyle(color: Colors.white.withValues(alpha: 0.7))),
          ),
          TextButton(
            onPressed: () async {
              await _habitService.delete(habit.id);
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.touch_app_rounded, size: 64, color: Colors.white.withValues(alpha: 0.2)),
          const SizedBox(height: 24),
          Text(
            'No habits yet',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 18,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add habits from suggestions or create your own',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.35),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 32),
          TextButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, color: Colors.cyanAccent, size: 20),
            label: const Text(
              'Add habits',
              style: TextStyle(color: Colors.cyanAccent, letterSpacing: 1),
            ),
          ),
        ],
      ),
    );
  }
}

class _HabitTile extends StatelessWidget {
  final Habit habit;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetReminder;

  const _HabitTile({
    required this.habit,
    required this.onEdit,
    required this.onDelete,
    required this.onSetReminder,
  });

  @override
  Widget build(BuildContext context) {
    final hasReminder = habit.reminderTimeMinutes != null;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        habit.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      if (hasReminder && habit.reminderTimeOfDay != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Reminder ${IstTime.formatMinutes(habit.reminderTimeMinutes!)}',
                          style: TextStyle(
                            color: Colors.cyanAccent.withValues(alpha: 0.9),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    hasReminder ? Icons.notifications_active : Icons.notifications_none_outlined,
                    size: 20,
                    color: hasReminder ? Colors.cyanAccent : Colors.white.withValues(alpha: 0.5),
                  ),
                  onPressed: onSetReminder,
                  tooltip: hasReminder ? 'Change reminder' : 'Set reminder',
                ),
                IconButton(
                  icon: Icon(Icons.edit_outlined, size: 20, color: Colors.white.withValues(alpha: 0.5)),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, size: 20, color: Colors.white.withValues(alpha: 0.4)),
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _AddButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.1),
          border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.5)),
        ),
        child: const Icon(Icons.add, color: Colors.cyanAccent, size: 28),
      ),
    );
  }
}
