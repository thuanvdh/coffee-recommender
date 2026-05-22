import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:coffee_recommender/features/search/data/models/coffee_shop.dart';

class ShopCard extends StatelessWidget {
  final CoffeeShop shop;

  const ShopCard({
    super.key,
    required this.shop,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOpen = shop.status.toLowerCase() == 'open';

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/shop/${shop.slug}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shop Image
            Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=500',
                  height: 160.0,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 160.0,
                    color: theme.colorScheme.surface,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 160.0,
                    color: theme.colorScheme.surface,
                    child: const Icon(Icons.broken_image, size: 40.0),
                  ),
                ),
                // Status Badge
                Positioned(
                  top: 12.0,
                  right: 12.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: isOpen ? Colors.green.shade800 : Colors.red.shade800,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      isOpen ? 'Đang mở' : 'Đóng cửa',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Info Section
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.between,
                    children: [
                      Expanded(
                        child: Text(
                          shop.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Row(
                        children: const [
                          Icon(Icons.star, color: Colors.amber, size: 16.0),
                          SizedBox(width: 4.0),
                          Text(
                            '4.8',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6.0),
                  if (shop.address != null) ...[
                    Text(
                      shop.address!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8.0),
                  ],
                  // Tags (Purposes / Spaces)
                  if (shop.purposes.isNotEmpty || shop.spaces.isNotEmpty)
                    Wrap(
                      spacing: 6.0,
                      runSpacing: 4.0,
                      children: [
                        ...shop.purposes.take(2).map((p) => _buildTag(context, p, theme.colorScheme.primary)),
                        ...shop.spaces.take(1).map((s) => _buildTag(context, s, theme.colorScheme.secondary)),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(BuildContext context, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10.0,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
