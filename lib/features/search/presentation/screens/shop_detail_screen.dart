import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:coffee_recommender/features/search/data/models/coffee_shop.dart';
import 'package:coffee_recommender/features/search/presentation/providers/search_notifier.dart';

/// Provider to fetch shop details by slug
final shopDetailProvider = FutureProvider.family<CoffeeShop, String>((ref, slug) async {
  final dioClient = ref.watch(searchDioClientProvider);
  final response = await dioClient.dio.get('/shops/slug/$slug');
  if (response.statusCode == 200 && response.data != null) {
    final Map<String, dynamic> data = response.data is Map 
        ? response.data as Map<String, dynamic> 
        : response.data['data'] as Map<String, dynamic>;
    return CoffeeShop.fromJson(data);
  }
  throw Exception('Failed to load shop details');
});

class ShopDetailScreen extends ConsumerWidget {
  final String slug;

  const ShopDetailScreen({
    super.key,
    required this.slug,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final detailAsync = ref.watch(shopDetailProvider(slug));

    return Scaffold(
      body: detailAsync.when(
        data: (shop) => _buildContent(context, ref, theme, shop),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48.0, color: theme.colorScheme.error),
              const SizedBox(height: 16.0),
              Text(
                'Có lỗi xảy ra: $err',
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () => ref.refresh(shopDetailProvider(slug)),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, ThemeData theme, CoffeeShop shop) {
    final isOpen = shop.status.toLowerCase() == 'open';

    return CustomScrollView(
      slivers: [
        // Collapsible App Bar with Image
        SliverAppBar(
          expandedHeight: 280.0,
          pinned: true,
          stretch: true,
          flexibleSpace: FlexibleSpaceBar(
            stretchModes: const [
              StretchMode.zoomBackground,
              StretchMode.blurBackground,
            ],
            background: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=800',
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: theme.colorScheme.surface,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: theme.colorScheme.surface,
                    child: const Icon(Icons.broken_image, size: 64.0),
                  ),
                ),
                // Gradient Overlays for readability and depth
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black54,
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black85,
                      ],
                      stops: [0.0, 0.25, 0.7, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),
          leading: CircleAvatar(
            backgroundColor: Colors.black38,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),

        // Detail Content
        SliverList(
          delegate: SliverChildListDelegate([
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title, Status & Rating Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          shop.name,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.extrabold,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                        decoration: BoxDecoration(
                          color: isOpen ? Colors.green.shade800 : Colors.red.shade800,
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Text(
                          isOpen ? 'Đang mở' : 'Đóng cửa',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),

                  // Rating and District Row
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 20.0),
                      const SizedBox(width: 4.0),
                      Text(
                        '4.8',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Text(
                        '•',
                        style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4)),
                      ),
                      const SizedBox(width: 8.0),
                      Icon(
                        Icons.location_on_outlined, 
                        color: theme.colorScheme.secondary, 
                        size: 16.0,
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        shop.district ?? 'Đà Nẵng',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),

                  // Address Box
                  if (shop.address != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: theme.colorScheme.outline.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.map_outlined,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                            size: 20.0,
                          ),
                          const SizedBox(width: 12.0),
                          Expanded(
                            child: Text(
                              shop.address!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.8),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24.0),
                  ],

                  // Action Buttons Row (Phone, Directions, Share)
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          context,
                          icon: Icons.phone_outlined,
                          label: 'Gọi điện',
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Đang kết nối cuộc gọi...')),
                            );
                          },
                          theme: theme,
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: _buildActionButton(
                          context,
                          icon: Icons.directions_outlined,
                          label: 'Chỉ đường',
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Đang mở bản đồ...')),
                            );
                          },
                          theme: theme,
                          isPrimary: true,
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: _buildActionButton(
                          context,
                          icon: Icons.share_outlined,
                          label: 'Chia sẻ',
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Đã sao chép liên kết chia sẻ!')),
                            );
                          },
                          theme: theme,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32.0),

                  // Divider
                  Divider(color: theme.colorScheme.outline.withOpacity(0.2)),
                  const SizedBox(height: 24.0),

                  // Purposes (Phù hợp với)
                  if (shop.purposes.isNotEmpty) ...[
                    _buildSectionTitle(theme, 'Phù hợp với'),
                    const SizedBox(height: 12.0),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: shop.purposes.map((p) => _buildChip(p, theme.colorScheme.primary, theme)).toList(),
                    ),
                    const SizedBox(height: 24.0),
                  ],

                  // Spaces (Không gian)
                  if (shop.spaces.isNotEmpty) ...[
                    _buildSectionTitle(theme, 'Không gian'),
                    const SizedBox(height: 12.0),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: shop.spaces.map((s) => _buildChip(s, theme.colorScheme.secondary, theme)).toList(),
                    ),
                    const SizedBox(height: 24.0),
                  ],

                  // Amenities (Tiện ích)
                  if (shop.amenities.isNotEmpty) ...[
                    _buildSectionTitle(theme, 'Tiện ích nổi bật'),
                    const SizedBox(height: 12.0),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: shop.amenities.map((a) => _buildChip(a, Colors.teal, theme)).toList(),
                    ),
                    const SizedBox(height: 24.0),
                  ],

                  // About Section Placeholder
                  _buildSectionTitle(theme, 'Giới thiệu quán'),
                  const SizedBox(height: 12.0),
                  Text(
                    'Quán cà phê mang phong cách hiện đại pha chút hoài cổ, không gian yên tĩnh thích hợp cho làm việc, đọc sách hay gặp gỡ bạn bè. Menu đa dạng với các loại cà phê specialty chất lượng cao, trà thanh nhiệt và bánh ngọt tươi mới mỗi ngày.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40.0),
                ],
              ),
            ),
          ]),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 18.0,
        letterSpacing: -0.2,
      ),
    );
  }

  Widget _buildChip(String text, Color color, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(30.0),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1.0,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isDark ? color.withOpacity(0.9) : color,
          fontSize: 12.0,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required ThemeData theme,
    bool isPrimary = false,
  }) {
    if (isPrimary) {
      return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14.0),
          backgroundColor: theme.colorScheme.secondary,
          foregroundColor: theme.colorScheme.onSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          elevation: 2,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22.0),
            const SizedBox(height: 4.0),
            Text(label, style: const TextStyle(fontSize: 11.0, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14.0),
        side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.6)),
        foregroundColor: theme.colorScheme.onSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22.0),
          const SizedBox(height: 4.0),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.0,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
