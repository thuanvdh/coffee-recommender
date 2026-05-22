import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:intl/intl.dart';
import 'package:coffee_recommender/features/search/data/models/coffee_shop.dart';
import 'package:coffee_recommender/features/search/presentation/providers/search_notifier.dart';
import 'package:coffee_recommender/features/search/presentation/providers/favorites_provider.dart';

/// Provider to fetch shop details by slug
final shopDetailProvider = FutureProvider.family<CoffeeShop, String>((ref, slug) async {
  final dioClient = ref.watch(searchDioClientProvider);
  final response = await dioClient.dio.get('/shops/slug/$slug');
  if (response.statusCode == 200 && response.data != null) {
    final responseData = response.data;
    Map<String, dynamic> shopJson;
    if (responseData is Map<String, dynamic>) {
      if (responseData.containsKey('shop')) {
        shopJson = responseData['shop'] as Map<String, dynamic>;
      } else if (responseData.containsKey('data')) {
        shopJson = responseData['data'] as Map<String, dynamic>;
      } else {
        shopJson = responseData;
      }
    } else {
      throw Exception('Invalid response format');
    }
    return CoffeeShop.fromJson(shopJson);
  }
  throw Exception('Failed to load shop details');
});

class ShopDetailScreen extends ConsumerStatefulWidget {
  final String slug;

  const ShopDetailScreen({
    super.key,
    required this.slug,
  });

  @override
  ConsumerState<ShopDetailScreen> createState() => _ShopDetailScreenState();
}

