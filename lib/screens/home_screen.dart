import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback? onToggleTheme;
  final ThemeMode? themeMode;
  const HomeScreen({super.key, this.onToggleTheme, this.themeMode});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beach Grain Sense'),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round),
            tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            onPressed: onToggleTheme,
          ),
        ],
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Welcome to Beach Grain Sense',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Analyze sand grain size with your phone camera. Place a ₹10 note next to the sand for best results.',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt_rounded),
                  label: const Text('Start Analysis'),
                  onPressed: () => Navigator.pushNamed(context, '/camera'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 48),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
