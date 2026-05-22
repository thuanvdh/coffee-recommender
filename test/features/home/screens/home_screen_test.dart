import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffee_recommender/features/home/presentation/screens/home_screen.dart';
import 'package:coffee_recommender/features/home/presentation/widgets/weather_widget.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  testWidgets('HomeScreen renders search, smart chips, weather and districts',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: getTestOverrides(),
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    // Verify Title / Slogan
    expect(find.text('Cafe là văn hóa'), findsOneWidget);
    expect(
        find.text('Khám phá góc nhỏ\ntuyệt vời tại Đà Nẵng'), findsOneWidget);

    // Verify search-led discovery is primary
    expect(find.byType(SearchBar), findsOneWidget);
    expect(find.text('Tìm quán, khu vực, phong cách...'), findsOneWidget);
    expect(find.text('Gần tôi'), findsOneWidget);
    expect(find.text('Làm việc yên tĩnh'), findsOneWidget);
    expect(find.text('Hẹn hò'), findsOneWidget);
    expect(find.text('Check-in'), findsOneWidget);

    // Verify Weather Widget is present
    expect(find.byType(WeatherWidget), findsOneWidget);

    // Verify district chips are present
    expect(find.text('Hải Châu'), findsOneWidget);
    expect(find.text('Thanh Khê'), findsOneWidget);
    expect(find.text('Sơn Trà'), findsOneWidget);
  });
}
