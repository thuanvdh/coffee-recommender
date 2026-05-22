import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffee_recommender/features/search/domain/models/search_intent.dart';
import 'package:coffee_recommender/features/search/presentation/providers/search_notifier.dart';
import 'package:coffee_recommender/features/search/presentation/widgets/shop_card.dart';
import 'package:coffee_recommender/features/search/presentation/widgets/filter_bottom_sheet.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({
    super.key,
    this.initialIntent,
  });

  final SearchIntent? initialIntent;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;
  late String _lastSyncedQuery;
  String? _pendingQuerySync;

  @override
  void initState() {
    super.initState();

    final initialQuery = widget.initialIntent?.query ?? '';
    _searchController = TextEditingController(
      text: initialQuery,
    );
    _searchFocusNode = FocusNode()..addListener(_applyPendingQuerySync);
    _lastSyncedQuery = initialQuery;
    ref.listenManual<SearchState>(
      searchNotifierProvider,
      (previous, next) {
        if (previous?.searchQuery == next.searchQuery) return;
        _syncSearchController(next.searchQuery);
      },
    );
    _searchInitialIntent(widget.initialIntent);
  }

  @override
  void didUpdateWidget(covariant SearchScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    final initialIntent = widget.initialIntent;
    if (oldWidget.initialIntent == initialIntent) return;

    _syncSearchController(initialIntent?.query ?? '', force: true);
    _searchInitialIntent(initialIntent);
  }

  @override
  void dispose() {
    _searchFocusNode
      ..removeListener(_applyPendingQuerySync)
      ..dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _searchInitialIntent(SearchIntent? initialIntent) {
    if (!_hasInitialIntent(initialIntent)) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(searchNotifierProvider.notifier).search(initialIntent!);
    });
  }

  bool _hasInitialIntent(SearchIntent? initialIntent) {
    return initialIntent != null && initialIntent != SearchIntent();
  }

  void _syncSearchController(String query, {bool force = false}) {
    if (!force &&
        _searchFocusNode.hasFocus &&
        _searchController.text != _lastSyncedQuery) {
      _pendingQuerySync = query;
      return;
    }

    _pendingQuerySync = null;
    if (_searchController.text == query) {
      _lastSyncedQuery = query;
      return;
    }

    _searchController.value = _searchController.value.copyWith(
      text: query,
      selection: TextSelection.collapsed(offset: query.length),
      composing: TextRange.empty,
    );
    _lastSyncedQuery = query;
  }

  void _applyPendingQuerySync() {
    if (_searchFocusNode.hasFocus) return;

    final pendingQuery = _pendingQuerySync;
    if (pendingQuery == null) return;
    _syncSearchController(pendingQuery, force: true);
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FilterBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchNotifierProvider);
    final notifier = ref.read(searchNotifierProvider.notifier);

    // List of active filters
    final activeFilters = <String>[];
    final district = state.selectedDistrict;
    if (district != null) activeFilters.add(district);
    final purpose = state.selectedPurpose;
    if (purpose != null) activeFilters.add(purpose);
    final space = state.selectedSpace;
    if (space != null) activeFilters.add(space);
    final amenity = state.selectedAmenity;
    if (amenity != null) activeFilters.add(amenity);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tìm kiếm quán'),
      ),
      body: Column(
        children: [
          // Search input & Filter trigger button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: SearchBar(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    hintText: 'Nhập tên quán, địa chỉ...',
                    leading: const Icon(Icons.search),
                    onSubmitted: (query) => notifier.updateQuery(query),
                    onChanged: (query) {
                      // simple instant or debounced update can be hooked here
                    },
                  ),
                ),
                const SizedBox(width: 12.0),
                IconButton.filledTonal(
                  onPressed: () => _showFilterBottomSheet(context),
                  icon: const Icon(Icons.filter_list),
                  style: IconButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Active filter chips list
          if (activeFilters.isNotEmpty)
            Container(
              height: 36.0,
              margin: const EdgeInsets.only(bottom: 12.0),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: activeFilters.length,
                itemBuilder: (context, index) {
                  final filter = activeFilters[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Chip(
                      label: Text(
                        filter,
                        style: const TextStyle(fontSize: 10.0),
                      ),
                      onDeleted: () {
                        if (filter == state.selectedDistrict) {
                          notifier.updateDistrict(null);
                        } else if (filter == state.selectedPurpose) {
                          notifier.updatePurpose(null);
                        } else if (filter == state.selectedSpace) {
                          notifier.updateSpace(null);
                        } else if (filter == state.selectedAmenity) {
                          notifier.updateAmenity(null);
                        }
                      },
                    ),
                  );
                },
              ),
            ),

          // Results list
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => notifier.fetchShops(),
              child: _buildResults(context, state, notifier),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(
    BuildContext context,
    SearchState state,
    SearchNotifier notifier,
  ) {
    final rankedShops = state.rankedShops;
    final hasRankedShops = rankedShops.isNotEmpty;

    return switch (state.status) {
      SearchStateStatus.loading when !hasRankedShops =>
        _buildLoadingView(context),
      SearchStateStatus.empty => _buildEmptyView(context, notifier),
      SearchStateStatus.failure when !hasRankedShops => _buildErrorView(
          context,
          state.failure?.userMessage ?? state.error ?? 'Đã xảy ra lỗi',
          notifier,
        ),
      SearchStateStatus.stale => _buildRankedList(
          context,
          state,
          showStaleIndicator: true,
        ),
      SearchStateStatus.success => _buildRankedList(context, state),
      SearchStateStatus.loading => _buildRankedList(
          context,
          state,
          showLoadingIndicator: true,
        ),
      SearchStateStatus.failure => _buildRankedList(
          context,
          state,
          showStaleIndicator: true,
        ),
      SearchStateStatus.initial when hasRankedShops => _buildRankedList(
          context,
          state,
        ),
      SearchStateStatus.initial => _buildEmptyView(context, notifier),
    };
  }

  Widget _buildLoadingView(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        const Center(child: CircularProgressIndicator()),
      ],
    );
  }

  Widget _buildRankedList(
    BuildContext context,
    SearchState state, {
    bool showStaleIndicator = false,
    bool showLoadingIndicator = false,
  }) {
    final rankedShops = state.rankedShops;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: rankedShops.length +
          (showStaleIndicator || showLoadingIndicator ? 1 : 0),
      itemBuilder: (context, index) {
        if (showStaleIndicator && index == 0) {
          return _buildStaleIndicator(context, state);
        }
        if (showLoadingIndicator && index == 0) {
          return const Padding(
            padding: EdgeInsets.only(bottom: 12.0),
            child: LinearProgressIndicator(minHeight: 2.0),
          );
        }

        final rankedShop = rankedShops[
            index - (showStaleIndicator || showLoadingIndicator ? 1 : 0)];
        return ShopCard(
          shop: rankedShop.shop,
          matchReasons: rankedShop.matchReasons,
        );
      },
    );
  }

  Widget _buildStaleIndicator(BuildContext context, SearchState state) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withOpacity(0.35),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: theme.colorScheme.error.withOpacity(0.16),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 18.0,
            color: theme.colorScheme.error,
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              state.failure?.userMessage ??
                  state.error ??
                  'Đang hiển thị kết quả đã lưu gần nhất.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView(BuildContext context, SearchNotifier notifier) {
    final theme = Theme.of(context);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.15),
        const Icon(Icons.search_off, size: 64.0, color: Colors.grey),
        const SizedBox(height: 16.0),
        Center(
          child: Text(
            'Không tìm thấy quán nào',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        const SizedBox(height: 8.0),
        Center(
          child: Text(
            'Hãy thử thay đổi từ khóa hoặc bộ lọc khác nhé.',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
        ),
        const SizedBox(height: 16.0),
        Center(
          child: TextButton(
            onPressed: notifier.clearFilters,
            child: const Text('Xóa bộ lọc'),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView(
      BuildContext context, String error, SearchNotifier notifier) {
    final theme = Theme.of(context);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.15),
        const Icon(Icons.error_outline, size: 64.0, color: Colors.red),
        const SizedBox(height: 16.0),
        Center(
          child: Text(
            'Có lỗi xảy ra',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.red.shade800,
            ),
          ),
        ),
        const SizedBox(height: 8.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Text(
            error,
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16.0),
        Center(
          child: ElevatedButton(
            onPressed: () => notifier.fetchShops(),
            child: const Text('Thử lại'),
          ),
        ),
      ],
    );
  }
}
