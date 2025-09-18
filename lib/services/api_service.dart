import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service for communicating with the sand analysis backend API.
///
/// Usage:
///   await ApiService.analyzeSand(imagePath: ..., latitude: ..., longitude: ...);
class ApiService {
  /// The backend endpoint for sand analysis.
  static const String _baseUrl = 'http://10.20.34.117:8000/analyze/'; // Local Wi-Fi IP for phone access

  /// Sends an image and GPS coordinates to the backend for analysis.
  ///
  /// Returns a map containing:
  ///   - gps_coordinates: {latitude, longitude}
  ///   - classification: String (Wentworth scale)
  ///   - average_grain_size_mm: float
  ///   - std_deviation_mm: float
  ///   - grain_count: int
  ///   - scale_pixels_per_mm: float
  ///   - scale_detection_confidence: float (0-1)
  ///   - segmentation_quality: float (0-1)
  ///   - size_distribution: dict
  static Future<Map<String, dynamic>> analyzeSand({
    required String imagePath,
    required double latitude,
    required double longitude,
  }) async {
    var request = http.MultipartRequest('POST', Uri.parse(_baseUrl));
    request.files.add(await http.MultipartFile.fromPath('image_file', imagePath));
    request.fields['gps_lat'] = latitude.toString();
    request.fields['gps_lon'] = longitude.toString();

    final response = await request.send();
    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      return json.decode(respStr) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to analyze sand: \\${response.statusCode}');
    }
  }
}
