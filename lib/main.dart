import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

import 'package:tooth_tales/route.dart';
import 'package:tooth_tales/screens/admin/adminhomepage.dart';
import 'package:tooth_tales/screens/doctor/doctorHomePage.dart';
import 'package:tooth_tales/screens/login.dart';
import 'package:tooth_tales/screens/user/homepage.dart';
import 'package:tooth_tales/start.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // Handle background notification taps
}

Future<bool> _requestNotificationPermissions() async {
  if (Platform.isAndroid) {
    try {
      final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      final bool? granted = await androidPlugin?.areNotificationsEnabled();
      return granted ?? false;
    } on PlatformException catch (e) {
      print('Error checking notification permissions: $e');
      return false;
    }
  }
  return true; // iOS or other platforms
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyCfwbX0BpGrCXB8o9WSVaPSS9kF5R482Ec',
      appId: '1:94725667875:android:cb3acf569488c8401ec596',
      messagingSenderId: '94725667875',
      projectId: 'tooth-tales',
      storageBucket: 'tooth-tales.appspot.com',
    ),
  );

  // Timezone setup
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Karachi'));

  // Create Notification Channel (Android)
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'appointment_channel',
    'Appointment Reminders',
    description: 'Reminders for your upcoming appointments',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  final androidFlutterLocalNotificationsPlugin =
  flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>();
  await androidFlutterLocalNotificationsPlugin
      ?.createNotificationChannel(channel);

  // Ask for notification permissions
  final bool hasPermission = await _requestNotificationPermissions();
  if (!hasPermission) {
    print('Notification permission not granted');
  }

  // Initialize Notifications
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings =
  InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      print('Notification tapped while app is in foreground');
    },
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );

  // Now launch the app
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget _initialScreen = const Scaffold(
    body: Center(child: CircularProgressIndicator()),
  );

  @override
  void initState() {
    super.initState();
    _determineInitialScreen();
  }

  Future<void> _determineInitialScreen() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    String? role = prefs.getString('role');

    Widget screen;

    if (isLoggedIn && role != null) {
      switch (role) {
        case 'admin':
          screen =
              AdminHomePage(adminId: "9zMrY7yPCFfQW3mG88cz47MlZau2"); // Hardcoded ID
          break;
        case 'doctor':
          screen = DoctorHomePage();
          break;
        default:
          screen = HomePage();
      }
    } else {
      screen = const LoginScreen();
    }

    setState(() {
      _initialScreen = screen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tooth Tales',
      debugShowCheckedModeBanner: false,
      home: _initialScreen,
      routes: appRoutes,
      onGenerateRoute: generateRoute,
    );
  }
}
