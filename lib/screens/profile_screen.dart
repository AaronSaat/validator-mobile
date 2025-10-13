import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:validator/screens/login_screen.dart';
import 'package:validator/services/api_service.dart';
import 'package:validator/utils/appcolors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _userId = 0;
  String _name = '';
  String _email = '';
  bool isLoading = false;
  bool isLoadingLogout = false;
  String? errorMsg;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    loadProfileData();
    print('ProfileScreen successfully initialized');
    loadNotificationSetting();
    print('Notification setting loaded: $_notificationsEnabled');
  }

  Future<void> loadNotificationSetting() async {
    setState(() {
      isLoading = true;
    });
    try {
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      final response = await ApiService.getNotificationSetting(
        fcmToken: fcmToken ?? '',
      );
      print('API response: $response');
      if (response != null && response['success'] == true) {
        final allowNotification = response['allow_notification'] == 1
            ? true
            : false;
        setState(() {
          _notificationsEnabled = allowNotification;
        });
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('notifications_enabled', allowNotification);
      }
    } catch (e) {
      print('Error loading notification setting: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> logout() async {
    setState(() {
      isLoadingLogout = true;
      errorMsg = null;
    });
    try {
      FirebaseMessaging.instance.unsubscribeFromTopic('validator');
      String fcmToken = await FirebaseMessaging.instance.getToken() ?? '';
      await ApiService.deleteUserDevice(
        fcmToken: fcmToken,
      ).timeout(const Duration(seconds: 7));
      await FirebaseMessaging.instance.deleteToken();

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      print('Logout error: $e');
      setState(() {
        errorMsg = 'Logout failed: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoadingLogout = false;
        });
      }
    }
  }

  Future<void> loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('id') ?? 0;
      _name = prefs.getString('nama') ?? 'No Name';
      _email = prefs.getString('email') ?? 'No Email';
    });
  }

  Future<void> handleNotificationSwitch(bool value) async {
    setState(() {
      isLoading = true;
      _notificationsEnabled = value;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    try {
      if (value) {
        FirebaseMessaging.instance.subscribeToTopic('validator');
      } else {
        FirebaseMessaging.instance.unsubscribeFromTopic('validator');
      }
      ApiService.saveNotificationSetting(
        userId: _userId,
        allowed: value ? 1 : 0,
      );
    } catch (e) {
      print('Error updating notification setting: $e');
      setState(() {
        errorMsg = 'Gagal mengubah pengaturan notifikasi: $e';
        _notificationsEnabled = !value; // rollback switch
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (isLoading)
                Center(
                  child: LoadingAnimationWidget.beat(
                    color: Colors.white,
                    size: 80,
                  ),
                )
              else if (errorMsg != null)
                Center(child: Text(errorMsg!))
              else ...[
                Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  color: AppColors.baseBackground,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 24),
                        const Center(
                          child: Icon(
                            Icons.account_circle,
                            color: Colors.black,
                            size: 100,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Name:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Email:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _email,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.notifications,
                                        color: Colors.black,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Notifikasi',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Spacer(),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Aktifkan Semua Notifikasi',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'untuk seluruh perangkat yang\nmasuk dengan akun $_name',
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 8),
                                      const Spacer(),
                                      Switch(
                                        value: _notificationsEnabled,
                                        activeColor: AppColors.primary,
                                        onChanged: (value) async {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: Text(
                                                value
                                                    ? 'Aktifkan Semua Notifikasi?'
                                                    : 'Nonaktifkan Semua Notifikasi?',
                                              ),
                                              content: Text(
                                                value
                                                    ? 'Anda akan mengaktifkan notifikasi untuk seluruh perangkat yang masuk dengan akun ${_name}. Lanjutkan?'
                                                    : 'Anda akan menonaktifkan notifikasi untuk seluruh perangkat yang masuk dengan akun ${_name}. Lanjutkan?',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.of(
                                                    context,
                                                  ).pop(false),
                                                  child: const Text('Batal'),
                                                ),
                                                TextButton(
                                                  onPressed: () => Navigator.of(
                                                    context,
                                                  ).pop(true),
                                                  child: const Text('OK'),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (confirm == true) {
                                            await handleNotificationSwitch(
                                              value,
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            isLoadingLogout
                                ? Container(
                                    width: double.infinity,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: AppColors.greyLight,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    alignment: Alignment.center,
                                    child: const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : GestureDetector(
                                    onTap: () async {
                                      await logout();
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      alignment: Alignment.center,
                                      child: const Text(
                                        'Logout',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
