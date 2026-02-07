import 'package:flutter/material.dart';
import 'package:habitu/core/app_constants.dart';
import 'package:habitu/models/habit.dart';
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
              onAdd: () => _openHabitSheet(context),
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
                      onEdit: () => _openHabitSheet(context, habit: h),
                      onDelete: () => _confirmDelete(context, h),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: _AddButton(onPressed: () => _openHabitSheet(context)),
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

  void _openHabitSheet(BuildContext context, {Habit? habit}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _HabitFormSheet(
        habit: habit,
        onSave: (name, section, order) async {
          final now = DateTime.now();
          if (habit != null) {
            await _habitService.update(habit.copyWith(
              name: name,
              section: section,
              order: order,
              updatedAt: now,
            ));
          } else {
            await _habitService.create(Habit(
              id: '',
              name: name,
              section: section,
              order: order,
              createdAt: now,
              updatedAt: now,
            ));
          }
          if (ctx.mounted) Navigator.of(ctx).pop();
        },
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
          '“${habit.name}” will be removed.',
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
            'Add your first habit to start tracking',
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
              'Add habit',
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

  const _HabitTile({
    required this.habit,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
                  child: Text(
                    habit.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
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

class _HabitFormSheet extends StatefulWidget {
  final Habit? habit;
  final Future<void> Function(String name, String section, int order) onSave;

  const _HabitFormSheet({this.habit, required this.onSave});

  @override
  State<_HabitFormSheet> createState() => _HabitFormSheetState();
}

class _HabitFormSheetState extends State<_HabitFormSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _orderController;
  late String _section;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.habit?.name ?? '');
    _orderController = TextEditingController(text: '${widget.habit?.order ?? 0}');
    _section = widget.habit?.section ?? HabitSections.morning;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  widget.habit != null ? 'EDIT HABIT' : 'NEW HABIT',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 11,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                  decoration: InputDecoration(
                    hintText: 'Habit name',
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.06),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  ),
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _section,
                  dropdownColor: const Color(0xFF1A1A20),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.06),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                  style: const TextStyle(color: Colors.white),
                  items: HabitSections.all.map((s) {
                    return DropdownMenuItem(value: s, child: Text(HabitSections.displayName(s)));
                  }).toList(),
                  onChanged: (v) => setState(() => _section = v ?? HabitSections.morning),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text(
                      'Order',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _orderController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.06),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _saving ? null : () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white.withValues(alpha: 0.7),
                          side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        onPressed: _saving ? null : _submit,
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
                            : Text(widget.habit != null ? 'Save' : 'Add'),
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

  void _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    final order = int.tryParse(_orderController.text.trim()) ?? 0;
    setState(() => _saving = true);
    await widget.onSave(name, _section, order);
    if (mounted) setState(() => _saving = false);
  }
}
