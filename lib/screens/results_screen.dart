import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? analysis = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Animated transition on enter
    SchedulerBinding.instance.addPostFrameCallback((_) {
      // Optionally, you can add more animation triggers here
    });

    if (analysis == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Analysis Results')),
        backgroundColor: isDark ? const Color(0xFF263238) : const Color(0xFFF0F4F8),
        body: const Center(child: Text('No results to display.')),
      );
    }

    // Error handling: if backend returned an error
    if (analysis['error'] != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Analysis Results')),
        backgroundColor: isDark ? const Color(0xFF263238) : const Color(0xFFF0F4F8),
        body: Center(
          child: Card(
            margin: const EdgeInsets.all(32),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(analysis['error'].toString(), style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Highlighted key results
    final highlightCards = <Widget>[];
    if (analysis['classification'] != null) {
      highlightCards.add(
        Card(
          color: Colors.green[50],
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: const Icon(Icons.label_important, color: Colors.green),
            title: const Text('Classification', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(analysis['classification'].toString(), style: const TextStyle(fontSize: 18)),
          ),
        ),
      );
    }
    if (analysis['average_grain_size_mm'] != null) {
      highlightCards.add(
        Card(
          color: Colors.orange[50],
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: const Icon(Icons.straighten, color: Colors.orange),
            title: const Text('Average Grain Size (mm)', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(analysis['average_grain_size_mm'].toString(), style: const TextStyle(fontSize: 18)),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Analysis Results')),
      backgroundColor: isDark ? const Color(0xFF263238) : const Color(0xFFF0F4F8),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: ListView(
          key: ValueKey(analysis.hashCode),
          padding: const EdgeInsets.all(24.0),
          children: [
            ...highlightCards,
            Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sand Analysis Summary',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    if (analysis.containsKey('scale_object_type') && analysis['scale_object_type'] != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          children: [
                            const Icon(Icons.straighten, color: Colors.blueAccent),
                            const SizedBox(width: 8),
                            Text(
                              'Reference Detected: ',
                              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blue[800]),
                            ),
                            Expanded(
                              child: Text(
                                analysis['scale_object_type'],
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ...analysis.entries.where((entry) => entry.key != 'scale_object_type' && entry.key != 'classification' && entry.key != 'average_grain_size_mm' && entry.key != 'error').map((entry) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${entry.key}: ',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              Expanded(
                                child: Text(
                                  entry.value.toString(),
                                  style: const TextStyle(fontWeight: FontWeight.normal),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
