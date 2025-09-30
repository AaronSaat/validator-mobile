import 'package:flutter/material.dart';
import 'package:validator/screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Request notification permission khusus iOS
  if (Platform.isIOS) {
    NotificationSettings settings = await FirebaseMessaging.instance
        .requestPermission(alert: true, badge: true, sound: true);
    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      // Listen for token refresh (APNS token ready)
      FirebaseMessaging.instance.onTokenRefresh.listen((token) {
        print('FCM Token (onTokenRefresh): $token');
      });
      // Optionally, try getToken() (will return null if APNS belum siap)
      String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      String? token = await FirebaseMessaging.instance.getToken();
      print('FCM Token (getAPNSToken): $apnsToken');
      print('FCM Token (getToken): $token');
    } else {
      print('User declined or has not accepted notification permissions');
    }
  } else if (Platform.isAndroid) {
    String? token = await FirebaseMessaging.instance.getToken();
    print('FCM Token (Android): $token');
    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      print('FCM Token (Android onTokenRefresh): $token');
    });
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vallidator Pengadaan',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/login',
      routes: {'/login': (context) => const LoginScreen()},
    );
  }
}
