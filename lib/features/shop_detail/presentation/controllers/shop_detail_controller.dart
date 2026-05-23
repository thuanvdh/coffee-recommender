import 'package:coffee_recommender/core/result/app_failure.dart';
import 'package:coffee_recommender/core/result/result.dart';
import 'package:coffee_recommender/features/search/data/models/coffee_shop.dart';
import 'package:coffee_recommender/features/search/presentation/providers/search_notifier.dart';
import 'package:coffee_recommender/features/shop_detail/data/repositories/shop_detail_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ShopDetailStatus {
  initial,
  loading,
  success,
  failure,
  stale,
}

class ShopDetailState {
  const ShopDetailState({
    this.status = ShopDetailStatus.initial,
    this.shop,
    this.failure,
    this.isLoading = false,
  });

  final ShopDetailStatus status;
  final CoffeeShop? shop;
  final AppFailure? failure;
  final bool isLoading;

  ShopDetailState copyWith({
    ShopDetailStatus? status,
    Object? shop = _unset,
    Object? failure = _unset,
    bool? isLoading,
  }) {
    return ShopDetailState(
      status: status ?? this.status,
      shop: shop == _unset ? this.shop : shop as CoffeeShop?,
      failure: failure == _unset ? this.failure : failure as AppFailure?,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

const _unset = Object();

class ShopDetailController extends StateNotifier<ShopDetailState> {
  ShopDetailController(this._repository, {CoffeeShop? initialShop})
      : super(ShopDetailState(
          status: initialShop == null
              ? ShopDetailStatus.initial
              : ShopDetailStatus.stale,
          shop: initialShop,
        ));

  final ShopDetailRepository _repository;
  int _requestId = 0;

  @override
  ShopDetailState get debugState => state;

  Future<void> load(String slug) async {
    final requestId = ++_requestId;
    state = state.copyWith(
      status: ShopDetailStatus.loading,
      failure: null,
      isLoading: true,
    );

    final result = await _repository.fetchBySlug(slug);
    if (requestId != _requestId) {
      return;
    }

    switch (result) {
      case Success<CoffeeShop>(:final value):
        state = ShopDetailState(
          status: ShopDetailStatus.success,
          shop: value,
          isLoading: false,
        );
      case Failure<CoffeeShop>(:final failure):
        state = state.copyWith(
          status: state.shop == null
              ? ShopDetailStatus.failure
              : ShopDetailStatus.stale,
          failure: failure,
          isLoading: false,
        );
    }
  }

  Future<void> retry(String slug) => load(slug);
}

class ShopDetailControllerArgs {
  const ShopDetailControllerArgs({
    required this.slug,
    this.initialShop,
  });

  final String slug;
  final CoffeeShop? initialShop;

  @override
  bool operator ==(Object other) {
    return other is ShopDetailControllerArgs &&
        other.slug == slug &&
        other.initialShop == initialShop;
  }

  @override
  int get hashCode => Object.hash(slug, initialShop);
}

final shopDetailRepositoryProvider = Provider<ShopDetailRepository>(
  (ref) => ShopDetailRepository(ref.watch(searchDioClientProvider)),
);

final shopDetailControllerProvider = StateNotifierProvider.family<
    ShopDetailController,
    ShopDetailState,
    ShopDetailControllerArgs>((ref, args) {
  return ShopDetailController(
    ref.watch(shopDetailRepositoryProvider),
    initialShop: args.initialShop,
  )..load(args.slug);
});
