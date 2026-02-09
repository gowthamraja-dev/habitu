import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:habitu/core/app_constants.dart';
import 'package:habitu/models/habit.dart';
import 'package:habitu/models/habit_meta.dart';
import 'package:habitu/screens/home_screen.dart';
import 'package:habitu/services/habit_service.dart';
import 'package:habitu/services/habits_meta_service.dart';
import 'package:habitu/services/user_prefs_service.dart';

/// Single-screen setup: age + habits, one Continue. Minimal clicks.
class UnifiedSetupScreen extends StatefulWidget {
  const UnifiedSetupScreen({super.key});

  @override
  State<UnifiedSetupScreen> createState() => _UnifiedSetupScreenState();
}

class _UnifiedSetupScreenState extends State<UnifiedSetupScreen> {
  final HabitsMetaService _metaService = HabitsMetaService();
  final HabitService _habitService = HabitService();
  final UserPrefsService _userPrefs = UserPrefsService();

  String? _selectedAgeId;
  int? _ageMin;
  int? _ageMax;

  List<HabitMeta> _allMeta = [];
  Map<String, List<HabitMeta>> _byCategory = {};
  List<String> _categories = [];
  final Set<String> _selectedHabitIds = {};
  bool _habitsLoading = false;
  String? _habitsError;
  final Map<String, bool> _categoryExpanded = {};

  static const int _initialHabitsPerCategory = 10;

  @override
  void initState() {
    super.initState();
  }

  void _onAgeSelected(String id) {
    HapticFeedback.lightImpact();
    final item = HabitSections.ageGroups.firstWhere((e) => e['id'] == id);
    final ageMin = item['age_min'] as int;
    final ageMax = item['age_max'] as int;
    setState(() {
      _selectedAgeId = id;
      _ageMin = ageMin;
      _ageMax = ageMax;
      _allMeta = [];
      _byCategory = {};
      _categories = [];
      _selectedHabitIds.clear();
      _categoryExpanded.clear();
      _habitsLoading = true;
      _habitsError = null;
    });
    _loadHabits(ageMin, ageMax);
  }

  Future<void> _loadHabits(int ageMin, int ageMax) async {
    try {
      final list = await _metaService.fetchForAgeRange(ageMin, ageMax);
      final grouped = HabitsMetaService.groupByCategory(list);
      final categories = HabitsMetaService.getCategories(grouped);
      if (mounted) {
        setState(() {
          _allMeta = list;
          _byCategory = grouped;
          _categories = categories;
          _habitsLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _habitsLoading = false;
          _habitsError = e.toString();
        });
      }
    }
  }

  List<HabitMeta> _habitsForCategory(String displayCategory) {
    final key = displayCategory.toLowerCase();
    return _byCategory[key] ?? _byCategory[displayCategory] ?? [];
  }

  bool _isCategoryExpanded(String category) => _categoryExpanded[category] ?? false;

  void _toggleCategoryExpand(String category) {
    setState(() => _categoryExpanded[category] = !(_categoryExpanded[category] ?? false));
  }

  bool get _canContinue =>
      _selectedAgeId != null && _selectedHabitIds.isNotEmpty && !_habitsLoading;

