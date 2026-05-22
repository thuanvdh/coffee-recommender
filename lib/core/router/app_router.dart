import 'package:coffee_recommender/features/home/presentation/screens/home_screen.dart';
import 'package:coffee_recommender/features/navigation/presentation/main_shell.dart';
import 'package:coffee_recommender/features/search/presentation/screens/search_screen.dart';
import 'package:coffee_recommender/features/search/presentation/screens/shop_detail_screen.dart';
import 'package:coffee_recommender/features/suggest/presentation/screens/suggest_screen.dart';
import 'package:coffee_recommender/features/about/presentation/screens/about_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        final location = state.uri.path;
        int index = 0;
        if (location.startsWith('/search')) {
          index = 1;
        } else if (location.startsWith('/suggest')) {
          index = 2;
        } else if (location.startsWith('/about')) {
          index = 3;
        }
        return MainShell(
          currentIndex: index,
          onTap: (newIndex) {
            final paths = ['/', '/search', '/suggest', '/about'];
            context.go(paths[newIndex]);
          },
          child: child,
        );
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/search',
          builder: (context, state) => const SearchScreen(),
        ),
        GoRoute(
          path: '/suggest',
          builder: (context, state) => const SuggestScreen(),
        ),
        GoRoute(
          path: '/about',
          builder: (context, state) => const AboutScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/shop/:slug',
      builder: (context, state) {
        final slug = state.pathParameters['slug'] ?? '';
        return ShopDetailScreen(slug: slug);
      },
    ),
  ],
);

