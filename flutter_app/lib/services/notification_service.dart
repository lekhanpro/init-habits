import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;
import '../models/habit.dart';

/// Best-effort notifications. All methods catch errors so the app
/// keeps working on devices/emulators without notification support.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  Future<void> init() async {
    if (_ready) return;
    try {
      tzdata.initializeTimeZones();
    } catch (_) {}

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    try {
      await _plugin.initialize(settings);
      // Request notification permission on Android 13+.
      final androidImpl = _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await androidImpl?.requestNotificationsPermission();
      _ready = true;
    } catch (e) {
      if (kDebugMode) print('NotificationService init failed: $e');
    }
  }

  Future<void> scheduleForHabit(Habit habit) async {
    if (!_ready || habit.reminderMinutes == null) return;
    try {
      final id = habit.id.hashCode & 0x7fffffff;
      final hour = habit.reminderMinutes! ~/ 60;
      final minute = habit.reminderMinutes! % 60;
      final now = tz.TZDateTime.now(tz.local);
      var when = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
      if (when.isBefore(now)) when = when.add(const Duration(days: 1));

      await _plugin.zonedSchedule(
        id,
        'habits.today()',
        habit.name,
        when,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'init_habits_reminders',
            'Habit reminders',
            channelDescription: 'Daily reminders for your habits',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      if (kDebugMode) print('scheduleForHabit failed: $e');
    }
  }

  Future<void> cancelForHabit(Habit habit) async {
    if (!_ready) return;
    try {
      final id = habit.id.hashCode & 0x7fffffff;
      await _plugin.cancel(id);
    } catch (_) {}
  }

  Future<void> cancelAll() async {
    if (!_ready) return;
    try {
      await _plugin.cancelAll();
    } catch (_) {}
  }

  Future<void> rescheduleAll(List<Habit> habits, {required bool enabled}) async {
    await cancelAll();
    if (!enabled) return;
    for (final h in habits) {
      if (h.reminderMinutes != null && !h.archived) await scheduleForHabit(h);
    }
  }
}