class _ShopDetailScreenState extends ConsumerState<ShopDetailScreen> {
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  double _getAverageRating(CoffeeShop shop) {
    if (shop.reviews.isEmpty) return 4.5;
    final total = shop.reviews.map((r) => r.rating).fold<int>(0, (sum, item) => sum + item);
    return total / shop.reviews.length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final detailAsync = ref.watch(shopDetailProvider(widget.slug));

    return Scaffold(
      body: detailAsync.when(
        data: (shop) {
          final isDark = theme.brightness == Brightness.dark;
          final isOpen = shop.status.toLowerCase() == 'open';
          final favoriteList = ref.watch(favoritesProvider);
          final isFav = favoriteList.contains(shop.slug);

          // Collect all image URLs for carousel
          final List<String> imageUrls = [];
          if (shop.images.isNotEmpty) {
            imageUrls.addAll(shop.images.map((img) => img.url));
          }
          final imageUrl = shop.imageUrl;
          if (imageUrls.isEmpty && imageUrl != null && imageUrl.isNotEmpty) {
            imageUrls.add(imageUrl);
          }
          if (imageUrls.isEmpty) {
            imageUrls.add('https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=800');
          }

          // Filter drinks and pastries
          final drinks = shop.drinks.where((d) => d.category.toLowerCase() == 'drink').toList();
          final pastries = shop.drinks.where((d) => d.category.toLowerCase() == 'pastry').toList();
          final address = shop.address;
          final description = shop.description;

          return CustomScrollView(
            slivers: [
              // App Bar with multiple image carousel and favorites toggler
              SliverAppBar(
                expandedHeight: 300.0,
                pinned: true,
                stretch: true,
                leading: Container(
                  margin: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(LucideIcons.arrow_left, color: Colors.white, size: 20.0),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        isFav ? LucideIcons.heart : LucideIcons.heart,
                        color: isFav ? const Color(0xFFEF4444) : Colors.white,
                        size: 20.0,
                      ),
                      onPressed: () {
                        ref.read(favoritesProvider.notifier).toggleFavorite(shop.slug);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isFav 
                                  ? 'Đã xóa khỏi danh sách yêu thích' 
                                  : 'Đã thêm vào danh sách yêu thích'
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        itemCount: imageUrls.length,
                        itemBuilder: (context, index) {
                          return CachedNetworkImage(
                            imageUrl: imageUrls[index],
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: theme.colorScheme.surfaceVariant,
                              child: const Center(child: CircularProgressIndicator()),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: theme.colorScheme.surfaceVariant,
                              child: const Icon(LucideIcons.image_off, size: 64.0),
                            ),
                          );
                        },
                      ),
                      // Gradient Overlays for readability and depth
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black45,
                              Colors.transparent,
                              Colors.transparent,
                              Colors.black87,
                            ],
                            stops: [0.0, 0.25, 0.7, 1.0],
                          ),
                        ),
                      ),
                      // Smooth Page Indicator
                      if (imageUrls.length > 1)
                        Positioned(
                          bottom: 20.0,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: SmoothPageIndicator(
                              controller: _pageController,
                              count: imageUrls.length,
                              effect: ExpandingDotsEffect(
                                activeDotColor: const Color(0xFFC17A2F),
                                dotColor: Colors.white.withOpacity(0.5),
                                dotHeight: 6.0,
                                dotWidth: 6.0,
                                expansionFactor: 4,
                                spacing: 6.0,
                              ),
                            ),
                          ),
                        ),
                    ],
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
                        // Title, Status Row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                shop.name,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12.0),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                              decoration: BoxDecoration(
                                color: isOpen 
                                    ? const Color(0xFF10B981).withOpacity(0.15) 
                                    : const Color(0xFFEF4444).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(30.0),
                                border: Border.all(
                                  color: isOpen ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                  width: 1.0,
                                ),
                              ),
                              child: Text(
                                isOpen ? 'Đang mở' : 'Đóng cửa',
                                style: TextStyle(
                                  color: isOpen ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10.0),

                        // Rating and District Row
                        Row(
                          children: [
                            const Icon(LucideIcons.star, color: Colors.amber, size: 18.0),
                            const SizedBox(width: 4.0),
                            Text(
                              _getAverageRating(shop).toStringAsFixed(1),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4.0),
                            Text(
                              '(${shop.reviews.length} đánh giá)',
                              style: TextStyle(
                                color: theme.colorScheme.onSurface.withOpacity(0.5),
                                fontSize: 13.0,
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            Text(
                              '•',
                              style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.3)),
                            ),
                            const SizedBox(width: 8.0),
                            Icon(
                              LucideIcons.map_pin, 
                              color: theme.colorScheme.secondary, 
                              size: 15.0,
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
                        const SizedBox(height: 20.0),

                        // Sidebar Details Grid (2x2 key facts)
                        _SidebarInfoGrid(shop: shop),
                        const SizedBox(height: 24.0),

                        // Address Box
                        if (address != null) ...[
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(
                                color: theme.colorScheme.outline.withOpacity(isDark ? 0.2 : 0.08),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  LucideIcons.map,
                                  color: theme.colorScheme.primary,
                                  size: 20.0,
                                ),
                                const SizedBox(width: 12.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Địa chỉ chính xác',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13.0,
                                        ),
                                      ),
                                      const SizedBox(height: 4.0),
                                      Text(
                                        address,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24.0),
                        ],

                        // Divider
                        Divider(color: theme.colorScheme.outline.withOpacity(isDark ? 0.15 : 0.08)),
                        const SizedBox(height: 20.0),

                        // Purposes (Phù hợp với)
                        if (shop.purposes.isNotEmpty) ...[
                          const _SectionTitle('Phù hợp với'),
                          const SizedBox(height: 12.0),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: shop.purposes.map((p) => _DetailChip(text: p, color: theme.colorScheme.primary)).toList(),
                          ),
                          const SizedBox(height: 24.0),
                        ],

                        // Spaces (Không gian)
                        if (shop.spaces.isNotEmpty) ...[
                          const _SectionTitle('Không gian'),
                          const SizedBox(height: 12.0),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: shop.spaces.map((s) => _DetailChip(text: s, color: theme.colorScheme.secondary)).toList(),
                          ),
                          const SizedBox(height: 24.0),
                        ],

                        // Amenities (Tiện ích)
                        if (shop.amenities.isNotEmpty) ...[
                          const _SectionTitle('Tiện ích nổi bật'),
                          const SizedBox(height: 12.0),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: shop.amenities.map((a) => _DetailChip(text: a, color: Colors.teal)).toList(),
                          ),
                          const SizedBox(height: 24.0),
                        ],

                        // About Section
                        const _SectionTitle('Giới thiệu quán'),
                        const SizedBox(height: 12.0),
                        Text(
                          description != null && description.isNotEmpty
                              ? description
                              : 'Quán cà phê mang phong cách thiết kế hiện đại, tinh tế. Không gian rộng rãi, thoáng mát thích hợp cho cả nhu cầu học tập, làm việc hiệu quả lẫn gặp gỡ trò chuyện cùng bạn bè. Menu đa dạng từ các loại cà phê specialty thơm ngon tới bánh ngọt nướng nóng hổi mỗi ngày.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32.0),

                        // Divider
                        Divider(color: theme.colorScheme.outline.withOpacity(isDark ? 0.15 : 0.08)),
                        const SizedBox(height: 24.0),

                        // Menu Section (Categorized)
                        _MenuSection(drinks: drinks, pastries: pastries),
                        const SizedBox(height: 32.0),

                        // Divider
                        Divider(color: theme.colorScheme.outline.withOpacity(isDark ? 0.15 : 0.08)),
                        const SizedBox(height: 24.0),

                        // Add Review Form
                        _ReviewForm(shopId: shop.id, slug: shop.slug),
                        const SizedBox(height: 32.0),

                        // Reviews List
                        _ReviewsList(reviews: shop.reviews),
                        const SizedBox(height: 40.0),
                      ],
                    ),
                  ),
                ]),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.triangle_alert, size: 48.0, color: theme.colorScheme.error),
                const SizedBox(height: 16.0),
                Text(
                  'Không thể tải thông tin quán cà phê',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8.0),
                Text(
                  err.toString(),
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24.0),
                ElevatedButton.icon(
                  onPressed: () => ref.refresh(shopDetailProvider(widget.slug)),
                  icon: const Icon(LucideIcons.refresh_cw, size: 16.0),
                  label: const Text('Thử lại'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 18.0,
        letterSpacing: -0.2,
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final String text;
  final Color color;

  const _DetailChip({
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback? onTap;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardContent = Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(isDark ? 0.15 : 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 16.0, color: const Color(0xFFC17A2F)),
              const SizedBox(width: 6.0),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.0),
          child: cardContent,
        ),
      );
    }
    return cardContent;
  }
}

