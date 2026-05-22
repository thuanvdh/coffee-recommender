import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffee_recommender/features/search/presentation/providers/search_notifier.dart';

class FilterBottomSheet extends ConsumerWidget {
  const FilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(searchNotifierProvider);
    final notifier = ref.read(searchNotifierProvider.notifier);
    final theme = Theme.of(context);

    final purposes = ['Làm việc', 'Hẹn hò', 'Check-in', 'Họp nhóm'];
    final practicalConditions = ['Máy lạnh', 'WiFi mạnh', 'Gửi xe'];
    final spaces = ['Yên tĩnh', 'Sân thượng', 'Vintage', 'Ngoài trời'];
    final districts = [
      'Hải Châu',
      'Sơn Trà',
      'Ngũ Hành Sơn',
      'Thanh Khê',
      'Liên Chiểu',
      'Cẩm Lệ',
    ];

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bộ lọc tìm kiếm',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  notifier.clearFilters();
                  Navigator.pop(context);
                },
                child: const Text('Xóa tất cả'),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 12.0),

          _buildFilterSection(
            context,
            title: 'Mục đích',
            items: purposes,
            selectedItem: state.selectedPurpose,
            onSelected: (val) => notifier.updatePurpose(val),
          ),
          const SizedBox(height: 16.0),

          _buildFilterSection(
            context,
            title: 'Điều kiện thực tế',
            items: practicalConditions,
            selectedItem: state.selectedAmenity,
            onSelected: (val) => notifier.updateAmenity(val),
          ),
          const SizedBox(height: 16.0),

          _buildFilterSection(
            context,
            title: 'Không gian & đồ uống',
            items: spaces,
            selectedItem: state.selectedSpace,
            onSelected: (val) => notifier.updateSpace(val),
          ),
          const SizedBox(height: 16.0),

          _buildFilterSection(
            context,
            title: 'Quận',
            items: districts,
            selectedItem: state.selectedDistrict,
            onSelected: (val) => notifier.updateDistrict(val),
          ),
          const SizedBox(height: 24.0),

          // Apply Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Text('Áp dụng bộ lọc'),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }

  Widget _buildFilterSection(
    BuildContext context, {
    required String title,
    required List<String> items,
    required String? selectedItem,
    required ValueChanged<String?> onSelected,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: items.map((item) {
            final isSelected = selectedItem == item;
            return ChoiceChip(
              label: Text(item),
              selected: isSelected,
              onSelected: (selected) {
                onSelected(selected ? item : null);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