  Future<void> _onComplete() async {
    if (!_canContinue) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final selected =
        _allMeta.where((m) => _selectedHabitIds.contains(m.id)).toList();
    final now = DateTime.now();
    const section = HabitSections.morning;
    for (var i = 0; i < selected.length; i++) {
      await _habitService.create(Habit(
        id: '',
        name: selected[i].name,
        section: section,
        order: i,
        createdAt: now,
        updatedAt: now,
      ));
    }
    await _userPrefs.setSetupComplete(uid);
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0C),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitle(),
                    const SizedBox(height: 28),
                    _buildAgeSection(),
                    if (_selectedAgeId != null) ...[
                      const SizedBox(height: 32),
                      _buildHabitsSection(),
                    ],
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            _buildContinueButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Identify your orbit',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 22,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Then pick the habits you want to build.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildAgeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AGE',
          style: TextStyle(
            color: Colors.cyanAccent.withValues(alpha: 0.9),
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: HabitSections.ageGroups.map((item) {
            final id = item['id'] as String;
            final label = item['label'] as String;
            final range = '${item['age_min']}-${item['age_max']}';
            final isSelected = _selectedAgeId == id;
            return _AgeChip(
              label: label,
              range: range,
              isSelected: isSelected,
              onTap: () => _onAgeSelected(id),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildHabitsSection() {
    if (_habitsLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              color: Colors.cyanAccent,
              strokeWidth: 2,
            ),
          ),
        ),
      );
    }
    if (_habitsError != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Text(
              _habitsError!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => _loadHabits(_ageMin!, _ageMax!),
              child: Text('Retry', style: TextStyle(color: Colors.cyanAccent)),
            ),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DAILY SYSTEMS',
          style: TextStyle(
            color: Colors.cyanAccent.withValues(alpha: 0.9),
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tap to select. At least one.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 16),
        ..._categories.map((cat) => _buildCategoryBlock(cat)),
      ],
    );
  }

  Widget _buildCategoryBlock(String displayCategory) {
    final habits = _habitsForCategory(displayCategory);
    if (habits.isEmpty) return const SizedBox.shrink();
    final expanded = _isCategoryExpanded(displayCategory);
    final toShow = expanded
        ? habits
        : habits.take(_initialHabitsPerCategory).toList();
    final hasMore = habits.length > _initialHabitsPerCategory;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            displayCategory.toUpperCase(),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...toShow.map((meta) => _HabitChip(
                    label: meta.name,
                    isSelected: _selectedHabitIds.contains(meta.id),
                    onTap: () {
                      setState(() {
                        if (_selectedHabitIds.contains(meta.id)) {
                          _selectedHabitIds.remove(meta.id);
                        } else {
                          _selectedHabitIds.add(meta.id);
                        }
                      });
                    },
                  )),
              if (hasMore)
                _MoreChip(
                  expanded: expanded,
                  onTap: () => _toggleCategoryExpand(displayCategory),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0C),
      ),
      child: SafeArea(
        top: false,
        child: AnimatedOpacity(
          opacity: _canContinue ? 1.0 : 0.45,
          duration: const Duration(milliseconds: 200),
          child: GestureDetector(
            onTap: _canContinue
                ? () {
                    HapticFeedback.mediumImpact();
                    _onComplete();
                  }
                : null,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00F2FE), Color(0xFF4FACFE)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: _canContinue
                    ? [
                        BoxShadow(
                          color: Colors.cyanAccent.withValues(alpha: 0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  'Continue',
                  style: TextStyle(
                    color: _canContinue
                        ? const Color(0xFF0A0A0C)
                        : const Color(0xFF0A0A0C).withValues(alpha: 0.7),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AgeChip extends StatelessWidget {
  final String label;
  final String range;
  final bool isSelected;
  final VoidCallback onTap;

  const _AgeChip({
    required this.label,
    required this.range,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.cyanAccent.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.cyanAccent
                : Colors.white.withValues(alpha: 0.12),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              size: 18,
              color: isSelected ? Colors.cyanAccent : Colors.white.withValues(alpha: 0.4),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.85),
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              range,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HabitChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _HabitChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.cyanAccent.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? Colors.cyanAccent
                : Colors.white.withValues(alpha: 0.1),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.add_circle_outline,
              size: 18,
              color: isSelected ? Colors.cyanAccent : Colors.white.withValues(alpha: 0.45),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.9),
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoreChip extends StatelessWidget {
  final bool expanded;
  final VoidCallback onTap;

  const _MoreChip({required this.expanded, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              expanded ? 'Less' : 'More',
              style: TextStyle(
                color: Colors.cyanAccent.withValues(alpha: 0.9),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: Colors.cyanAccent,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
