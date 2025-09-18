import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' as io;
import 'dart:typed_data';
import 'package:geolocator/geolocator.dart';
import '../services/api_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  String? _error;
  XFile? _previewPhoto;

  Uint8List? _webImageBytes;

  bool get _isDesktopOrWeb {
    if (kIsWeb) return true;
    try {
      return io.Platform.isWindows || io.Platform.isLinux || io.Platform.isMacOS;
    } catch (_) {
      return false;
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        setState(() {
          _previewPhoto = picked;
        });
        if (_isDesktopOrWeb && kIsWeb) {
          final bytes = await picked.readAsBytes();
          setState(() {
            _webImageBytes = bytes;
          });
        }
      }
    } catch (e) {
      setState(() => _error = 'Gallery error: $e');
    }
  }

  Future<void> _analyzePhoto() async {
    if (_previewPhoto == null) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      double latitude = 0.0;
      double longitude = 0.0;
      if (!_isDesktopOrWeb) {
        final Position position = await _getLocationWithPermission();
        latitude = position.latitude;
        longitude = position.longitude;
      }
      final analysis = await ApiService.analyzeSand(
        imagePath: _previewPhoto!.path,
        latitude: latitude,
        longitude: longitude,
      );
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted) {
        if (analysis['error'] != null) {
          setState(() => _error = analysis['error'].toString());
        } else {
          Navigator.pushReplacementNamed(context, '/results', arguments: analysis);
        }
      }
    } catch (e) {
      setState(() => _error = 'Error: $e');
    } finally {
      setState(() => _isLoading = false);
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Upload Sand Image')),
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
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Sand Image')),
      backgroundColor: isDark ? const Color(0xFF263238) : const Color(0xFFF0F4F8),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(48.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                _isDesktopOrWeb
                    ? 'Upload a sand image (with a ₹10 note for scale) from your computer.'
                    : 'Upload a sand image (with a ₹10 note for scale) from your phone.',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                icon: Icon(_isDesktopOrWeb ? Icons.upload_file : Icons.photo_library, size: 28),
                label: Text(_isDesktopOrWeb ? 'Select Image from Storage' : 'Select Image from Gallery', style: const TextStyle(fontSize: 18)),
                onPressed: _isLoading ? null : _pickFromGallery,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(220, 56),
                ),
              ),
              if (_previewPhoto != null) ...[
                const SizedBox(height: 32),
                if (_isDesktopOrWeb && kIsWeb && _webImageBytes != null)
                  Image.memory(_webImageBytes!, height: 240)
                else
                  Image.file(io.File(_previewPhoto!.path), height: 240),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.analytics),
                  label: const Text('Analyze'),
                  onPressed: _isLoading ? null : _analyzePhoto,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(180, 48),
                  ),
                ),
              ],
              if (_isLoading) ...[
                const SizedBox(height: 32),
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                const Text('Analyzing...', style: TextStyle(fontSize: 18)),
              ],
              if (_error != null) ...[
                const SizedBox(height: 24),
                Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 16)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
