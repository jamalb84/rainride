//6831be12eb410024805231zwde1d9f3
import 'dart:convert';
import 'package:http/http.dart' as http;

class GeocodingService {
  final String apiKey = '6831be12eb410024805231zwde1d9f3'; // Replace with your real API key

  Future<Map<String, double>?> getCoordinatesFromPlace(String place) async {
    final url = Uri.parse(
        'https://geocode.maps.co/search?q=$place&api_key=$apiKey');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List && data.isNotEmpty) {
        final first = data[0];
        final lat = double.tryParse(first['lat']);
        final lon = double.tryParse(first['lon']);
        if (lat != null && lon != null) {
          return {'lat': lat, 'lon': lon};
        }
      }
    }
    return null;
  }

  Future<List<String>> suggestLocations(String query) async {
    if (query.isEmpty) return [];

    final url = Uri.parse(
        'https://geocode.maps.co/search?q=$query&api_key=$apiKey');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        return data
            .map<String>((item) => item['display_name']?.toString() ?? '')
            .where((name) => name.isNotEmpty)
            .toList();
      }
    }
    return [];
  }
}
