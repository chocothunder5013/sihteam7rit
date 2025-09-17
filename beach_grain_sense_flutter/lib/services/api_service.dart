import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'http://10.20.34.117:8000/analyze/'; // Updated to your computer's LAN IP

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
