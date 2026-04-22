import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../../data/models/lot_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {},
    );

    await requestPermissions();
  }

  Future<void> requestPermissions() async {
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> showImmediateNotification() async {
    try {
      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: AndroidNotificationDetails('test_id', 'test_name'),
        iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentSound: true,
            presentBadge: true
        ),
      );

      await _notificationsPlugin.show(
        0,
        'Проверка связи',
        'Это уведомление должно появиться',
        platformChannelSpecifics,
      );
    } catch (e){}
  }

  Future<void> scheduleAuctionReminder(LotModel lot) async {
    if (lot.saleDate == null) return;

    final scheduledTime = lot.saleDate!.subtract(const Duration(minutes: 30));

    if (scheduledTime.isBefore(DateTime.now())) return;

    await _notificationsPlugin.zonedSchedule(
      lot.id.hashCode,
      'Auction Reminder',
      'Auction for ${lot.fullName} starts in 30 minutes!',
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'auction_reminders',
          'Auction Reminders',
          channelDescription: 'Notifications for upcoming auctions',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      payload: lot.id,
    );
  }

  Future<void> cancelReminder(String lotId) async {
    await _notificationsPlugin.cancel(lotId.hashCode);
  }

  Future<void> testNotification(LotModel lot) async {
    final now = tz.TZDateTime.now(tz.local);

    await _notificationsPlugin.zonedSchedule(
      999,
      'Auction Reminder (Test)',
      'Auction for ${lot.fullName} starts in 5 seconds!',
      now.add(const Duration(seconds: 5)),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'auction_reminders',
          'Auction Reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      payload: lot.id,
    );
  }
}
