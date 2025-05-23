import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math';

class RouteWeatherService {
  final String openRouteApiKey = '5b3ce3597851110001cf6248b65aa4407799420099062a292bfbe853'; // Replace with your key
  final String openWeatherApiKey = 'dbbaeca20de6df241df924e351bdddbd';    // Replace with your key

  final List<Map<String, dynamic>> klangValleyCities = [
    {'name': 'Kuala Lumpur', 'lat': 3.1390, 'lon': 101.6869},
    {'name': 'Petaling Jaya', 'lat': 3.1044, 'lon': 101.6400},
    {'name': 'Subang Jaya', 'lat': 3.0433, 'lon': 101.5806},
    {'name': 'Shah Alam', 'lat': 3.0738, 'lon': 101.5183},
    {'name': 'Cheras', 'lat': 3.0851, 'lon': 101.7409},
    {'name': 'Ampang', 'lat': 3.1617, 'lon': 101.7496},
    {'name': 'Puchong', 'lat': 2.9990, 'lon': 101.6162},
    {'name': 'Bangi', 'lat': 2.9446, 'lon': 101.7881},
    {'name': 'Kajang', 'lat': 2.9935, 'lon': 101.7870},
    {'name': 'Putrajaya', 'lat': 2.9264, 'lon': 101.6964},
    {'name': 'Cyberjaya', 'lat': 2.9226, 'lon': 101.6507},
    {'name': 'Seri Kembangan', 'lat': 3.0190, 'lon': 101.7070},
    {'name': 'Setapak', 'lat': 3.1949, 'lon': 101.7180},
    {'name': 'Gombak', 'lat': 3.2320, 'lon': 101.6926},
    {'name': 'Selayang', 'lat': 3.2667, 'lon': 101.6500},
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

    final routeCoords = await _getRouteCoordinates(fromLat, fromLon, toLat, toLon);
    if (routeCoords.isEmpty) return '⚠️ Could not retrieve route.';

    List<String> rainyCities = [];

    for (var city in klangValleyCities) {
      final match = routeCoords.any((point) {
        final double distance = _haversineDistance(
            city['lat'], city['lon'],
            point['lat'] as double, point['lon'] as double
        );
        return distance <= 5.0;
      });

      if (match) {
        final rain = await _checkCityRain(city, startTime, endTime);
        if (rain != null) rainyCities.add('${city['name']} (${rain}%)');
      }
    }

    if (rainyCities.isEmpty) {
      return '✅ All clear — no rain expected along this route.';
    } else {
      final risk = rainyCities.length == 1
          ? 'Low Risk'
          : (rainyCities.length <= 3 ? 'Moderate Risk' : 'High Risk');
      return '🌧️ Rain expected in ${rainyCities.length} cities:\n'
          '- ${rainyCities.join('\n- ')}\n\n'
          '☁️ Final Commute Score: $risk';
    }
  }

  Future<List<Map<String, dynamic>>> _getRouteCoordinates(
      double fromLat, double fromLon, double toLat, double toLon) async {
    final url = Uri.parse('https://api.openrouteservice.org/v2/directions/driving-car/geojson');
    final body = jsonEncode({
      "coordinates": [
        [fromLon, fromLat],
        [toLon, toLat]
      ]
    });

    final response = await http.post(
      url,
      headers: {
        'Authorization': openRouteApiKey,
        'Content-Type': 'application/json'
      },
      body: body,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final coords = data['features'][0]['geometry']['coordinates'] as List;

      return coords.map((c) => {'lon': c[0], 'lat': c[1]}).toList();
    }

    return [];
  }

  Future<int?> _checkCityRain(Map<String, dynamic> city, DateTime start, DateTime end) async {
    final lat = city['lat'];
    final lon = city['lon'];

    final url = Uri.parse(
      'https://api.openweathermap.org/data/3.0/onecall?lat=$lat&lon=$lon&exclude=current,minutely,daily,alerts&appid=$openWeatherApiKey&units=metric',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final hourly = data['hourly'] as List;

      for (var hour in hourly) {
        final forecastTime = DateTime.fromMillisecondsSinceEpoch(hour['dt'] * 1000, isUtc: true);
        if (forecastTime.isAfter(start) && forecastTime.isBefore(end)) {
          final weatherMain = hour['weather'][0]['main'].toLowerCase();
          final rainChance = hour['pop'] != null ? (hour['pop'] * 100).round() : null;

          if (weatherMain.contains('rain')) {
            return rainChance;
          }
        }
      }
    }

    return null;
  }

  double _haversineDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0;
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) * cos(_degToRad(lat2)) *
            sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _degToRad(double deg) => deg * (pi / 180);
}
