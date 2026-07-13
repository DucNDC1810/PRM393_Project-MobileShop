import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:project_mobileshop/core/theme/app_theme.dart';

class StoreLocationScreen extends StatefulWidget {
  const StoreLocationScreen({super.key});

  @override
  State<StoreLocationScreen> createState() => _StoreLocationScreenState();
}

class _StoreLocationScreenState extends State<StoreLocationScreen> {
  final MapController _mapController = MapController();
  final PageController _pageController = PageController(viewportFraction: 0.9);
  
  int _selectedStoreIndex = 0;
  LatLng? _userLocation;
  late Stream<QuerySnapshot> _storesStream;

  final List<Map<String, dynamic>> _defaultStores = [
    {
      'name': 'Beauty & Glow Cosmetics — Quận 1',
      'address': '456 Nguyễn Huệ, Quận 1, TP. Hồ Chí Minh',
      'hotline': '0909 888 777',
      'hours': '9:00 – 22:00 (Thứ 2 – Chủ Nhật)',
      'website': 'www.beautyandglow.vn',
      'location': const LatLng(10.774431, 106.703273),
    },
    {
      'name': 'Beauty & Glow Cosmetics — Quận 7',
      'address': '101 Tôn Dật Tiên, Quận 7, TP. Hồ Chí Minh',
      'hotline': '0909 888 778',
      'hours': '9:00 – 22:00 (Thứ 2 – Chủ Nhật)',
      'website': 'www.beautyandglow.vn',
      'location': const LatLng(10.732668, 106.701755),
    },
    {
      'name': 'Beauty & Glow Cosmetics — Gò Vấp',
      'address': '190 Quang Trung, Gò Vấp, TP. Hồ Chí Minh',
      'hotline': '0909 888 779',
      'hours': '9:00 – 22:00 (Thứ 2 – Chủ Nhật)',
      'website': 'www.beautyandglow.vn',
      'location': const LatLng(10.827668, 106.678125),
    },
    {
      'name': 'Beauty & Glow Cosmetics — Hà Nội',
      'address': '123 Đường Cầu Giấy, Quận Cầu Giấy, Hà Nội',
      'hotline': '1900 1234',
      'hours': '8:30 – 21:30 (Thứ 2 – Chủ Nhật)',
      'website': 'www.beautyandglow.vn',
      'location': const LatLng(21.028511, 105.798150),
    }
  ];

  @override
  void initState() {
    super.initState();
    _storesStream = FirebaseFirestore.instance
        .collection('store_locations')
        .where('is_active', isEqualTo: true)
        .snapshots();
    _checkLocationPermission();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return;
    } 

