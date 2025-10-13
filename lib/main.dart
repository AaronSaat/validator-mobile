import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:validator/screens/butuh_persetujuan_screen.dart';
import 'package:validator/screens/dashboard_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:validator/screens/detail_butuh_persetujuan_screen.dart';
import 'package:validator/screens/splash_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Get APNs token for iOS
  if (Platform.isIOS) {
    String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
    print('APNs Token: $apnsToken');
  }

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    // Navigasi ke screen sesuai data notifikasi
    final tujuan = message.data['tujuan']?.toString() ?? '';
    final id = int.tryParse(message.data['id']?.toString() ?? '0') ?? 0;
    final userId =
        int.tryParse(message.data['user_id']?.toString() ?? '0') ?? 0;
    print('Navigating with tujuan: $tujuan, id: $id, userId: $userId');

    switch (tujuan) {
      case 'butuh_persetujuan':
        print('Navigating to Splash Screen');
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => SplashScreen(
              fromNotification: true,
              tujuan: tujuan,
              id: id,
              userId: userId,
            ),
          ),
        );
        break;
      case 'detail_butuh_persetujuan':
        print('Navigating to Splash Screen');
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => SplashScreen(
              fromNotification: true,
              tujuan: tujuan,
              id: id,
              userId: userId,
            ),
          ),
        );
        break;
      case 'butuh_konfirmasi_penyelesaian':
        print('Navigating to Splash Screen');
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => SplashScreen(
              fromNotification: true,
              tujuan: tujuan,
              id: id,
              userId: userId,
            ),
          ),
        );
        break;
      case 'detail_butuh_konfirmasi_penyelesaian':
        print('Navigating to Splash Screen');
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => SplashScreen(
              fromNotification: true,
              tujuan: tujuan,
              id: id,
              userId: userId,
            ),
          ),
        );
        break;
      default:
        // Default action jika screen tidak dikenali
        print('Navigating to Dashboard Screen');
        navigatorKey.currentState?.pushReplacement(
          MaterialPageRoute(
            builder: (_) =>
                const DashboardScreen(fromScreen: 'notifikasi_dashboard'),
          ),
        );
        break;
    }
  });

  if (Platform.isIOS) {
    NotificationSettings settings = await FirebaseMessaging.instance
        .requestPermission(alert: true, badge: true, sound: true);
    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      // Baru di sini boleh subscribe topic atau getToken
      FirebaseMessaging.instance.subscribeToTopic('validator');
    }
  } else if (Platform.isAndroid) {
    // Request notification permission for Android 13+ (API 33+)
    try {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      if (deviceInfo.version.sdkInt >= 33) {
        // ignore: use_build_context_synchronously
        final permission = await Permission.notification.request();
        if (permission.isGranted) {
          print('Android notification permission granted');
        } else {
          print('Android notification permission denied');
        }
      }
    } catch (e) {
      print('Error requesting Android notification permission: $e');
    }
  }
  FirebaseMessaging.instance.subscribeToTopic('validator');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Vallidator Pengadaan',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(fromNotification: false),
      },
    );
  }
}
