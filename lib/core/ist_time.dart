import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;

/// Helpers for working with Indian Standard Time (IST / Asia/Kolkata).
///
/// We store reminder times as "minutes since midnight" (0..1439).
/// These helpers keep conversions + formatting consistent across the app.
class IstTime {
  static const String ianaZone = 'Asia/Kolkata';

  /// TZ location for IST scheduling.
  static tz.Location location() => tz.getLocation(ianaZone);

  /// Convert a [TimeOfDay] to minutes since midnight.
  static int toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

  /// Convert minutes since midnight to a [TimeOfDay].
  static TimeOfDay fromMinutes(int minutes) {
    final m = minutes.clamp(0, 1439);
    return TimeOfDay(hour: m ~/ 60, minute: m % 60);
  }

  /// Format minutes since midnight as a stable IST string (e.g. "9:05 AM IST").
  ///
  /// This avoids device-locale/time format differences so the UI is consistent.
  static String formatMinutes(int minutes) {
    final t = fromMinutes(minutes);
    final hour12 = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final mm = t.minute.toString().padLeft(2, '0');
    final suffix = t.hour >= 12 ? 'PM' : 'AM';
    return '$hour12:$mm $suffix IST';
  }
}

