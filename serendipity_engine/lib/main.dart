import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:serendipity_engine/presentation/screens/landing_page.dart';
import 'package:serendipity_engine/presentation/screens/home/navigation_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Serendipity Engine', home: const MainNavigationBar());
  }
}
