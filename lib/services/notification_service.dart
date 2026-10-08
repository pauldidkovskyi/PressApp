import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/schedule_item.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(settings: initSettings);
    _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  Future<void> syncNotifications(
    List<EventItem> events,
    List<TaskItem> tasks,
  ) async {
    await _notificationsPlugin.cancelAll();

    int notificationId = 0;
    final now = DateTime.now();

    for (var event in events) {
      if (!event.isCompleted && event.reminderMinutes != null) {
        final scheduledTime = event.startTime.subtract(
          Duration(minutes: event.reminderMinutes!),
        );
        if (scheduledTime.isAfter(now)) {
          await _schedule(
            id: notificationId++,
            title: event.title,
            body: event.reminderMinutes == 0
                ? 'Starting now!'
                : 'Starts in ${event.reminderMinutes} minutes',
            scheduledTime: scheduledTime,
          );
        }
      }
    }

    for (var task in tasks) {
      if (!task.isCompleted && task.reminderTime != null) {
        if (task.reminderTime!.isAfter(now)) {
          await _schedule(
            id: notificationId++,
            title: 'Reminder: ${task.title}',
            body: task.description ?? 'Don\'t forget your task!',
            scheduledTime: task.reminderTime!,
          );
        }
      }
    }

    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    _scheduleBriefingsForDate(today, tasks, notificationId);
    _scheduleBriefingsForDate(tomorrow, tasks, notificationId + 100);
  }

  Future<void> _scheduleBriefingsForDate(
    DateTime date,
    List<TaskItem> allTasks,
    int baseId,
  ) async {
    final now = DateTime.now();

    final dayTasks = allTasks
        .where(
          (t) =>
              t.date.year == date.year &&
              t.date.month == date.month &&
              t.date.day == date.day,
        )
        .toList();
    if (dayTasks.isEmpty) return;

    final morningTime = DateTime(date.year, date.month, date.day, 6, 30);
    if (morningTime.isAfter(now)) {
      final taskListText = dayTasks
          .take(3)
          .map((t) => '• ${t.title}')
          .join('\n');
      final moreText = dayTasks.length > 3
          ? '\n...and ${dayTasks.length - 3} more'
          : '';

      await _schedule(
        id: baseId + 1,
        title: '☀️ ${dayTasks.length} tasks for today',
        body: '$taskListText$moreText',
        scheduledTime: morningTime,
      );
    }

    final eveningTime = DateTime(date.year, date.month, date.day, 20, 0);
    final unfinishedTasks = dayTasks.where((t) => !t.isCompleted).toList();

    if (eveningTime.isAfter(now) && unfinishedTasks.isNotEmpty) {
      final taskListText = unfinishedTasks
          .take(3)
          .map((t) => '• ${t.title}')
          .join('\n');
      final moreText = unfinishedTasks.length > 3
          ? '\n...and ${unfinishedTasks.length - 3} more'
          : '';

      await _schedule(
        id: baseId + 2,
        title: '🌙 ${unfinishedTasks.length} unfinished tasks left',
        body: '$taskListText$moreText',
        scheduledTime: eveningTime,
      );
    }
  }

  Future<void> _schedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    final delay = scheduledTime.difference(DateTime.now());
    if (delay.isNegative) return;

    final tzTime = tz.TZDateTime.now(tz.local).add(delay);

    const androidDetails = AndroidNotificationDetails(
      'schedule_channel',
      'Schedule Notifications',
      channelDescription: 'Notifications for events and tasks',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tzTime,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}
