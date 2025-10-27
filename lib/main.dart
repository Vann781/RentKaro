// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart' show Firebase;
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'firebase_options.dart';
// import 'screens/login_screen.dart';
// import 'screens/main_screen.dart';
//
// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
// FlutterLocalNotificationsPlugin();
//
// // --- TOP LEVEL HANDLER (Required for background messages) ---
// @pragma('vm:entry-point') // Required for background execution
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   // If you use Firebase services, you must initialize them here.
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   print("Handling a background message: ${message.messageId}");
// }
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   // Initialize Firebase Core
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//
//   // 1. Initialize local notifications settings (Android and iOS)
//   const AndroidInitializationSettings initializationSettingsAndroid =
//   AndroidInitializationSettings('@mipmap/ic_launcher');
//
//   const InitializationSettings initializationSettings = InitializationSettings(
//     android: initializationSettingsAndroid,
//   );
//
//   // *** FIX: Correct variable name used here ***
//   await flutterLocalNotificationsPlugin.initialize(initializationSettings);
//
//   // 2. Set up notification channel for Android (CRITICAL for heads-up alerts)
//   const AndroidNotificationChannel channel = AndroidNotificationChannel(
//     'high_importance_channel', // ID (Must be consistent)
//     'Chat Messages',
//     description: 'Notifications for incoming chat messages.',
//     importance: Importance.high, // HIGH for heads-up pop-up
//   );
//
//   await flutterLocalNotificationsPlugin
//       .resolvePlatformSpecificImplementation<
//       AndroidFlutterLocalNotificationsPlugin>()
//       ?.createNotificationChannel(channel);
//
//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//
//   // 3. Handle Foreground Messages (Triggers the local pop-up)
//   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//     print('Got a message whilst in the foreground!');
//
//     RemoteNotification? notification = message.notification;
//
//     if (notification != null) {
//       flutterLocalNotificationsPlugin.show(
//         notification.hashCode,
//         notification.title ?? 'New Message',
//         notification.body ?? 'Check your chat.',
//         NotificationDetails(
//           android: AndroidNotificationDetails(
//             channel.id, // Use the high importance channel
//             channel.name,
//             icon: 'launch_background',
//             importance: Importance.high,
//           ),
//         ),
//         payload: message.data['conversation_id'], // Data passed on tap
//       );
//     }
//   });
//
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     // Flipkart ka primary blue
//     final Color primaryColor = Colors.blue.shade800;
//     // Amazon/Flipkart ka accent color
//     final Color secondaryColor = Colors.orange.shade700;
//
//     return MaterialApp(
//       title: 'RentKaro',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         useMaterial3: true,
//         primaryColor: primaryColor,
//
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: primaryColor,
//           primary: primaryColor,
//           secondary: secondaryColor,
//           brightness: Brightness.light,
//         ),
//
//         // Custom AppBar theme from earlier
//         appBarTheme: const AppBarTheme(
//           foregroundColor: Colors.white,
//           iconTheme: IconThemeData(color: Colors.white),
//           titleTextStyle: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//           elevation: 4.0,
//         ),
//
//         // Custom Floating Button theme
//         floatingActionButtonTheme: FloatingActionButtonThemeData(
//           backgroundColor: secondaryColor,
//           foregroundColor: Colors.white,
//         ),
//       ),
//       home: const LoginScreen(),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firebase_options.dart';
import 'screens/check_auth_screen.dart'; // <-- NEW IMPORT

// 1. Initialize the local notifications plugin globally
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

// --- TOP LEVEL HANDLER (Required for background messages) ---
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase Core
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 1. Initialize local notifications settings (Android and iOS)
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // 2. Set up notification channel for Android
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'Chat Messages',
    description: 'Notifications for incoming chat messages.',
    importance: Importance.high,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 3. Handle Foreground Messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');

    RemoteNotification? notification = message.notification;

    if (notification != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title ?? 'New Message',
        notification.body ?? 'Check your chat.',
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            icon: 'launch_background',
            importance: Importance.high,
          ),
        ),
        payload: message.data['conversation_id'],
      );
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryNavy = Color(0xFF0A1F44); // Dark Navy Blue
    final Color accentDarkYellow = Color(0xFFFFA000); // Darker, rich Yellow/Orange
    final Color backgroundLight = Colors.grey.shade50;
    final Color textLight = Colors.grey.shade400; // For secondary text

    return MaterialApp(
      title: 'RentKaro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: primaryNavy, // Main primary color
        scaffoldBackgroundColor: backgroundLight,

        // Naya color scheme
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryNavy,
          primary: primaryNavy,
          secondary: accentDarkYellow, // Accent color
          background: backgroundLight,
          brightness: Brightness.light,
        ),

        // Custom AppBar Theme (for gradient)
        appBarTheme: AppBarTheme(
          foregroundColor: Colors.white, // White text/icons
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 2.0,

          // Update text style for a better look
          titleTextStyle: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontFamily: 'Montserrat', // Suggestion for a better font (requires adding font family)
          ),
        ),

        // Floating Button Theme
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: accentDarkYellow,
          foregroundColor: Colors.white,
        ),

        // Bottom Bar Theme
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: primaryNavy,
          unselectedItemColor: Colors.grey.shade600,
          backgroundColor: Colors.white,
          elevation: 8.0,
        ),
      ),
      home: const CheckAuthScreen(),
    );
  }
}