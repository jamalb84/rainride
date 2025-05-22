import 'dart:convert';
import 'package:http/http.dart' as http;

class GeocodingService {
  final String apiKey = '5a74c42f591049aba41c40e7405e88bb'; // 🔁 replace this with your real key

  Future<Map<String, double>?> getCoordinatesFromPlace(String place) async {
    final url = Uri.parse(
      'https://api.opencagedata.com/geocode/v1/json?q=$place&key=$apiKey&limit=1',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'].isNotEmpty) {
        final geometry = data['results'][0]['geometry'];
        return {
          'lat': geometry['lat'],
          'lon': geometry['lng'],
        };
      }
    }

    return null; // if no results
  }
}
