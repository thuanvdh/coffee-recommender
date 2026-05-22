import 'package:flutter_test/flutter_test.dart';
import 'package:coffee_recommender/features/search/data/models/coffee_shop.dart';

void main() {
  test('CoffeeShop deserializes successfully from valid JSON response', () {
    final json = {
      'id': 12,
      'name': 'Góc Yên Bình',
      'slug': 'goc-yen-binh',
      'address': '45 Lê Lợi, Hải Châu, Đà Nẵng',
      'district': 'Hải Châu',
      'status': 'open',
      'purposes': ['Làm việc', 'Đọc sách'],
      'spaces': ['Máy lạnh'],
      'amenities': ['WiFi mạnh', 'Bàn cao'],
      'created_at': '2026-05-21T08:00:00Z',
      'updated_at': '2026-05-21T08:00:00Z'
    };

    final shop = CoffeeShop.fromJson(json);

    expect(shop.id, 12);
    expect(shop.name, 'Góc Yên Bình');
    expect(shop.purposes, contains('Làm việc'));
  });
}
