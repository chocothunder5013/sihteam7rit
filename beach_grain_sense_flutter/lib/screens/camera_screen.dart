import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import '../services/api_service.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      _controller = CameraController(_cameras![0], ResolutionPreset.medium);
      await _controller!.initialize();
      setState(() {});
    } catch (e) {
      setState(() => _error = 'Camera error: $e');
    }
  }

  Future<Position> _getLocationWithPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied by user.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied. Please enable it in settings.');
    }
    return await Geolocator.getCurrentPosition();
  }

  Future<void> _takePictureAndAnalyze() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }
    try {
      final XFile photo = await _controller!.takePicture();
      final Position position = await _getLocationWithPermission();
      final analysis = await ApiService.analyzeSand(
        imagePath: photo.path,
        latitude: position.latitude,
        longitude: position.longitude,
      );
      if (!mounted) return;
      // Add a short delay for smoother transition
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/results', arguments: analysis);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Error: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _triggerAutofocus() async {
    if (_controller != null && _controller!.value.isInitialized) {
      try {
        await _controller!.setFocusMode(FocusMode.auto);
        // Optionally, trigger focus at center (if supported)
        await _controller!.setFocusPoint(const Offset(0.5, 0.5));
      } catch (e) {
        setState(() => _error = 'Focus error: $e');
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Capture Sand')),
        body: Center(
          child: Card(
            margin: const EdgeInsets.all(32),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(_error!, style: const TextStyle(fontSize: 16)),
            ),
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF263238) : const Color(0xFFF0F4F8),
      );
    }
    if (_controller == null || !_controller!.value.isInitialized) {
      return Scaffold(
        appBar: AppBar(title: const Text('Capture Sand')),
        body: const Center(child: CircularProgressIndicator()),
        backgroundColor: isDark ? const Color(0xFF263238) : const Color(0xFFF0F4F8),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Capture Sand')),
      backgroundColor: isDark ? const Color(0xFF263238) : const Color(0xFFF0F4F8),
      body: Stack(
        children: [
          CameraPreview(_controller!),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator()),
            ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.camera, size: 28),
                    onPressed: _isLoading ? null : _takePictureAndAnalyze,
                    label: const Text('Capture & Analyze', style: TextStyle(fontSize: 20)),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(180, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Circular, compact focus button
                  SizedBox(
                    width: 56,
                    height: 56,
                    child: FloatingActionButton(
                      heroTag: 'focusBtn',
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      onPressed: _isLoading ? null : _triggerAutofocus,
                      child: const Icon(Icons.center_focus_strong, size: 28),
                      tooltip: 'Focus',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
