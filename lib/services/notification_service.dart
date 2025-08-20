import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import '../models/task.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notifications.initialize(initializationSettings);
    
    await _requestPermissions();
    
    _isInitialized = true;
  }

  static Future<void> _requestPermissions() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  static Future<void> scheduleTaskReminder(Task task) async {
    if (!_isInitialized) await initialize();

    try {
      final reminderTime = task.deadline.subtract(const Duration(days: 1));
      
      if (reminderTime.isAfter(DateTime.now())) {
        await _notifications.zonedSchedule(
          task.id ?? 0,
          'Przypomnienie o zadaniu',
          'Jutro mija termin zadania: ${task.title}',
          tz.TZDateTime.from(reminderTime, tz.local),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'task_reminders',
              'Przypomnienia o zadaniach',
              channelDescription: 'Powiadomienia o zbliżających się terminach zadań',
              importance: Importance.high,
              priority: Priority.high,
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      }

      if (task.deadline.isAfter(DateTime.now())) {
        final deadlineReminder = DateTime(
          task.deadline.year,
          task.deadline.month,
          task.deadline.day,
          9,
        );

        if (deadlineReminder.isAfter(DateTime.now())) {
          await _notifications.zonedSchedule(
            (task.id ?? 0) + 10000,
            'Termin zadania dzisiaj!',
            'Dzisiaj mija termin zadania: ${task.title}',
            tz.TZDateTime.from(deadlineReminder, tz.local),
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'task_deadlines',
                'Terminy zadań',
                channelDescription: 'Powiadomienia o terminach zadań',
                importance: Importance.max,
                priority: Priority.max,
              ),
              iOS: DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
              ),
            ),
            uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
            matchDateTimeComponents: DateTimeComponents.time,
          );
        }
      }
    } catch (e) {
      print('Błąd planowania powiadomienia: $e');
    }
  }

  static Future<void> cancelTaskReminder(int taskId) async {
    await _notifications.cancel(taskId);
    await _notifications.cancel(taskId + 10000);
  }

  static Future<void> cancelAllReminders() async {
    await _notifications.cancelAll();
  }
}
