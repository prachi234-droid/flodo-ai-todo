import 'package:flutter/material.dart';

import 'controllers/task_controller.dart';
import 'screens/home_screen.dart';
import 'services/local_storage_service.dart';

class FlodoTaskApp extends StatefulWidget {
  const FlodoTaskApp({super.key});

  @override
  State<FlodoTaskApp> createState() => _FlodoTaskAppState();
}

class _FlodoTaskAppState extends State<FlodoTaskApp> {
  late final TaskController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TaskController(storage: LocalStorageService())..initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF0E7490),
      brightness: Brightness.light,
    );

    return MaterialApp(
      title: 'Flodo Tasks',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFFF4F7FB),
        textTheme: Theme.of(context).textTheme.apply(
              bodyColor: const Color(0xFF102033),
              displayColor: const Color(0xFF102033),
            ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFF102033),
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: colorScheme.primary,
              width: 1.5,
            ),
          ),
        ),
      ),
      home: HomeScreen(controller: _controller),
    );
  }
}
