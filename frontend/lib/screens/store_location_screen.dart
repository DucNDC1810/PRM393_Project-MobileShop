import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StoreLocationScreen extends StatelessWidget {
  const StoreLocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Hệ thống cửa hàng',
          style: TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primary,
        elevation: 0.5,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('store_locations')
            .where('is_active', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          final Map<String, dynamic> store = docs.isNotEmpty 
              ? docs.first.data() as Map<String, dynamic> 
              : {
                  'name': 'Beauty & Glow — Chi nhánh Hà Nội',
                  'address': '123 Đường Cầu Giấy, Quận Cầu Giấy, Hà Nội',
                  'hotline': '19001234',
                  'hours': '8:30 – 21:30 (Thứ 2 – Chủ Nhật)',
                  'website': 'www.beautyglow.vn',
                };

          final String storeName = store['name'] ?? 'Beauty & Glow Store';
          final String address = store['address'] ?? '123 Cầu Giấy, Hà Nội';
          final String hotline = store['hotline'] ?? '19001234';
          final String hours = store['hours'] ?? '8:30 - 21:30';

          return Stack(
            children: [
              // Simulated Map View (Minimalist Vector Map Look matching premium design UI)
              Positioned.fill(
                bottom: 250,
                child: Container(
                  color: const Color(0xFFECEFF1),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Grid background pattern to simulate maps
                      Opacity(
                        opacity: 0.15,
                        child: GridPaper(
                          color: AppColors.primary,
                          divisions: 2,
                          interval: 100,
                          subdivisions: 1,
                        ),
                      ),
                      // Map roads simulation
                      Positioned(
                        top: 150,
                        left: 0,
                        right: 0,
                        child: Container(height: 24, color: Colors.white),
                      ),
                      Positioned(
                        left: 180,
                        top: 0,
                        bottom: 0,
                        child: Container(width: 24, color: Colors.white),
                      ),
                      // Custom Marker Pin
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                              ],
                            ),
                            child: const Text(
                              'Flagship Store',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'DM Sans',
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Icon(
                            Icons.location_on,
                            color: AppColors.primary,
                            size: 44,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Sheet Card Info
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 280,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 16,
                        offset: Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.outlineVariant,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryFixed,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'ĐANG MỞ CỬA',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'DM Sans',
                              ),
                            ),
                          ),
                          const Icon(Icons.storefront, color: AppColors.primary, size: 24),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        storeName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.onSurface,
                          fontFamily: 'DM Sans',
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Details
                      Expanded(
                        child: Column(
                          children: [
                            _infoRow(Icons.location_on_outlined, address),
                            const SizedBox(height: 8),
                            _infoRow(Icons.call_outlined, 'Hotline: $hotline'),
                            const SizedBox(height: 8),
                            _infoRow(Icons.schedule_outlined, 'Giờ hoạt động: $hours'),
                          ],
                        ),
                      ),
                      // Action Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.directions, size: 20),
                          label: const Text(
                            'Chỉ đường',
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
              fontFamily: 'DM Sans',
            ),
          ),
        ),
      ],
    );
  }
}
