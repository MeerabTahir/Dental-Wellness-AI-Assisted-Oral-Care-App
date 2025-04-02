import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class DailyTipsPage extends StatefulWidget {
  @override
  _DailyTipsPageState createState() => _DailyTipsPageState();
}

class _DailyTipsPageState extends State<DailyTipsPage> {
  final List<String> _tips = [
    "Brush your teeth twice a day.",
    "Floss daily to remove plaque.",
    "Visit your dentist regularly.",
    "Eat a balanced diet for healthy teeth.",
    "Avoid sugary snacks and drinks.",
    "Use fluoride toothpaste.",
    "Replace your toothbrush every 3-4 months.",
    "Drink plenty of water.",
    "Wear a mouthguard during sports."
  ];

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    _initializeNotifications();
    _scheduleDailyNotification();
  }

  void _initializeNotifications() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void _scheduleDailyNotification() {
    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      'Daily Tips',
      'Daily dental tips reminder',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);

    final now = DateTime.now();
    final location = tz.getLocation('Asia/Karachi');
    final scheduledNotificationDateTime = tz.TZDateTime(
      location,
      now.year,
      now.month,
      now.day,
      11,
      0,
      0,
    );

    flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Daily Dental Tip',
      'Check out today\'s dental tip!',
      scheduledNotificationDateTime,
      notificationDetails,
      androidAllowWhileIdle: true,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Dental Tips'),
      ),
      body: ListView.builder(
        itemCount: _tips.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_tips[index]),
          );
        },
      ),
    );
  }
}
