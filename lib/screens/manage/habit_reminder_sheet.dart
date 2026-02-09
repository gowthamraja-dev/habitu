import 'package:flutter/material.dart';
import 'package:habitu/core/ist_time.dart';
import 'package:habitu/models/habit.dart';
import 'package:habitu/services/habit_service.dart';
import 'package:habitu/services/notification_service.dart';

/// Bottom sheet to set or remove a daily reminder time for a habit.
class HabitReminderSheet extends StatefulWidget {
  final Habit habit;
  final VoidCallback onSaved;

  const HabitReminderSheet({
    super.key,
    required this.habit,
    required this.onSaved,
  });

  @override
  State<HabitReminderSheet> createState() => _HabitReminderSheetState();
}

class _HabitReminderSheetState extends State<HabitReminderSheet> {
  late TimeOfDay _pickedTime;
  bool _saving = false;
  final HabitService _habitService = HabitService();
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _pickedTime = widget.habit.reminderTimeMinutes != null
        ? IstTime.fromMinutes(widget.habit.reminderTimeMinutes!)
        : const TimeOfDay(hour: 9, minute: 0);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _pickedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.cyanAccent,
              onPrimary: const Color(0xFF0A0A0C),
              surface: const Color(0xFF1A1A20),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (t != null && mounted) setState(() => _pickedTime = t);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final minutes = IstTime.toMinutes(_pickedTime);
      final updated = widget.habit.copyWith(
        reminderTimeMinutes: minutes,
        updatedAt: DateTime.now(),
      );
      await _habitService.update(updated);
      await _notificationService.requestPermission();
      await _notificationService.syncHabitReminder(updated);
      if (mounted) {
        widget.onSaved();
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not schedule reminder: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _removeReminder() async {
    setState(() => _saving = true);
    final updated = widget.habit.copyWith(
      clearReminder: true,
      updatedAt: DateTime.now(),
    );
    await _habitService.update(updated);
    await _notificationService.cancelHabitReminder(widget.habit.id);
    if (mounted) {
      widget.onSaved();
      Navigator.of(context).pop();
    }
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final hasReminder = widget.habit.reminderTimeMinutes != null;
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0E0E12),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'DAILY REMINDER',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 11,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.habit.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 24),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Notify at',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14),
                  ),
                  trailing: TextButton.icon(
                    onPressed: _saving ? null : _pickTime,
                    icon: const Icon(Icons.schedule, color: Colors.cyanAccent, size: 20),
                    label: Text(
                      _pickedTime.format(context),
                      style: const TextStyle(
                        color: Colors.cyanAccent,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (hasReminder) ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _saving ? null : _removeReminder,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white.withValues(alpha: 0.7),
                            side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text('Remove reminder'),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      flex: hasReminder ? 1 : 2,
                      child: FilledButton(
                        onPressed: _saving ? null : _save,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.cyanAccent,
                          foregroundColor: const Color(0xFF0A0A0C),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: _saving
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
