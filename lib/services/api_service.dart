// lib/services/api_service.dart

import 'dart:async' show TimeoutException;
import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:validator/screens/login_screen.dart';
import 'package:validator/utils/globalvariables.dart';

class ApiService {
  static const String baseurl = GlobalVariables.baseApiUrl;
  // static const String baseurl = 'https://netunim.seabs.ac.id/api-syc2025/';

  static Future<Map<String, dynamic>> validateUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      if (token.isEmpty) {
        throw Exception('Token not found');
      }
      final url = Uri.parse('${baseurl}validate-user');
      final response = await http
          .get(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      print('URL: $url');
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'User validation failed');
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: $e');
    } on TimeoutException {
      throw Exception('Request timed out');
    } catch (e) {
      print('Error: $e');
      throw Exception('$e');
    }
  }

  static Future<Map<String, dynamic>> checkUser(
    String username,
    String password,
  ) async {
    try {
      final url = Uri.parse('${baseurl}check-user');
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'username': username, 'password': password}),
          )
          .timeout(const Duration(seconds: 10));

      print('URL: $url');
      print(
        'Request Body: ${json.encode({'username': username, 'password': password})}',
      );
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Login failed');
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: $e');
    } on TimeoutException {
      throw Exception('Request timed out');
    } catch (e) {
      print('Error: $e');
      throw Exception('$e');
    }
  }

  static Future<Map<String, dynamic>> checkVersion({
    required String version,
  }) async {
    try {
      final url = Uri.parse('${baseurl}check-version');
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'user_version': version}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Check version failed');
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: $e');
    } on TimeoutException {
      throw Exception('Request timed out');
    } catch (e) {
      print('Error: $e');
      throw Exception('$e');
    }
  }

  static Future<Map<String, dynamic>> saveUserDevice({
    required String userId,
    required String username,
    required String fcmToken,
    required String platform,
    required String deviceModel,
    required String deviceManufacturer,
    required String deviceVersion,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse('${baseurl}save-user-device');
    final response = await http
        .post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode({
            'user_id': userId,
            'username': username,
            'fcm_token': fcmToken,
            'platform': platform,
            'device_model': deviceModel,
            'device_manufacturer': deviceManufacturer,
            'device_version': deviceVersion,
          }),
        )
        .timeout(const Duration(seconds: 10));

    print(
      'Request Body: ${json.encode({'user_id': userId, 'username': username, 'fcm_token': fcmToken, 'platform': platform, 'device_model': deviceModel, 'device_manufacturer': deviceManufacturer, 'device_version': deviceVersion})}',
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Save user device failed');
    }
  }

  static Future<Map<String, dynamic>> deleteUserDevice({
    required String fcmToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse('${baseurl}delete-user-device');
    final response = await http
        .post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode({'fcm_token': fcmToken}),
        )
        .timeout(const Duration(seconds: 10));

    print('Request Body: ${json.encode({'fcm_token': fcmToken})}');
    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Delete user device failed');
    }
  }

  static Future<Map<String, dynamic>> deleteUser({
    required String userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse('${baseurl}delete-user');
    final response = await http
        .post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode({'user_id': userId}),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Delete user device failed');
    }
  }

  static Future<Map<String, dynamic>> getNotificationSetting({
    required String fcmToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse('${baseurl}get-notification-setting');
    final response = await http
        .post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode({'fcm_token': fcmToken}),
        )
        .timeout(const Duration(seconds: 10));

    print('url: $url');
    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Get notification setting failed');
    }
  }

  static Future<Map<String, dynamic>> saveNotificationSetting({
    required int userId,
    required int allowed,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse('${baseurl}save-notification-setting');
    final response = await http
        .post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode({'user_id': userId, 'allowed': allowed}),
        )
        .timeout(const Duration(seconds: 10));

    print('url: $url');
    print(
      'Request Body: ${json.encode({'user_id': userId, 'allowed': allowed})}',
    );
    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Save notification setting failed');
    }
  }

  static Future<Map<String, dynamic>> siteIndex({required int userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse('${baseurl}site-index');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'user_id': userId}),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch site index');
    }
  }

  static Future<Map<String, dynamic>> persetujuan({
    required int userId,
    String search = '',
    required int page,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse('${baseurl}persetujuan');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'user_id': userId, 'search': search, 'page': page}),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Failed to fetch persetujuan');
    }
  }

  static Future<Map<String, dynamic>> pembelianTambahDetailApproval({
    required String pembelianId,
    required String userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse('${baseurl}pembelian-tambah-detail-approval');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'user_id': userId, 'approval_id': pembelianId}),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch pembelian tambah detail approval');
    }
  }

  static Future<Map<String, dynamic>> pembelianApproval({
    required int pembelianId,
    required int userId,
    required int approve,
    required int level,
    required int status,
    required int idDivisi,
    required int branch,
    required String keterangan,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse('${baseurl}pembelian-approval');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'id_pembelian': pembelianId,
        'user_id': userId,
        'approve': approve,
        'level': level,
        'status': status,
        'branch': branch,
        'id_divisi': idDivisi,
        'keterangan': keterangan,
      }),
    );

    print('URL: $url');
    print(
      'Request Body: ${json.encode({'id_pembelian': pembelianId, 'user_id': userId, 'approve': approve, 'level': level, 'status': status, 'branch': branch, 'id_divisi': idDivisi, 'keterangan': keterangan})}',
    );
    print('response body: ${response.body}');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch pembelian approval');
    }
  }

  static Future<Map<String, dynamic>> beforeAction({
    required int userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse('${baseurl}before-action');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'user_id': userId}),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch before action');
    }
  }

  static Future<Map<String, dynamic>> transaksiGantung({
    required int userId,
    String search = '',
    required int page,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse('${baseurl}transaksi-gantung');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'user_id': userId, 'search': search, 'page': page}),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Failed to fetch persetujuan');
    }
  }

  static Future<Map<String, dynamic>> konfirmasiBarangtiba({
    required int userId,
    String search = '',
    required int page,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse('${baseurl}konfirmasi-barang-tiba');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'user_id': userId, 'search': search, 'page': page}),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Failed to fetch persetujuan');
    }
  }

  static Future<Map<String, dynamic>> arsipTransaksiKembali({
    required int userId,
    required String username,
    String search = '',
    required int page,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse('${baseurl}arsip-transaksi-kembali');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'user_id': userId,
        'username': username,
        'search': search,
        'page': page,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(
        error['message'] ?? 'Failed to fetch arsip transaksi kembali',
      );
    }
  }

  static Future<Map<String, dynamic>> arsipTransaksi({
    required int userId,
    String jenis = '',
    String tgl_pengajuan = '',
    String tgl_pengajuan_akhir = '',
    String search = '',
    required int page,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse('${baseurl}arsip-transaksi');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'user_id': userId,
        'jenis': jenis,
        'tgl_pengajuan': tgl_pengajuan,
        'tgl_pengajuan_akhir': tgl_pengajuan_akhir,
        'search': search,
        'page': page,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Failed to fetch persetujuan');
    }
  }

  static Future<Map<String, dynamic>> pembayaranViewValidator({
    required String idBayar,
    required String userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse('${baseurl}pembayaran-view-validator');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'id_bayar': idBayar, 'user_id': userId}),
    );

    print('URL: $url');
    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch pembayaran view');
    }
  }

  static Future<Map<String, dynamic>> konfirmasiBarangTibaApproval({
    required String idBayar,
    required String userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse('${baseurl}konfirmasi-barang-tiba-approval');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'id_bayar': idBayar, 'user_id': userId}),
    );

    print('URL: $url');
    print(
      'Request Body: ${json.encode({'id_bayar': idBayar, 'user_id': userId})}',
    );
    print('Response Status: ${response.statusCode}');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch konfirmasi barang tiba');
    }
  }

  static Future<Map<String, dynamic>> barangTibaApproval({
    required int bayarId,
    required int userId,
    required int approve,
    required int idDivisi,
    required int branch,
    required String keterangan,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse('${baseurl}barang-tiba-approval');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'id_bayar': bayarId,
        'user_id': userId,
        'approve': approve,
        'id_divisi': idDivisi,
        'branch': branch,
        'keterangan': keterangan,
      }),
    );

    print('URL: $url');
    print('response body: ${response.body}');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch barang tiba approval');
    }
  }

  // static Future<bool> validateToken(
  //   BuildContext context, {
  //   required String token,
  // }) async {
  //   if (token == null || token.isEmpty) {
  //     Navigator.of(context).pushReplacement(
  //       MaterialPageRoute(builder: (context) => const LoginScreen()),
  //     );
  //   }

  //   final url = Uri.parse('${baseurl}brm-today');
  //   final response = await http.get(
  //     url,
  //     headers: {
  //       'Authorization': 'Bearer $token',
  //       'Content-Type': 'application/json',
  //     },
  //   );

  //   if (response.statusCode == 200) {
  //     final Map<String, dynamic> dataBacaan = json.decode(response.body);
  //     return dataBacaan['success'];
  //   } else if (response.statusCode == 401) {
  //     showCustomSnackBar(
  //       context,
  //       'Sesi login Anda telah habis. Silakan login kembali.',
  //     );
  //     await handleUnauthorized(context);
  //     throw Exception('Unauthorized');
  //     // return false;
  //   } else {
  //     print('❌ Error test: ${response.statusCode} - ${response.body}');
  //     throw Exception('Failed to validate token');
  //     // return false;
  //   }
  // }
}