    if (mounted) {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
      });
    }
  }

  Future<void> _openExternalMap(LatLng location) async {
    final url = 'https://www.google.com/maps/dir/?api=1&destination=${location.latitude},${location.longitude}';
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể mở bản đồ. Vui lòng kiểm tra lại thiết bị.')),
        );
      }
    }
  }

  Future<void> _callHotline(String hotline) async {
    final cleanHotline = hotline.replaceAll(RegExp(r'\D'), '');
    final uri = Uri.parse('tel:$cleanHotline');
    try {
      await launchUrl(uri);
    } catch (e) {
      debugPrint('Could not launch hotline: $e');
    }
  }

  Future<void> _openWebsite(String website) async {
    final url = website.startsWith('http') ? website : 'https://$website';
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Could not launch website: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _storesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        List<Map<String, dynamic>> storesList = [];
        
        if (docs.isNotEmpty) {
          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            double lat = data['latitude'] ?? _defaultStores[0]['location'].latitude;
            double lng = data['longitude'] ?? _defaultStores[0]['location'].longitude;
            storesList.add({
              'name': data['name'] ?? 'Beauty & Glow Cosmetics',
              'address': data['address'] ?? '456 Nguyễn Huệ, Quận 1, TP. Hồ Chí Minh',
              'hotline': data['hotline'] ?? '0909 888 777',
              'hours': data['hours'] ?? '9:00 – 22:00 (Thứ 2 – Chủ Nhật)',
              'website': data['website'] ?? 'www.beautyandglow.vn',
              'location': LatLng(lat, lng),
            });
          }
          // Add dummy data for demo if Firebase only has 1 store
          if (storesList.length == 1) {
            storesList.addAll(_defaultStores.skip(1));
          }
        } else {
          storesList = _defaultStores;
        }

        final initialCenter = storesList.isNotEmpty ? storesList[_selectedStoreIndex]['location'] as LatLng : _defaultStores[0]['location'] as LatLng;

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
            actions: [
              IconButton(
                icon: const Icon(Icons.format_list_bulleted),
                onPressed: () {
                  _showStoresList(context, storesList);
                },
              )
            ],
          ),
          body: Stack(
            children: [
              // Flutter Map View
              Positioned.fill(
                bottom: 280,
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: initialCenter,
                    initialZoom: 15.0,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.project_mobileshop',
                    ),
                    MarkerLayer(
                      markers: [
                        ...storesList.asMap().entries.map((entry) {
                          int index = entry.key;
                          var store = entry.value;
                          bool isSelected = index == _selectedStoreIndex;
                          return Marker(
                            point: store['location'] as LatLng,
                            width: isSelected ? 60 : 40,
                            height: isSelected ? 60 : 40,
                            child: GestureDetector(
                              onTap: () {
                                _pageController.animateToPage(
                                  index,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              child: Icon(
                                Icons.location_on,
                                color: isSelected ? Colors.red : Colors.red[300],
                                size: isSelected ? 50 : 35,
                              ),
                            ),
                          );
                        }),
                        if (_userLocation != null)
                          Marker(
                            point: _userLocation!,
                            width: 60,
                            height: 60,
                            child: const Icon(
                              Icons.my_location,
                              color: Colors.blue,
                              size: 30,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Bottom Sheet Carousel
              Positioned(
                left: 0,
                right: 0,
                bottom: 20,
                height: 310,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _selectedStoreIndex = index;
                    });
                    _mapController.move(
                      storesList[index]['location'] as LatLng,
                      15.0,
                    );
                  },
                  itemCount: storesList.length,
                  itemBuilder: (context, index) {
                    final store = storesList[index];
                    return _buildStoreCard(store);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStoreCard(Map<String, dynamic> store) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
            store['name'] ?? '',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
              fontFamily: 'DM Sans',
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          // Details
          Expanded(
            child: Column(
              children: [
                _infoRow(Icons.location_on_outlined, store['address'] ?? '', null),
                const SizedBox(height: 6),
                _infoRow(Icons.call_outlined, 'Hotline: ${store['hotline']}', () => _callHotline(store['hotline'] ?? '')),
                const SizedBox(height: 6),
                _infoRow(Icons.schedule_outlined, 'Giờ mở cửa: ${store['hours']}', null),
                const SizedBox(height: 6),
                _infoRow(Icons.language_outlined, 'Website: ${store['website']}', () => _openWebsite(store['website'] ?? '')),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Action Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => _openExternalMap(store['location'] as LatLng),
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
    );
  }

  Widget _infoRow(IconData icon, String text, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 13,
                  color: onTap != null ? AppColors.primary : AppColors.onSurfaceVariant,
                  decoration: onTap != null ? TextDecoration.underline : TextDecoration.none,
                  fontFamily: 'DM Sans',
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStoresList(BuildContext context, List<Map<String, dynamic>> storesList) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Danh sách chi nhánh',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'DM Sans',
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: storesList.length,
                  itemBuilder: (context, index) {
                    final store = storesList[index];
                    bool isSelected = index == _selectedStoreIndex;
                    return ListTile(
                      leading: Icon(
                        Icons.store, 
                        color: isSelected ? AppColors.primary : Colors.grey
                      ),
                      title: Text(
                        store['name'] ?? '', 
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, 
                          fontFamily: 'DM Sans',
                          color: isSelected ? AppColors.primary : AppColors.onSurface,
                        )
                      ),
                      subtitle: Text(
                        store['address'] ?? '', 
                        style: const TextStyle(fontFamily: 'DM Sans', fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: isSelected ? const Icon(Icons.check_circle, color: AppColors.primary) : null,
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          _selectedStoreIndex = index;
                        });
                        if (_pageController.hasClients) {
                          _pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                        _mapController.move(store['location'] as LatLng, 15.0);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