class _SidebarInfoGrid extends StatelessWidget {
  final CoffeeShop shop;

  const _SidebarInfoGrid({
    required this.shop,
  });

  @override
  Widget build(BuildContext context) {
    final distance = shop.distanceKm;
    final distanceVal = distance != null 
        ? '${distance.toStringAsFixed(1)} km'
        : 'Chỉ đường';

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12.0,
      crossAxisSpacing: 12.0,
      childAspectRatio: 1.55,
      children: [
        _InfoCard(
          icon: LucideIcons.clock,
          title: 'Giờ mở cửa',
          value: shop.openingHours ?? '07:00 - 22:00',
        ),
        _InfoCard(
          icon: LucideIcons.dollar_sign,
          title: 'Khoảng giá',
          value: shop.priceRange ?? '30k - 70k',
        ),
        _InfoCard(
          icon: LucideIcons.phone,
          title: 'Số điện thoại',
          value: shop.phone ?? 'Không có',
          onTap: shop.phone != null ? () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Đang kết nối tới ${shop.phone}...')),
            );
          } : null,
        ),
        _InfoCard(
          icon: LucideIcons.navigation,
          title: 'Vị trí & Khoảng cách',
          value: distanceVal,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đang mở bản đồ chỉ đường...')),
            );
          },
        ),
      ],
    );
  }
}

class _MenuSection extends StatefulWidget {
  final List<Drink> drinks;
  final List<Drink> pastries;

  const _MenuSection({
    required this.drinks,
    required this.pastries,
  });

  @override
  State<_MenuSection> createState() => _MenuSectionState();
}

