import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:coffee_recommender/features/search/data/models/coffee_shop.dart';
import 'package:coffee_recommender/features/search/presentation/providers/favorites_provider.dart';
import 'package:coffee_recommender/features/search/presentation/screens/shop_detail_screen.dart';

class ShopCard extends ConsumerWidget {
  final CoffeeShop shop;
  final EdgeInsetsGeometry? margin;
  final List<String> matchReasons;

  const ShopCard({
    super.key,
    required this.shop,
    this.margin,
    this.matchReasons = const [],
  });

  double get _averageRating {
    if (shop.reviews.isEmpty) return 4.5;
    final total = shop.reviews
        .map((r) => r.rating)
        .fold<int>(0, (sum, item) => sum + item);
    return total / shop.reviews.length;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isOpen = shop.status.toLowerCase() == 'open';
    final favoriteList = ref.watch(favoritesProvider);
    final isFav = favoriteList.contains(shop.slug);

    final shopImageUrl = shop.imageUrl;
    final imageUrl = (shopImageUrl != null && shopImageUrl.isNotEmpty)
        ? shopImageUrl
        : 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=600';

    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 20.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(isDark ? 0.15 : 0.08),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 10.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: InkWell(
          onTap: () => context.push(
            '/shop/${shop.slug}',
            extra: ShopDetailRouteExtra(
              initialShop: shop,
              matchReasons: matchReasons,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image container with 4:3 aspect ratio
              AspectRatio(
                aspectRatio: 4 / 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: theme.colorScheme.surfaceVariant,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2.0),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: theme.colorScheme.surfaceVariant,
                        child: Icon(
                          LucideIcons.image_off,
                          size: 40.0,
                          color: theme.colorScheme.onSurfaceVariant
                              .withOpacity(0.5),
                        ),
                      ),
                    ),
                    // Gradient overlay at the bottom of the image for text contrast
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.35),
                              Colors.transparent,
                              Colors.transparent,
                              Colors.black.withOpacity(0.45),
                            ],
                            stops: const [0.0, 0.3, 0.7, 1.0],
                          ),
                        ),
                      ),
                    ),
                    // Open/Closed Status Badge (Top-Left)
                    Positioned(
                      top: 12.0,
                      left: 12.0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 5.0),
                        decoration: BoxDecoration(
                          color: isOpen
                              ? const Color(0xFF10B981)
                                  .withOpacity(0.9) // Emerald green
                              : const Color(0xFFEF4444)
                                  .withOpacity(0.9), // Coral red
                          borderRadius: BorderRadius.circular(30.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          isOpen ? 'Đang mở' : 'Đóng cửa',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                    // Favorite Toggle Button (Top-Right)
                    Positioned(
                      top: 12.0,
                      right: 12.0,
                      child: GestureDetector(
                        onTap: () {
                          ref
                              .read(favoritesProvider.notifier)
                              .toggleFavorite(shop.slug);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(isFav
                                  ? 'Đã xóa khỏi danh sách yêu thích'
                                  : 'Đã thêm vào danh sách yêu thích'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1.0,
                            ),
                          ),
                          child: Icon(
                            isFav ? LucideIcons.heart : LucideIcons.heart,
                            size: 18.0,
                            color:
                                isFav ? const Color(0xFFEF4444) : Colors.white,
                          ),
                        ),
                      ),
                    ),
                    // Distance badge overlay (Bottom-Right) if distanceKm is present
                    if (shop.distanceKm != null)
                      Positioned(
                        bottom: 12.0,
                        right: 12.0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 5.0),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(30.0),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.15),
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                LucideIcons.map_pin,
                                color: Color(0xFFC17A2F),
                                size: 12.0,
                              ),
                              const SizedBox(width: 4.0),
                              Text(
                                '${(shop.distanceKm ?? 0.0).toStringAsFixed(1)} km',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Info Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Shop Name & Rating Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            shop.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 17.0,
                              letterSpacing: -0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              LucideIcons.star,
                              color: Colors.amber,
                              size: 15.0,
                            ),
                            const SizedBox(width: 4.0),
                            Text(
                              _averageRating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13.0,
                              ),
                            ),
                            const SizedBox(width: 2.0),
                            Text(
                              '(${shop.reviews.length})',
                              style: TextStyle(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.4),
                                fontSize: 11.0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6.0),
                    // Address/District Info
                    if (shop.address != null)
                      Row(
                        children: [
                          Icon(
                            LucideIcons.map_pin,
                            size: 13.0,
                            color: theme.colorScheme.onSurface.withOpacity(0.4),
                          ),
                          const SizedBox(width: 4.0),
                          Expanded(
                            child: Text(
                              shop.address ?? '',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.55),
                                fontSize: 12.0,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    if (matchReasons.isNotEmpty) ...[
                      const SizedBox(height: 10.0),
                      Wrap(
                        spacing: 6.0,
                        runSpacing: 6.0,
                        children: [
                          for (final reason in matchReasons.take(2))
                            _ShopTag(
                              text: reason,
                              color: theme.colorScheme.tertiary,
                            ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 12.0),
                    // Tags (Purposes / Spaces) matching web chip tags
                    if (shop.purposes.isNotEmpty || shop.spaces.isNotEmpty)
                      Wrap(
                        spacing: 6.0,
                        runSpacing: 6.0,
                        children: [
                          ...shop.purposes.take(2).map((p) => _ShopTag(
                              text: p, color: theme.colorScheme.primary)),
                          ...shop.spaces.take(1).map((s) => _ShopTag(
                              text: s, color: theme.colorScheme.secondary)),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShopTag extends StatelessWidget {
  const _ShopTag({
    required this.text,
    required this.color,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.5),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(
          color: color.withOpacity(0.18),
          width: 0.8,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isDark ? color.withOpacity(0.9) : color,
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
