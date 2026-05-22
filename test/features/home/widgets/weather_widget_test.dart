import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coffee_recommender/features/home/presentation/widgets/weather_widget.dart';

void main() {
  testWidgets('WeatherWidget renders temperature and recommendation text', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WeatherWidget(
            temperature: 32.5,
            weatherCode: 1,
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('32.5°C'), findsOneWidget);
    expect(find.text('Trời khá oi nóng ☀️ - Trốn nắng ở phòng máy lạnh thôi!'), findsOneWidget);
  });
}
