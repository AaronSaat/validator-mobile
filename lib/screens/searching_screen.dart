import 'package:flutter/material.dart';
import 'package:validator/screens/butuh_persetujuan_screen.dart';
import 'package:validator/screens/transaksi_gantung_screen.dart';
import 'package:validator/utils/appcolors.dart';

class SearchingScreen extends StatefulWidget {
  final String fromScreen;
  const SearchingScreen({Key? key, required this.fromScreen}) : super(key: key);

  @override
  State<SearchingScreen> createState() => _SearchingScreenState();
}

class _SearchingScreenState extends State<SearchingScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Open keyboard automatically
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchSubmitted(String query) {
    if (widget.fromScreen == 'butuh_persetujuan') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              ButuhPersetujuanScreen(search: _searchController.text),
        ),
      );
    } else if (widget.fromScreen == 'transaksi_gantung') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              TransaksiGantungScreen(search: _searchController.text),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Pencarian'),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: AppColors.baseBackground,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      FocusScope.of(context).requestFocus(_focusNode);
                    },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          const Icon(Icons.search, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              focusNode: _focusNode,
                              decoration: InputDecoration(
                                hintText: widget.fromScreen == 'butuh_persetujuan'
                                  ? 'Cari PPB/PJL Butuh Persetujuan...'
                                  : widget.fromScreen == 'transaksi_gantung'
                                    ? 'Cari Transaksi Gantung...'
                                    : 'Type to search...',
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              style: const TextStyle(
                                color: AppColors.textblack,
                                fontSize: 14,
                              ),
                              textInputAction: TextInputAction.go,
                              onSubmitted: _onSearchSubmitted,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_forward,
                              color: Colors.grey,
                            ),
                            onPressed: () =>
                                _onSearchSubmitted(_searchController.text),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(color: AppColors.orange),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          // Icon dan text di ujung kiri
                          const Icon(
                            Icons.info_outline,
                            color: AppColors.black,
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Lakukan pencarian berdasarkan:',
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12,
                                  color: AppColors.textwhite,
                                ),
                              ),
                              Text(
                                widget.fromScreen == 'butuh_persetujuan'
                                  ? 'No. PPB/PJL, Nama Pemohon,\nKeterangan/Keperluan'
                                  : widget.fromScreen == 'transaksi_gantung'
                                    ? 'No. PPB/PJL, Nama Pemohon, Keperluan,\nTunai/Transfer'
                                    : "",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: AppColors.textwhite,
                                ),
                                maxLines: 3,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
