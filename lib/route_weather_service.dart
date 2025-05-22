import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math';

class RouteWeatherService {
  final String apiKey = 'dbbaeca20de6df241df924e351bdddbd'; // replace this

  // Sample list of major Malaysian cities and towns
  final List<Map<String, dynamic>> cities = [
    {'name': 'Kuala Lumpur', 'lat': 3.1390, 'lon': 101.6869},
    {'name': 'Putrajaya', 'lat': 2.9264, 'lon': 101.6964},
    {'name': 'Kajang', 'lat': 2.9935, 'lon': 101.7870},
    {'name': 'Seremban', 'lat': 2.7258, 'lon': 101.9424},
    {'name': 'Melaka', 'lat': 2.1896, 'lon': 102.2501},
    {'name': 'Shah Alam', 'lat': 3.0738, 'lon': 101.5183},
    {'name': 'Petaling Jaya', 'lat': 3.1044, 'lon': 101.6400},
    {'name': 'Subang Jaya', 'lat': 3.0433, 'lon': 101.5806},
    {'name': 'Nilai', 'lat': 2.8155, 'lon': 101.7982},
    {'name': 'Bangi', 'lat': 2.9446, 'lon': 101.7881},
  ];

  Future<String> checkRainAlongRoute({
    required double fromLat,
    required double fromLon,
    required double toLat,
    required double toLon,
    required int startHour,
    required int endHour,
  }) async {
    final now = DateTime.now().toUtc();
    final startTime = now.copyWith(hour: startHour, minute: 0);
    final endTime = now.copyWith(hour: endHour, minute: 0);

    final minLat = min(fromLat, toLat);
    final maxLat = max(fromLat, toLat);
    final minLon = min(fromLon, toLon);
    final maxLon = max(fromLon, toLon);

    int rainHits = 0;

    for (var city in cities) {
      final cityLat = city['lat'];
      final cityLon = city['lon'];

      // Check if city falls within bounding box
      if (cityLat >= minLat &&
          cityLat <= maxLat &&
          cityLon >= minLon &&
          cityLon <= maxLon) {
        final url = Uri.parse(
          'https://api.openweathermap.org/data/3.0/onecall?lat=$cityLat&lon=$cityLon&exclude=current,minutely,daily,alerts&appid=$apiKey',
        );

        final response = await http.get(url);
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final hourly = data['hourly'] as List;

          for (var hour in hourly) {
            final forecastTime = DateTime.fromMillisecondsSinceEpoch(hour['dt'] * 1000, isUtc: true);
            if (forecastTime.isAfter(startTime) && forecastTime.isBefore(endTime)) {
              final weatherMain = hour['weather'][0]['main'].toLowerCase();
              if (weatherMain.contains('rain')) {
                rainHits++;
                break; // one rain hit is enough per city
              }
            }
          }
        }
      }
    }

    if (rainHits == 0) return "Clear ☀️";
    if (rainHits <= 2) return "Some Rain ☁️";
    return "Heavy Rain 🌧️";
  }
}
