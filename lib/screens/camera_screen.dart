import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import '../services/api_service.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _picker = ImagePicker();
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isLoading = false;
  String? _error;
  XFile? _previewPhoto;
  bool _showShutter = false;
  bool _isFocusing = false;

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

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    setState(() {
      _isFocusing = true;
    });
    await _triggerAutofocus();
    setState(() {
      _isFocusing = false;
    });
    setState(() {
      _showShutter = true;
    });
    await Future.delayed(const Duration(milliseconds: 120));
    setState(() {
      _showShutter = false;
    });
    try {
      final XFile photo = await _controller!.takePicture();
      setState(() {
        _previewPhoto = photo;
      });
    } catch (e) {
      setState(() => _error = 'Capture error: $e');
    }
  }

  Future<void> _analyzePhoto() async {
    if (_previewPhoto == null) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final Position position = await _getLocationWithPermission();
      final analysis = await ApiService.analyzeSand(
        imagePath: _previewPhoto!.path,
        latitude: position.latitude,
        longitude: position.longitude,
      );
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/results', arguments: analysis);
      }
    } catch (e) {
      setState(() => _error = 'Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _triggerAutofocus() async {
    if (_controller != null && _controller!.value.isInitialized) {
      try {
        await _controller!.setFocusMode(FocusMode.auto);
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

  Future<void> _pickFromGallery() async {
    try {
      final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        setState(() {
          _previewPhoto = picked;
        });
      }
    } catch (e) {
      setState(() => _error = 'Gallery error: $e');
    }
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_error!, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    onPressed: () {
                      setState(() {
                        _error = null;
                        _previewPhoto = null;
                      });
                    },
                  ),
                ],
              ),
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
    // Preview/Retake UI
    if (_previewPhoto != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Preview Photo')),
        backgroundColor: isDark ? const Color(0xFF263238) : const Color(0xFFF0F4F8),
        body: Stack(
          children: [
            Center(child: Image.file(File(_previewPhoto!.path))),
            if (_isLoading)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Analyzing...', style: TextStyle(color: Colors.white, fontSize: 18)),
                    ],
                  ),
                ),
              ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.replay),
                      label: const Text('Retake'),
                      onPressed: _isLoading
                          ? null
                          : () {
                              setState(() => _previewPhoto = null);
                            },
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.analytics),
                      label: const Text('Analyze'),
                      onPressed: _isLoading ? null : _analyzePhoto,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(140, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
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
    // Camera UI
    return Scaffold(
      appBar: AppBar(title: const Text('Capture Sand')),
      backgroundColor: isDark ? const Color(0xFF263238) : const Color(0xFFF0F4F8),
      body: Stack(
        children: [
          CameraPreview(_controller!),
          if (_showShutter)
            AnimatedOpacity(
              opacity: _showShutter ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 120),
              child: Container(color: Colors.white.withAlpha((0.7 * 255).toInt())),
            ),
          if (_isFocusing)
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent, width: 4),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Icon(Icons.center_focus_strong, color: Colors.blueAccent, size: 40),
              ),
            ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.camera, size: 28),
                        onPressed: _isLoading ? null : _takePicture,
                        label: const Text('Capture', style: TextStyle(fontSize: 20)),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(140, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.photo_library, size: 28),
                        onPressed: _isLoading ? null : _pickFromGallery,
                        label: const Text('Add from Phone Storage', style: TextStyle(fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(140, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ],
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
