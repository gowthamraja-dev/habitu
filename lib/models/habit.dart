import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Represents a single habit stored in Firestore.
class Habit {
  final String id;
  final String name;
  final String section;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? colorHex;
  final String? iconName;
  /// Daily reminder time as minutes since midnight (e.g. 540 = 9:00). Null = no reminder.
  final int? reminderTimeMinutes;

  const Habit({
    required this.id,
    required this.name,
    required this.section,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
    this.colorHex,
    this.iconName,
    this.reminderTimeMinutes,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'section': section,
      'order': order,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      if (colorHex != null) 'colorHex': colorHex,
      if (iconName != null) 'iconName': iconName,
      if (reminderTimeMinutes != null) 'reminderTimeMinutes': reminderTimeMinutes,
    };
  }

  factory Habit.fromMap(String id, Map<String, dynamic> map) {
    return Habit(
      id: id,
      name: map['name'] as String? ?? '',
      section: map['section'] as String? ?? 'MORNING_SYSTEM',
      order: (map['order'] as num?)?.toInt() ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      colorHex: map['colorHex'] as String?,
      iconName: map['iconName'] as String?,
      reminderTimeMinutes: (map['reminderTimeMinutes'] as num?)?.toInt(),
    );
  }

  /// Set [clearReminder] to true to remove the daily reminder.
  Habit copyWith({
    String? id,
    String? name,
    String? section,
    int? order,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? colorHex,
    String? iconName,
    int? reminderTimeMinutes,
    bool clearReminder = false,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      section: section ?? this.section,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      colorHex: colorHex ?? this.colorHex,
      iconName: iconName ?? this.iconName,
      reminderTimeMinutes: clearReminder ? null : (reminderTimeMinutes ?? this.reminderTimeMinutes),
    );
  }

  /// Reminder time as TimeOfDay, or null if no reminder.
  TimeOfDay? get reminderTimeOfDay {
    if (reminderTimeMinutes == null) return null;
    final m = reminderTimeMinutes!;
    return TimeOfDay(hour: m ~/ 60, minute: m % 60);
  }
}
