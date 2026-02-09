import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:habitu/core/ist_time.dart';
import 'package:habitu/models/habit.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Schedules and cancels time-based daily notifications for habits.
class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;

  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'habit_reminders',
    'Habit reminders',
    description: 'Daily reminders for your habits',
    importance: Importance.defaultImportance,
    playSound: true,
  );

  /// Call once at app startup (e.g. from main.dart).
  Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    // Force IST everywhere (independent of device timezone).
    tz.setLocalLocation(IstTime.location());

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
    );
    const initSettings = InitializationSettings(android: android, iOS: ios);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onSelect,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    _initialized = true;
  }

  void _onSelect(NotificationResponse response) {
    if (response.payload != null && response.payload!.isNotEmpty) {
      try {
        final payload = jsonDecode(response.payload!) as Map<String, dynamic>;
        final habitId = payload['habitId'] as String?;
        // Could navigate to habit / home when tapped
        if (habitId != null) {}
      } catch (_) {}
    }
  }

  /// Request permission (iOS 10+, Android 13+). Call before scheduling.
  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      return await ios.requestPermissions(alert: true, badge: true, sound: true) ?? false;
    }
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    return true;
  }

  int _notificationIdForHabit(String habitId) {
    return habitId.hashCode.abs() % 0x7FFFFFFF;
  }

  /// Schedule a daily notification for [habit] at [reminderTimeMinutes] (minutes since midnight).
  /// Re-scheduling for the same habit replaces the previous time.
  Future<void> scheduleHabitReminder(Habit habit, int reminderTimeMinutes) async {
    await initialize();
    final id = _notificationIdForHabit(habit.id);
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      reminderTimeMinutes ~/ 60,
      reminderTimeMinutes % 60,
    );
    if (scheduled.isBefore(now)) scheduled = scheduled.add(const Duration(days: 1));

    final payload = jsonEncode({'habitId': habit.id, 'habitName': habit.name});

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channel.id,
        _channel.name,
        channelDescription: _channel.description,
        importance: _channel.importance,
      ),
      iOS: const DarwinNotificationDetails(presentAlert: true, presentBadge: true),
    );

    // Android 12+/14+: exact alarms may be blocked by system settings. If so,
    // fall back to inexact scheduling instead of crashing/hanging the UI.
    try {
      await _plugin.zonedSchedule(
        id,
        'Habit reminder',
        habit.name,
        scheduled,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } on PlatformException catch (e) {
      if (e.code == 'exact_alarms_not_permitted') {
        await _plugin.zonedSchedule(
          id,
          'Habit reminder',
          habit.name,
          scheduled,
          details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: payload,
          matchDateTimeComponents: DateTimeComponents.time,
        );
        return;
      }
      rethrow;
    }
  }

  /// Cancel the daily reminder for this habit.
  Future<void> cancelHabitReminder(String habitId) async {
    final id = _notificationIdForHabit(habitId);
    await _plugin.cancel(id);
  }

  /// Apply reminder state from [habit]: schedule if reminderTimeMinutes set, else cancel.
  Future<void> syncHabitReminder(Habit habit) async {
    if (habit.reminderTimeMinutes != null) {
      await scheduleHabitReminder(habit, habit.reminderTimeMinutes!);
    } else {
      await cancelHabitReminder(habit.id);
    }
  }

  /// Show a local notification immediately (for testing).
  Future<void> showTestNow({String title = 'Local notification test', String body = 'It works'}) async {
    await initialize();
    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(0x7FFFFFFF),
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: _channel.importance,
        ),
        iOS: const DarwinNotificationDetails(presentAlert: true, presentBadge: true),
      ),
    );
  }

  /// Test: wait [seconds] then show a notification (reliable when app is open).
  /// Does not use AlarmManager, so keep app in foreground for the delay.
  Future<void> scheduleTestInSeconds({
    int seconds = 10,
    String title = 'Scheduled local test',
    String? body,
  }) async {
    await initialize();
    await Future.delayed(Duration(seconds: seconds));
    await showTestNow(
      title: title,
      body: body ?? 'This was delayed $seconds seconds',
    );
  }
}
