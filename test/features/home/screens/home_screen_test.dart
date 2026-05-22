import 'package:coffee_recommender/features/search/domain/models/search_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'package:go_router/go_router.dart';
import 'package:coffee_recommender/features/home/presentation/screens/home_screen.dart';
import 'package:coffee_recommender/features/home/presentation/widgets/weather_widget.dart';
import '../../../helpers/test_helpers.dart';

class LocationServicesOffGeolocator extends GeolocatorPlatform {
  @override
  Future<bool> isLocationServiceEnabled() async => false;
}

Future<void> pumpHomeRouter(
  WidgetTester tester, {
  required void Function(SearchIntent intent) onSearch,
}) async {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) {
          final intent = state.extra! as SearchIntent;
          onSearch(intent);
          return Scaffold(
            body: Text('Search route: ${intent.query}'),
          );
        },
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: getTestOverrides(),
      child: MaterialApp.router(routerConfig: router),
    ),
  );
}

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

  testWidgets('HomeScreen submits primary search as SearchIntent extra',
      (WidgetTester tester) async {
    SearchIntent? submittedIntent;
    await pumpHomeRouter(
      tester,
      onSearch: (intent) => submittedIntent = intent,
    );

    await tester.tap(find.byType(SearchBar));
    await tester.enterText(find.byType(EditableText), 'espresso');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(submittedIntent, isNotNull);
    expect(submittedIntent!.query, 'espresso');
    expect(find.text('Search route: espresso'), findsOneWidget);
  });

  testWidgets('Gần tôi chip uses GPS flow instead of immediate search route',
      (WidgetTester tester) async {
    final originalGeolocator = GeolocatorPlatform.instance;
    GeolocatorPlatform.instance = LocationServicesOffGeolocator();
    SearchIntent? submittedIntent;

    addTearDown(() {
      GeolocatorPlatform.instance = originalGeolocator;
    });

    await pumpHomeRouter(
      tester,
      onSearch: (intent) => submittedIntent = intent,
    );

    expect(find.text('Gần tôi'), findsOneWidget);

    await tester.tap(find.text('Gần tôi'));
    await tester.pump();

    expect(submittedIntent, isNull);
    expect(find.textContaining('Search route:'), findsNothing);
    expect(find.text('Dịch vụ định vị GPS đang tắt.'), findsOneWidget);
  });
}
