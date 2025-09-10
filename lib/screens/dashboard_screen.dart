import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:validator/screens/login_screen.dart';
import 'package:validator/services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? username, email, nama, userId;
  List<dynamic> persetujuanList = [];
  int? totalDibutuhkan;
  bool isLoading = true;
  String? errorMsg;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? '';
      email = prefs.getString('email') ?? '';
      nama = prefs.getString('nama') ?? '';
      userId = prefs.getInt('id')?.toString() ?? '';
    });
    _fetchPersetujuan();
  }

  Future<void> _fetchPersetujuan() async {
    setState(() {
      isLoading = true;
      errorMsg = null;
    });
    try {
      final result = await ApiService.persetujuan(
        userId: userId.toString() ?? '',
        search: '',
      );
      if (result['success'] == true) {
        setState(() {
          persetujuanList = result['data'] ?? [];
          totalDibutuhkan = result['total_dibutuhkan'] is int
              ? result['total_dibutuhkan']
              : int.tryParse(result['total_dibutuhkan']?.toString() ?? '');
        });
      } else {
        setState(() {
          errorMsg = result['message'] ?? 'Failed to fetch data';
        });
      }
    } catch (e) {
      setState(() {
        errorMsg = e.toString();
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
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: IconButton(
              icon: const Icon(Icons.logout, color: Colors.black),
              tooltip: 'Logout',
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            child: Image.asset(
              'assets/images/background_login.jpg',
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              fit: BoxFit.fill,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'User Info',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text('Username: ${username ?? ''}'),
                          Text('Name: ${nama ?? ''}'),
                          Text('Email: ${email ?? ''}'),
                        ],
                      ),
                    ),
                  ),
                ),
                if (isLoading)
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (errorMsg != null)
                  Expanded(child: Center(child: Text(errorMsg!)))
                else ...[
                  if (totalDibutuhkan != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Total Biaya Dibutuhkan: Rp$totalDibutuhkan',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: persetujuanList.length,
                      itemBuilder: (context, index) {
                        final item = persetujuanList[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            title: Text(item['no_ppb'] ?? '-'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Nama: ${item['nama_pemohon'] ?? '-'}'),
                                Text(
                                  'Jabatan: ${item['jabatan_pemohon'] ?? '-'}',
                                ),
                                Text(
                                  'Keterangan: ${item['keterangan'] ?? '-'}',
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
