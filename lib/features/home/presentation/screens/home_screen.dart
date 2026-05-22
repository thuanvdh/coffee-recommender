import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:coffee_recommender/features/home/presentation/widgets/weather_widget.dart';

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

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(weatherProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Hero Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24.0),
                    bottomRight: Radius.circular(24.0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cà phê Đà Nẵng',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Tìm quán cà phê chuẩn gu của bạn',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    // Weather Integration
                    weatherAsync.when(
                      data: (weather) => WeatherWidget(
                        temperature: weather['temp'] as double,
                        weatherCode: weather['code'] as int,
                      ),
                      loading: () => const WeatherWidget(temperature: 28.5, weatherCode: 1),
                      error: (_, __) => const WeatherWidget(temperature: 28.5, weatherCode: 1),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24.0),

              // 2. Districts Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Tìm kiếm theo khu vực',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12.0),
              SizedBox(
                height: 40.0,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  children: [
                    _buildDistrictChip(context, 'Hải Châu'),
                    _buildDistrictChip(context, 'Thanh Khê'),
                    _buildDistrictChip(context, 'Sơn Trà'),
                    _buildDistrictChip(context, 'Ngũ Hành Sơn'),
                    _buildDistrictChip(context, 'Liên Chiểu'),
                    _buildDistrictChip(context, 'Cẩm Lệ'),
                  ],
                ),
              ),

              const SizedBox(height: 28.0),

              // 3. Mood Explorer (2x2 Grid)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hôm nay bạn cần không gian thế nào?',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'Chọn một phong cách phù hợp với tâm trạng hoặc mục đích nhé.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12.0,
                  mainAxisSpacing: 12.0,
                  childAspectRatio: 1.25,
                  children: [
                    _buildMoodCard(
                      context,
                      title: 'Học bài & Làm việc',
                      desc: 'Yên tĩnh, máy lạnh mát rượi, wifi mạnh.',
                      icon: Icons.work_outline,
                      color: const Color(0xFFE8F5E9),
                      iconColor: Colors.green,
                      path: '/search?purpose=Ngồi+làm+việc&amenity=Máy+lạnh',
                    ),
                    _buildMoodCard(
                      context,
                      title: 'Hẹn hò lãng mạn',
                      desc: 'Góc riêng tư, nhạc nhẹ, ấm cúng.',
                      icon: Icons.favorite_border,
                      color: const Color(0xFFFFEBEE),
                      iconColor: Colors.red,
                      path: '/search?purpose=Không+gian+riêng+tư&space=Trong+nhà',
                    ),
                    _buildMoodCard(
                      context,
                      title: 'Tụ tập bạn bè',
                      desc: 'Ngoài trời thoáng đãng, vỉa hè rộng rãi.',
                      icon: Icons.people_outline,
                      color: const Color(0xFFE3F2FD),
                      iconColor: Colors.blue,
                      path: '/search?purpose=Tụ+tập+bạn+bè&space=Ngoài+trời',
                    ),
                    _buildMoodCard(
                      context,
                      title: 'Check-in sống ảo',
                      desc: 'Decor xinh xắn, view sông biển đẹp.',
                      icon: Icons.camera_alt_outlined,
                      color: const Color(0xFFFFF8E1),
                      iconColor: Colors.amber.shade800,
                      path: '/search?space=View+hoàng+hôn',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDistrictChip(BuildContext context, String district) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ActionChip(
        label: Text(district),
        onPressed: () {
          context.go('/search?district=${Uri.encodeComponent(district)}');
        },
      ),
    );
  }

  Widget _buildMoodCard(
    BuildContext context, {
    required String title,
    required String desc,
    required IconData icon,
    required Color color,
    required Color iconColor,
    required String path,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => context.go(path),
      borderRadius: BorderRadius.circular(12.0),
      child: Ink(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: theme.brightness == Brightness.light ? color : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12.0),
          border: BorderSide(
            color: theme.brightness == Brightness.light ? Colors.transparent : theme.colorScheme.outline,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 24.0),
            const SizedBox(height: 8.0),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4.0),
            Expanded(
              child: Text(
                desc,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 10.0,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
