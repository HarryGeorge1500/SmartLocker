import 'package:http/http.dart' as http;
import 'dart:convert';

class GraphHopperHelper {
  final String apiKey;
  final String apiUrl = 'https://graphhopper.com/api/1/route';

  GraphHopperHelper({required this.apiKey, required double startLat, required double startLng,
    required double endLat, required double endLng});

  Future<Map<String, dynamic>> getDirections({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    String profile = 'car', // Add this parameter
  }) async {
    try {
      String url = '$apiUrl?point=$endLat,$endLng&point=$startLat,$startLng&key=$apiKey&profile=$profile'; // Add profile parameter to URL
      http.Response response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception('Failed to get directions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get directions: $e');
    }
  }
}
