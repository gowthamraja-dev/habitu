import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:habitu/core/app_constants.dart';
import 'package:habitu/models/habit.dart';
import 'package:habitu/models/habit_meta.dart';
import 'package:habitu/screens/manage/habit_form_sheet.dart';
import 'package:habitu/services/habit_service.dart';
import 'package:habitu/services/habits_meta_service.dart';

/// Setup-style screen for adding habits: pick from catalog (by age) or add custom. Used from Manage habits.
class AddHabitsScreen extends StatefulWidget {
  const AddHabitsScreen({super.key});

  @override
  State<AddHabitsScreen> createState() => _AddHabitsScreenState();
}

class _AddHabitsScreenState extends State<AddHabitsScreen> {
  final HabitsMetaService _metaService = HabitsMetaService();
  final HabitService _habitService = HabitService();

  String? _selectedAgeId;
  int? _ageMin;
  int? _ageMax;
  List<HabitMeta> _allMeta = [];
  Map<String, List<HabitMeta>> _byCategory = {};
  List<String> _categories = [];
  final Set<String> _selectedIds = {};
  bool _loading = false;
  String? _error;
  final Map<String, bool> _categoryExpanded = {};

  static const int _initialPerCategory = 10;
  static const String _defaultAgeId = 'adult'; // 25-39

  @override
  void initState() {
    super.initState();
    _selectedAgeId = _defaultAgeId;
    final item = HabitSections.ageGroups.firstWhere((e) => e['id'] == _defaultAgeId);
    _ageMin = item['age_min'] as int;
    _ageMax = item['age_max'] as int;
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    if (_ageMin == null || _ageMax == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await _metaService.fetchForAgeRange(_ageMin!, _ageMax!);
      final grouped = HabitsMetaService.groupByCategory(list);
      final categories = HabitsMetaService.getCategories(grouped);
      if (mounted) {
        setState(() {
          _allMeta = list;
          _byCategory = grouped;
          _categories = categories;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    }
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
      _selectedIds.clear();
      _loading = true;
      _error = null;
    });
    _loadHabits();
  }

  List<HabitMeta> _habitsForCategory(String displayCategory) {
    final key = displayCategory.toLowerCase();
    return _byCategory[key] ?? _byCategory[displayCategory] ?? [];
  }

  bool _isExpanded(String cat) => _categoryExpanded[cat] ?? false;

  void _toggleExpand(String cat) {
    setState(() => _categoryExpanded[cat] = !(_categoryExpanded[cat] ?? false));
  }

  Future<void> _addSelectedFromCatalog() async {
    if (_selectedIds.isEmpty) return;
    final currentList = await _habitService.watchHabits().first;
    int order = currentList.length;
    final selected = _allMeta.where((m) => _selectedIds.contains(m.id)).toList();
    final now = DateTime.now();
    const section = HabitSections.morning;
    for (final meta in selected) {
      await _habitService.create(Habit(
        id: '',
        name: meta.name,
        section: section,
        order: order++,
        createdAt: now,
        updatedAt: now,
      ));
    }
    if (mounted) {
      setState(() => _selectedIds.clear());
      Navigator.of(context).pop();
    }
  }

  void _openCustomHabitSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => HabitFormSheet(
        onSave: (name, section, order) async {
          final now = DateTime.now();
          await _habitService.create(Habit(
            id: '',
            name: name,
            section: section,
            order: order,
            createdAt: now,
            updatedAt: now,
          ));
          if (ctx.mounted) Navigator.of(ctx).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'ADD HABITS',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            letterSpacing: 3,
            fontWeight: FontWeight.w300,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAgeStrip(),
                    const SizedBox(height: 24),
                    _buildCustomCta(),
                    const SizedBox(height: 20),
                    if (_loading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(color: Colors.cyanAccent, strokeWidth: 2),
                          ),
                        ),
                      )
                    else if (_error != null)
                      _buildError()
                    else
                      _buildCatalog(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            _buildAddSelectedButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAgeStrip() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AGE (for suggestions)',
          style: TextStyle(
            color: Colors.cyanAccent.withValues(alpha: 0.9),
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: HabitSections.ageGroups.map((item) {
              final id = item['id'] as String;
              final label = item['label'] as String;
              final isSelected = _selectedAgeId == id;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () => _onAgeSelected(id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.cyanAccent.withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Colors.cyanAccent : Colors.white.withValues(alpha: 0.12),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomCta() {
    return GestureDetector(
      onTap: _openCustomHabitSheet,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Row(
          children: [
            Icon(Icons.add_circle_outline, color: Colors.cyanAccent, size: 24),
            const SizedBox(width: 14),
            const Text(
              'Add custom habit',
              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _loadHabits,
            child: Text('Retry', style: TextStyle(color: Colors.cyanAccent)),
          ),
        ],
      ),
    );
  }

  Widget _buildCatalog() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SUGGESTED (tap to select)',
          style: TextStyle(
            color: Colors.cyanAccent.withValues(alpha: 0.9),
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 14),
        ..._categories.map((cat) {
          final habits = _habitsForCategory(cat);
          if (habits.isEmpty) return const SizedBox.shrink();
          final expanded = _isExpanded(cat);
          final toShow = expanded ? habits : habits.take(_initialPerCategory).toList();
          final hasMore = habits.length > _initialPerCategory;
          return Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cat.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...toShow.map((meta) => _Chip(
                          label: meta.name,
                          isSelected: _selectedIds.contains(meta.id),
                          onTap: () {
                            setState(() {
                              if (_selectedIds.contains(meta.id)) {
                                _selectedIds.remove(meta.id);
                              } else {
                                _selectedIds.add(meta.id);
                              }
                            });
                          },
                        )),
                    if (hasMore)
                      GestureDetector(
                        onTap: () => _toggleExpand(cat),
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
                      ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAddSelectedButton() {
    final enabled = _selectedIds.isNotEmpty;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      decoration: const BoxDecoration(color: Color(0xFF0A0A0C)),
      child: SafeArea(
        top: false,
        child: AnimatedOpacity(
          opacity: enabled ? 1.0 : 0.45,
          duration: const Duration(milliseconds: 200),
          child: GestureDetector(
            onTap: enabled
                ? () {
                    HapticFeedback.mediumImpact();
                    _addSelectedFromCatalog();
                  }
                : null,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00F2FE), Color(0xFF4FACFE)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  enabled ? 'Add ${_selectedIds.length} selected' : 'Select habits above or add custom',
                  style: TextStyle(
                    color: enabled ? const Color(0xFF0A0A0C) : const Color(0xFF0A0A0C).withValues(alpha: 0.7),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
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

class _Chip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _Chip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.cyanAccent.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? Colors.cyanAccent : Colors.white.withValues(alpha: 0.1),
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
