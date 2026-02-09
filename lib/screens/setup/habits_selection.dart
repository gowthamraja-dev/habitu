import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:habitu/core/app_constants.dart';
import 'package:habitu/models/habit.dart';
import 'package:habitu/models/habit_meta.dart';
import 'package:habitu/screens/home_screen.dart';
import 'package:habitu/services/habit_service.dart';
import 'package:habitu/services/habits_meta_service.dart';
import 'package:habitu/services/user_prefs_service.dart';

const int _chipsPerSection = 5;

class HabitSelectionScreen extends StatefulWidget {
  final int ageMin;
  final int ageMax;

  const HabitSelectionScreen({
    super.key,
    required this.ageMin,
    required this.ageMax,
  });

  @override
  State<HabitSelectionScreen> createState() => _HabitSelectionScreenState();
}

class _HabitSelectionScreenState extends State<HabitSelectionScreen> {
  final HabitsMetaService _metaService = HabitsMetaService();
  final HabitService _habitService = HabitService();
  final UserPrefsService _userPrefs = UserPrefsService();

  List<HabitMeta> _allMeta = [];
  Map<String, List<HabitMeta>> _byCategory = {};
  List<String> _categories = [];
  final Set<String> _selectedIds = {};
  bool _loading = true;
  String? _error;
  final Map<String, bool> _expandedCategory = {};

  String get _selectedCategory => _categories.isNotEmpty ? _categories[_selectedCategoryIndex] : '';
  int _selectedCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await _metaService.fetchForAgeRange(widget.ageMin, widget.ageMax);
      final grouped = HabitsMetaService.groupByCategory(list);
      final categories = HabitsMetaService.getCategories(grouped);
      if (mounted) {
        setState(() {
          _allMeta = list;
          _byCategory = grouped;
          _categories = categories;
          _loading = false;
          if (_categories.isNotEmpty && _selectedCategoryIndex >= _categories.length) {
            _selectedCategoryIndex = 0;
          }
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

  List<HabitMeta> _habitsForCategory(String displayCategory) {
    final key = displayCategory.toLowerCase();
    return _byCategory[key] ?? _byCategory[displayCategory] ?? [];
  }

  bool _isExpanded(String category) => _expandedCategory[category] ?? false;

  void _toggleExpand(String category) {
    setState(() => _expandedCategory[category] = !(_expandedCategory[category] ?? false));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            if (_loading) const Expanded(child: Center(child: CircularProgressIndicator(color: Colors.cyanAccent))),
            if (_error != null) Expanded(child: _buildError()),
            if (!_loading && _error == null) ...[
              _buildCategoryTabs(),
              Expanded(child: _buildContent()),
            ],
            if (!_loading && _error == null) _buildContinueButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "CHOOSE YOUR",
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              letterSpacing: 4,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "DAILY SYSTEMS",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w200,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _load,
              child: const Text('Retry', style: TextStyle(color: Colors.cyanAccent)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    if (_categories.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final isActive = _selectedCategoryIndex == index;
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _selectedCategoryIndex = index);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isActive ? Colors.cyanAccent : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  _categories[index].toUpperCase(),
                  style: TextStyle(
                    color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.3),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    final category = _selectedCategory;
    final habits = _habitsForCategory(category);
    if (habits.isEmpty) {
      return Center(
        child: Text(
          'No habits in this category',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
        ),
      );
    }

    final expanded = _isExpanded(category);
    final toShow = expanded ? habits : habits.take(_chipsPerSection).toList();
    final hasMore = habits.length > _chipsPerSection;

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ...toShow.asMap().entries.map((e) {
              final index = e.key;
              final meta = e.value;
              final isSelected = _selectedIds.contains(meta.id);
              return TweenAnimationBuilder<double>(
                key: ValueKey('${meta.id}_$index'),
                duration: Duration(milliseconds: 350 + (index * 40)),
                tween: Tween(begin: 0.0, end: 1.0),
                curve: Curves.elasticOut,
                builder: (context, value, child) => Transform.scale(
                  scale: value,
                  child: child,
                ),
                child: _OrbitChip(
                  label: meta.name,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedIds.remove(meta.id);
                      } else {
                        _selectedIds.add(meta.id);
                      }
                    });
                  },
                ),
              );
            }),
            if (hasMore)
              _MoreChip(
                expanded: expanded,
                onTap: () => _toggleExpand(category),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildContinueButton() {
    final enabled = _selectedIds.isNotEmpty;
    return AnimatedOpacity(
      opacity: enabled ? 1.0 : 0.4,
      duration: const Duration(milliseconds: 200),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
        child: GestureDetector(
          onTap: enabled ? _onComplete : null,
          child: Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00F2FE), Color(0xFF4FACFE)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                "CONTINUE",
                style: TextStyle(
                  color: Color(0xFF0A0A0C),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onComplete() async {
    if (_selectedIds.isEmpty) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final selected = _allMeta.where((m) => _selectedIds.contains(m.id)).toList();
    final now = DateTime.now();
    final section = HabitSections.morning;

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
}

class _OrbitChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _OrbitChip({
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.cyanAccent.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(50),
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              expanded ? 'Less' : 'More',
              style: TextStyle(
                color: Colors.cyanAccent.withValues(alpha: 0.9),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: Colors.cyanAccent,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