class _MenuSectionState extends State<_MenuSection> {
  int _activeMenuTab = 0; // 0: Nước uống, 1: Bánh ngọt

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Thực đơn của quán'),
        const SizedBox(height: 16.0),
        // Menu Segment Switcher (Drinks / Pastries)
        Row(
          children: [
            _buildMenuTabButton(0, 'Nước uống (${widget.drinks.length})'),
            const SizedBox(width: 12.0),
            _buildMenuTabButton(1, 'Bánh ngọt (${widget.pastries.length})'),
          ],
        ),
        const SizedBox(height: 16.0),
        // Active List Display
        _activeMenuTab == 0
            ? _buildMenuItemsList(theme, widget.drinks, 'Không có nước uống nào được đăng ký.')
            : _buildMenuItemsList(theme, widget.pastries, 'Không có bánh ngọt nào được đăng ký.'),
      ],
    );
  }

  Widget _buildMenuTabButton(int index, String label) {
    final theme = Theme.of(context);
    final isSelected = _activeMenuTab == index;
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _activeMenuTab = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected 
                ? const Color(0xFFC17A2F) 
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(
              color: isSelected 
                  ? const Color(0xFFC17A2F) 
                  : theme.colorScheme.outline.withOpacity(isDark ? 0.15 : 0.08),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 13.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItemsList(ThemeData theme, List<Drink> items, String emptyMessage) {
    final isDark = theme.brightness == Brightness.dark;
    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24.0),
        alignment: Alignment.center,
        child: Text(
          emptyMessage,
          style: TextStyle(
            color: theme.colorScheme.onSurface.withOpacity(0.5),
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (context, index) => Divider(
        height: 1.0, 
        color: theme.colorScheme.outline.withOpacity(isDark ? 0.12 : 0.06),
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        final price = item.price;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.5,
                          ),
                        ),
                        if (item.isSignature) ...[
                          const SizedBox(width: 8.0),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(4.0),
                              border: Border.all(color: const Color(0xFFF59E0B), width: 0.6),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(LucideIcons.sparkles, size: 8.0, color: Color(0xFFF59E0B)),
                                SizedBox(width: 2.0),
                                Text(
                                  'Signature',
                                  style: TextStyle(
                                    color: Color(0xFFF59E0B),
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (item.isTrending) ...[
                          const SizedBox(width: 6.0),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(4.0),
                              border: Border.all(color: const Color(0xFFEF4444), width: 0.6),
                            ),
                            child: const Text(
                              'Trending',
                              style: TextStyle(
                                color: Color(0xFFEF4444),
                                fontSize: 8.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16.0),
              Text(
                price != null && price.isNotEmpty 
                    ? price 
                    : 'Liên hệ',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFC17A2F),
                  fontSize: 14.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ReviewForm extends ConsumerStatefulWidget {
  final int shopId;
  final String slug;

  const _ReviewForm({
    required this.shopId,
    required this.slug,
  });

  @override
  ConsumerState<_ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends ConsumerState<_ReviewForm> {
  final _nameController = TextEditingController();
  final _commentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  int _selectedRating = 5;
  bool _isSubmittingReview = false;

  @override
  void dispose() {
    _nameController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) return;

    setState(() {
      _isSubmittingReview = true;
    });

    final result = await ref.read(searchNotifierProvider.notifier).submitReview(
      widget.shopId,
      _nameController.text.trim(),
      _selectedRating,
      _commentController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      _isSubmittingReview = false;
    });

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đánh giá của bạn đã được gửi thành công!'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
      _nameController.clear();
      _commentController.clear();
      setState(() {
        _selectedRating = 5;
      });
      // Refresh shop details to show new review
      ref.refresh(shopDetailProvider(widget.slug));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gửi đánh giá thất bại. Vui lòng thử lại!'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Viết đánh giá của bạn'),
          const SizedBox(height: 8.0),
          Text(
            'Chia sẻ trải nghiệm thực tế của bạn tại quán để giúp cộng đồng lựa chọn tốt hơn.',
            style: TextStyle(
              fontSize: 12.5,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 16.0),
          
          // Star Rating Selector
          Row(
            children: [
              Text(
                'Đánh giá sao: ',
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8.0),
              Row(
                children: List.generate(5, (index) {
                  final starVal = index + 1;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedRating = starVal;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: Icon(
                        LucideIcons.star,
                        color: starVal <= _selectedRating ? Colors.amber : theme.colorScheme.outline,
                        size: 26.0,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 16.0),

          // User Name Input
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Họ và tên của bạn',
              hintText: 'Nhập tên hiển thị trên đánh giá',
              prefixIcon: Icon(LucideIcons.user, size: 18.0),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập họ và tên';
              }
              return null;
            },
          ),
          const SizedBox(height: 14.0),

          // Comment Input
          TextFormField(
            controller: _commentController,
            decoration: const InputDecoration(
              labelText: 'Nội dung đánh giá',
              hintText: 'Cảm nhận về không gian, nước uống, thái độ phục vụ...',
              prefixIcon: Icon(LucideIcons.message_square, size: 18.0),
              alignLabelWithHint: true,
            ),
            maxLines: 4,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập nội dung đánh giá';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),

          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmittingReview ? null : _submitReview,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                backgroundColor: const Color(0xFFC17A2F),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: _isSubmittingReview
                  ? const SizedBox(
                      height: 18.0,
                      width: 18.0,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Gửi đánh giá',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewsList extends StatelessWidget {
  final List<Review> reviews;

  const _ReviewsList({
    required this.reviews,
  });

  Color _getAvatarColor(String name) {
    final colors = [
      const Color(0xFFC17A2F),
      const Color(0xFF2C3E50),
      const Color(0xFFEF4444),
      const Color(0xFF10B981),
      const Color(0xFF8B5CF6),
      const Color(0xFF06B6D4),
      const Color(0xFFF59E0B),
    ];
    final hash = name.codeUnits.fold<int>(0, (sum, unit) => sum + unit);
    return colors[hash % colors.length];
  }

  String _formatDate(String dateStr) {
    try {
      final dateTime = DateTime.parse(dateStr).toLocal();
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    } catch (_) {
      if (dateStr.length >= 10) {
        return dateStr.substring(0, 10);
      }
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const _SectionTitle('Đánh giá từ khách hàng'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Text(
                '${reviews.length} đánh giá',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        
        if (reviews.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32.0),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(isDark ? 0.15 : 0.08),
              ),
            ),
            alignment: Alignment.center,
            child: Column(
              children: [
                Icon(LucideIcons.message_square, size: 36.0, color: theme.colorScheme.outline.withOpacity(0.5)),
                const SizedBox(height: 8.0),
                Text(
                  'Chưa có đánh giá nào',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  'Hãy là người đầu tiên chia sẻ cảm nhận về quán!',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: reviews.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16.0),
            itemBuilder: (context, index) {
              final review = reviews[index];
              final initial = review.userName.trim().isNotEmpty
                  ? review.userName.trim().substring(0, 1).toUpperCase()
                  : '?';
              final avatarColor = _getAvatarColor(review.userName);
              final comment = review.comment;

              return Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(isDark ? 0.15 : 0.08),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 18.0,
                          backgroundColor: avatarColor,
                          child: Text(
                            initial,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                review.userName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.5,
                                ),
                              ),
                              const SizedBox(height: 2.0),
                              Row(
                                children: [
                                  Row(
                                    children: List.generate(5, (starIdx) {
                                      return Icon(
                                        LucideIcons.star,
                                        size: 11.0,
                                        color: starIdx < review.rating ? Colors.amber : theme.colorScheme.outline,
                                      );
                                    }),
                                  ),
                                  const SizedBox(width: 8.0),
                                  Text(
                                    _formatDate(review.createdAt),
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                                      fontSize: 11.0,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (comment != null && comment.trim().isNotEmpty) ...[
                      const SizedBox(height: 12.0),
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Text(
                          comment,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.85),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
