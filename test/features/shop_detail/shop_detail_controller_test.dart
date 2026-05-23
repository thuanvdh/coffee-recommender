import 'dart:async';

import 'package:coffee_recommender/core/network/dio_client.dart';
import 'package:coffee_recommender/core/result/app_failure.dart';
import 'package:coffee_recommender/core/result/result.dart';
import 'package:coffee_recommender/features/search/data/models/coffee_shop.dart';
import 'package:coffee_recommender/features/shop_detail/data/repositories/shop_detail_repository.dart';
import 'package:coffee_recommender/features/shop_detail/presentation/controllers/shop_detail_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ShopDetailController', () {
    test('load moves from loading to success', () async {
      final repository = _CompletingShopDetailRepository();
      final subject = ShopDetailController(repository);

      final loadFuture = subject.load('goc-yen-binh');

      expect(subject.debugState.status, ShopDetailStatus.loading);
      expect(subject.debugState.isLoading, isTrue);

      repository.complete(const Result.success(_shop));
      await loadFuture;

      expect(subject.debugState.status, ShopDetailStatus.success);
      expect(subject.debugState.isLoading, isFalse);
      expect(subject.debugState.shop, _shop);
      expect(subject.debugState.failure, isNull);
      expect(repository.slug, 'goc-yen-binh');
    });

    test('load moves from loading to failure', () async {
      final repository = _CompletingShopDetailRepository();
      final subject = ShopDetailController(repository);

      final loadFuture = subject.load('missing-shop');

      expect(subject.debugState.status, ShopDetailStatus.loading);
      expect(subject.debugState.isLoading, isTrue);

      repository.complete(const Result.failure(AppFailure.network()));
      await loadFuture;

      expect(subject.debugState.status, ShopDetailStatus.failure);
      expect(subject.debugState.isLoading, isFalse);
      expect(subject.debugState.shop, isNull);
      expect(subject.debugState.failure?.type, AppFailureType.network);
      expect(repository.slug, 'missing-shop');
    });
  });
}

class _CompletingShopDetailRepository extends ShopDetailRepository {
  _CompletingShopDetailRepository() : super(DioClient(Dio()));

  final Completer<Result<CoffeeShop>> _completer = Completer();
  String? slug;

  @override
  Future<Result<CoffeeShop>> fetchBySlug(String slug) {
    this.slug = slug;
    return _completer.future;
  }

  void complete(Result<CoffeeShop> result) {
    _completer.complete(result);
  }
}

const _shop = CoffeeShop(
  id: 1,
  name: 'Goc Yen Binh',
  slug: 'goc-yen-binh',
  address: '45 Le Loi, Hai Chau, Da Nang',
  district: 'Hai Chau',
  status: 'open',
  createdAt: '2026-05-22T08:00:00Z',
  updatedAt: '2026-05-22T08:00:00Z',
);
