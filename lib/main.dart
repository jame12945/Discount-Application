import 'package:discount_app/core/theme/theme.dart';
import 'package:discount_app/features/discount/presentation/pages/discount_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Discount App',
        theme: AppTheme.darkThemeMode,
        home: DiscountPage());
  }
}
