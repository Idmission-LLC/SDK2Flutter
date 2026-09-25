import 'package:flutter/material.dart';

import 'sdk_configuration_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blueGrey,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F172A), // Slate
          primary: const Color(0xFF0F172A),
          secondary: Colors.cyan,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC), // Slate 50
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F172A),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const SdkConfigurationPage(),
    );
  }
}
