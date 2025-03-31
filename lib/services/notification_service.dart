import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Use the app's launcher icon instead of app_icon
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: DarwinInitializationSettings(), // For iOS if needed
        );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
      },
    );
  }

  Future<void> showProxyAddedNotification(
    String proxyIp,
    String proxyPort,
  ) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'proxy_channel_id',
          'Proxy Notifications',
          channelDescription: 'Notifications for proxy status',
          importance: Importance.high,
          priority: Priority.high,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      'New Proxy Added',
      'Proxy $proxyIp:$proxyPort has been added',
      platformChannelSpecifics,
    );
  }
}
