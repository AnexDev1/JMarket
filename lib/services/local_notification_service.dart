import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

 

  Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);
    await _flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  Future<void> showNotification({required String title, required String body}) async {
    const androidDetails = AndroidNotificationDetails(
      'order_status_channel',
      'Order Status Notifications',
      channelDescription: 'Notifications for order status updates',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iOSDetails = DarwinNotificationDetails();
    const notificationDetails = NotificationDetails(android: androidDetails, iOS: iOSDetails);
    await _flutterLocalNotificationsPlugin.show(0, title, body, notificationDetails);
  }
}