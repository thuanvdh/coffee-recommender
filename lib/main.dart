import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffee_recommender/app.dart';

void main() {
  runApp(
    const ProviderScope(
      child: CoffeeApp(),
    ),
  );
}
