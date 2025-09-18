// lib/services/api_service.dart

import 'dart:async' show TimeoutException;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:validator/screens/login_screen.dart';
import 'package:validator/utils/globalvariables.dart';

class ApiService {
  static const String baseurl = GlobalVariables.baseApiUrl;
  // static const String baseurl = 'https://netunim.seabs.ac.id/api-syc2025/';

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
      throw Exception('Unexpected error: $e');
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
      body: json.encode({'user_id': userId, 'search': search}),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch persetujuan');
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
        'keterangan': keterangan,
      }),
    );
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
      body: json.encode({'user_id': userId, 'search': search}),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch transaksi gantung');
    }
  }

  static Future<Map<String, dynamic>> konfirmasiBarangtiba({
    required int userId,
    String search = '',
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
      body: json.encode({'user_id': userId, 'search': search}),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch konfirmasi barang tiba');
    }
  }

  static Future<Map<String, dynamic>> arsipTransaksiKembali({
    required int userId,
    required String username,
    String search = '',
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
      body: json.encode({'user_id': userId, 'username': username, 'search': search}),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch arsip transaksi kembali');
    }
  }

  static Future<Map<String, dynamic>> arsipTransaksi({
    required int userId,
    String jenis = '',
    String tgl_pengajuan = '',
    String tgl_pengajuan_akhir = '',
    String search = '',
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
      body: json.encode({'user_id': userId, 'jenis': jenis, 'tgl_pengajuan': tgl_pengajuan, 'tgl_pengajuan_akhir': tgl_pengajuan_akhir, 'search': search}),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch arsip transaksi  ');
    }
  }

  static Future<Map<String, dynamic>> pembayaranView({
    required String idBayar,
    required String userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse('${baseurl}pembayaran-view');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'id_bayar': idBayar, 'user_id': userId}),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch pembayaran view');
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
