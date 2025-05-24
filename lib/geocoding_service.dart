//6831be12eb410024805231zwde1d9f3
import 'dart:convert';
import 'package:http/http.dart' as http;

class GeocodingService {
  final String apiKey = '6831be12eb410024805231zwde1d9f3'; // <-- Replace this with your actual key

  Future<Map<String, double>?> getCoordinatesFromPlace(String place) async {
    final url = Uri.parse(
        'https://geocode.maps.co/search?q=$place&api_key=$apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        final first = data.first;
        final lat = double.tryParse(first['lat']);
        final lon = double.tryParse(first['lon']);
        if (lat != null && lon != null) {
          return {'lat': lat, 'lon': lon};
        }
      }
    }

    return null;
  }

  Future<List<String>> suggestLocations(String pattern) async {
    final url = Uri.parse(
        'https://geocode.maps.co/search?q=$pattern&api_key=$apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map<String>((item) => item['display_name'].toString()).toList();
    }

    return [];
  }
}
