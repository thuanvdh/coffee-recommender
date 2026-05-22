import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coffee_recommender/features/navigation/presentation/main_shell.dart';

void main() {
  testWidgets('MainShell renders bottom navigation bar with 4 tabs', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MainShell(
          currentIndex: 0,
          onTap: (index) {},
          child: const Scaffold(
            body: Center(child: Text('Home Screen')),
          ),
        ),
      ),
    );

    // Verify NavigationBar is present
    expect(find.byType(NavigationBar), findsOneWidget);

    // Verify the child widget content is displayed
    expect(find.text('Home Screen'), findsOneWidget);

    // Verify 4 navigation destinations exist
    final destinations = tester.widgetList<NavigationDestination>(
      find.byType(NavigationDestination),
    );
    expect(destinations.length, 4);
    
    // Verify labels of the destinations
    expect(find.text('Trang chủ'), findsOneWidget);
    expect(find.text('Tìm kiếm'), findsOneWidget);
    expect(find.text('Đề xuất'), findsOneWidget);
    expect(find.text('Giới thiệu'), findsOneWidget);
  });
}
