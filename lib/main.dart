import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/camera_screen.dart';
import 'screens/results_screen.dart';

void main() {
  runApp(const BeachGrainSenseApp());
}

class BeachGrainSenseApp extends StatefulWidget {
  const BeachGrainSenseApp({super.key});

  @override
  State<BeachGrainSenseApp> createState() => _BeachGrainSenseAppState();
}

class _BeachGrainSenseAppState extends State<BeachGrainSenseApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Set initial theme based on system brightness only once
    if (_themeMode == ThemeMode.system) {
      final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      setState(() {
        _themeMode = brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
      });
    }
  }

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beach Grain Sense',
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF6EC6CA), // Soft teal
          secondary: const Color(0xFFB2DFDB),
          surface: Colors.white, // Use surface instead of deprecated background
        ),
        scaffoldBackgroundColor: const Color(0xFFF0F4F8),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF6EC6CA),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6EC6CA),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF37474F), // Blue-grey
          secondary: const Color(0xFF80CBC4),
          surface: const Color(0xFF37474F), // Use surface instead of deprecated background
        ),
        scaffoldBackgroundColor: const Color(0xFF263238),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF37474F),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF80CBC4),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF37474F),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      themeMode: _themeMode,
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(onToggleTheme: _toggleTheme, themeMode: _themeMode),
        '/camera': (context) => const CameraScreen(),
        '/results': (context) => const ResultsScreen(),
      },
    );
  }
}
