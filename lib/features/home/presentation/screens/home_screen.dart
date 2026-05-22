import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:coffee_recommender/core/theme/app_colors.dart';
import 'package:coffee_recommender/features/discovery/presentation/controllers/discovery_controller.dart';
import 'package:coffee_recommender/features/home/presentation/widgets/weather_widget.dart';
import 'package:coffee_recommender/features/search/domain/models/search_intent.dart';
import 'package:coffee_recommender/features/search/presentation/providers/search_notifier.dart';
import 'package:coffee_recommender/features/search/data/models/coffee_shop.dart';
import 'package:coffee_recommender/features/search/presentation/widgets/shop_card.dart';

// Weather Provider
final weatherProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  try {
    final dio = Dio();
    final response = await dio.get(
      'https://api.open-meteo.com/v1/forecast?latitude=16.0544&longitude=108.2022&current_weather=true',
      options: Options(receiveTimeout: const Duration(seconds: 3)),
    );
    if (response.statusCode == 200 && response.data != null) {
      final current = response.data['current_weather'] as Map<String, dynamic>;
      return {
        'temp': (current['temperature'] as num).toDouble(),
        'code': (current['weathercode'] as num).toInt(),
      };
    }
  } catch (_) {
    // Fallback Da Nang weather when offline
  }
  return {'temp': 28.5, 'code': 1};
});

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  final _discoveryController = DiscoveryController();
  bool _shuffling = false;
  String _shuffledName = '';
  Timer? _shuffleTimer;

  @override
  void dispose() {
    _shuffleTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _submitSearch(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    context.go('/search', extra: SearchIntent(query: trimmed));
  }

  Future<void> _handleNearMe() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!mounted) return;
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dịch vụ định vị GPS đang tắt.')));
      return;
    }

    permission = await Geolocator.checkPermission();
    if (!mounted) return;
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (!mounted) return;
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Quyền định vị GPS bị từ chối.')));
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Quyền định vị GPS bị từ chối vĩnh viễn.')));
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5),
      );
      if (!mounted) return;
      context.go(
        '/search',
        extra: SearchIntent(
          nearMe: true,
          latitude: position.latitude,
          longitude: position.longitude,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể lấy vị trí hiện tại.')));
    }
  }

  Future<void> _handleSurpriseMe() async {
    if (_shuffling) return;

    final notifier = ref.read(searchNotifierProvider.notifier);
    final state = ref.read(searchNotifierProvider);

    List<CoffeeShop> shops = state.shops;
    if (shops.isEmpty) {
      setState(() {
        _shuffling = true;
        _shuffledName = 'Đang tải danh sách...';
      });
      await notifier.fetchShops();
      if (!mounted) return;
      shops = ref.read(searchNotifierProvider).shops;
    }

    if (shops.isEmpty) {
      setState(() {
        _shuffling = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không có dữ liệu quán cà phê.')));
      return;
    }

    setState(() {
      _shuffling = true;
      _shuffledName = 'Đang chọn quán...';
    });

    final random = Random();
    int ticks = 0;

    _shuffleTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        final randomShop = shops[random.nextInt(shops.length)];
        _shuffledName = randomShop.name;
      });
      ticks++;

      if (ticks > 12) {
        timer.cancel();
        final finalShop = shops[random.nextInt(shops.length)];
        setState(() {
          _shuffledName = finalShop.name;
        });

        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) {
            setState(() {
              _shuffling = false;
            });
            context.go('/shop/${finalShop.slug}');
          }
        });
      }
    });
  }

  void _handleWeatherRecommendation(double temp, int code) {
    if (code >= 51 && code <= 67) {
      context.go('/search', extra: SearchIntent(spaceTags: ['Trong nhà']));
    } else if (temp > 30.0) {
      context.go('/search', extra: SearchIntent(amenityTags: ['Máy lạnh']));
    } else {
      context.go('/search', extra: SearchIntent(spaceTags: ['Sân thượng']));
    }
  }

  @override
  Widget build(BuildContext context) {
    final weatherAsync = ref.watch(weatherProvider);
    final searchState = ref.watch(searchNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final accentColor = isDark ? AppColors.darkAccent : AppColors.lightAccent;
    final textLightColor =
        isDark ? AppColors.darkTextLight : AppColors.lightTextLight;
    final cardBgColor = isDark ? AppColors.darkBgLight : AppColors.lightBgLight;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final sectionBgColor =
        isDark ? AppColors.darkBgSection : AppColors.lightBgSection;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Hero Banner with Radial Background Style
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 32.0),
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      isDark
                          ? const Color(0xFF2C241D)
                          : const Color(0xFFF9EFE5),
                      isDark ? AppColors.darkBg : AppColors.lightBg,
                    ],
                    center: Alignment.topRight,
                    radius: 1.5,
                  ),
                  border: Border(
                    bottom: BorderSide(color: borderColor, width: 1.0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cafe là văn hóa',
                      style: GoogleFonts.dancingScript(
                        color: accentColor,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Khám phá góc nhỏ\ntuyệt vời tại Đà Nẵng',
                      style: GoogleFonts.inter(
                        color: primaryColor,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Tổng hợp những quán cà phê có không gian đẹp nhất, cà phê ngon nhất và trải nghiệm tuyệt nhất tại thành phố biển Đà Nẵng.',
                      style: GoogleFonts.inter(
                        color: textLightColor,
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SearchBar(
                      controller: _searchController,
                      hintText: 'Tìm quán, khu vực, phong cách...',
                      leading: Icon(LucideIcons.search, color: accentColor),
                      trailing: [
                        IconButton(
                          tooltip: 'Tìm kiếm',
                          icon: const Icon(LucideIcons.arrow_right),
                          onPressed: () =>
                              _submitSearch(_searchController.text),
                        ),
                      ],
                      onSubmitted: _submitSearch,
                      backgroundColor: WidgetStatePropertyAll(cardBgColor),
                      side: WidgetStatePropertyAll(
                        BorderSide(color: borderColor),
                      ),
                      elevation: const WidgetStatePropertyAll(0),
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final preset in _discoveryController.presets)
                          ActionChip(
                            label: Text(preset.label),
                            avatar: Icon(
                              preset.id == 'near_me'
                                  ? LucideIcons.navigation
                                  : LucideIcons.sparkles,
                              size: 16,
                            ),
                            onPressed: () {
                              context.go('/search', extra: preset.intent);
                            },
                            backgroundColor: cardBgColor,
                            side: BorderSide(color: borderColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            labelStyle: GoogleFonts.inter(
                              color: primaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Quick Actions
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => context.go('/search'),
                          icon: const Icon(LucideIcons.compass, size: 16),
                          label: const Text('Khám phá ngay'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            foregroundColor:
                                isDark ? AppColors.darkBg : Colors.white,
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: _handleSurpriseMe,
                          icon: Icon(
                            LucideIcons.sparkles,
                            size: 16,
                            color: _shuffling ? primaryColor : accentColor,
                          ),
                          label: Text(
                            _shuffling ? _shuffledName : 'Bốc Thăm Ngẫu Nhiên',
                            style: GoogleFonts.inter(
                              color: primaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: borderColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 12.0),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: _handleNearMe,
                          icon: const Icon(LucideIcons.navigation,
                              size: 16, color: Colors.blueAccent),
                          label: Text(
                            'Tìm Gần Đây',
                            style: GoogleFonts.inter(
                              color: primaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: borderColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 12.0),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Weather Integration Card
                    weatherAsync.when(
                      data: (weather) {
                        final temp = weather['temp'] as double;
                        final code = weather['code'] as int;
                        return WeatherWidget(
                          temperature: temp,
                          weatherCode: code,
                          onTap: () => _handleWeatherRecommendation(temp, code),
                        );
                      },
                      loading: () => WeatherWidget(
                        temperature: 28.5,
                        weatherCode: 1,
                        onTap: () => _handleWeatherRecommendation(28.5, 1),
                      ),
                      error: (_, __) => WeatherWidget(
                        temperature: 28.5,
                        weatherCode: 1,
                        onTap: () => _handleWeatherRecommendation(28.5, 1),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. New Shops Section
              if (searchState.shops.isNotEmpty) ...[
                Container(
                  color: sectionBgColor,
                  padding: const EdgeInsets.symmetric(
                      vertical: 24.0, horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Quán mới mở',
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Những địa điểm cà phê nóng hổi.',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: textLightColor,
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () => context.go('/search?status=new'),
                            child: Row(
                              children: [
                                Text('Xem tất cả',
                                    style: GoogleFonts.inter(
                                        color: accentColor,
                                        fontWeight: FontWeight.w600)),
                                const Icon(LucideIcons.chevron_right, size: 16),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Horizontal scroll of top new shops
                      SizedBox(
                        height: 340,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: min(4, searchState.shops.length),
                          itemBuilder: (context, idx) {
                            final shop = searchState.shops[idx];
                            return Container(
                              width: 220,
                              margin: const EdgeInsets.only(right: 14),
                              child: ShopCard(shop: shop),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // 4. District Finder
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tìm kiếm theo khu vực',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Khám phá danh sách các quán ngon nhất theo từng quận Đà Nẵng.',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: textLightColor,
                      ),
                    ),
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                      childAspectRatio: 1.3,
                      children: const [
                        _DistrictCard(district: 'Hải Châu'),
                        _DistrictCard(district: 'Thanh Khê'),
                        _DistrictCard(district: 'Sơn Trà'),
                        _DistrictCard(district: 'Ngũ Hành Sơn'),
                        _DistrictCard(district: 'Liên Chiểu'),
                        _DistrictCard(district: 'Cẩm Lệ'),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _DistrictCard extends StatelessWidget {
  const _DistrictCard({
    required this.district,
  });

  final String district;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBgLight : AppColors.lightBgLight;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return InkWell(
      onTap: () {
        context.go('/search', extra: SearchIntent(district: district));
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.map_pin, size: 16, color: Colors.blueAccent),
            const SizedBox(height: 6),
            Text(
              district,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
