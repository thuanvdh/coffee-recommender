import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffee_recommender/features/home/presentation/screens/home_screen.dart';
import 'package:coffee_recommender/features/home/presentation/widgets/weather_widget.dart';

void main() {
  testWidgets('HomeScreen renders header, weather, mood explorer and districts', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    // Verify Title / Slogan
    expect(find.text('Cà phê Đà Nẵng'), findsOneWidget);
    expect(find.text('Tìm quán cà phê chuẩn gu của bạn'), findsOneWidget);

    // Verify Weather Widget is present
    expect(find.byType(WeatherWidget), findsOneWidget);

    // Verify mood cards text
    expect(find.text('Học bài & Làm việc'), findsOneWidget);
    expect(find.text('Hẹn hò lãng mạn'), findsOneWidget);
    expect(find.text('Tụ tập bạn bè'), findsOneWidget);
    expect(find.text('Check-in sống ảo'), findsOneWidget);

    // Verify district chips are present
    expect(find.text('Hải Châu'), findsOneWidget);
    expect(find.text('Thanh Khê'), findsOneWidget);
    expect(find.text('Sơn Trà'), findsOneWidget);
  });
}
