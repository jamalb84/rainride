//5b3ce3597851110001cf6248b65aa4407799420099062a292bfbe853 - openroute
//dbbaeca20de6df241df924e351bdddbd -- openweather
//6831be12eb410024805231zwde1d9f3 -- geocode

// lib/route_weather_service.dart
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class RouteWeatherService {
  final String openRouteApiKey = '5b3ce3597851110001cf6248b65aa4407799420099062a292bfbe853';
  final String openWeatherApiKey = 'dbbaeca20de6df241df924e351bdddbd';

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
    final endTime = endHour > startHour
        ? now.copyWith(hour: endHour, minute: 0)
        : now.add(Duration(days: 1)).copyWith(hour: endHour, minute: 0);

    final routeCoords = await _getRouteCoordinates(fromLat, fromLon, toLat, toLon);
    if (routeCoords.isEmpty) return '⚠️ Could not retrieve route coordinates.';

    Set<String> rainyCities = {};
    Set<String> clearCities = {};

    for (var point in routeCoords) {
      final lat = point['lat'];
      final lon = point['lon'];

      if (lat == null || lon == null) continue;

      final cityName = await _getCityName(lat, lon);
      if (cityName == null || cityName.isEmpty) continue;

      final rainChance = await _checkRainChance(lat, lon, startTime, endTime);
      if (rainChance != null) {
        rainyCities.add('$cityName ($rainChance%)');
      } else {
        clearCities.add(cityName);
      }
    }

    final risk = rainyCities.isEmpty
        ? 'Low Risk'
        : (rainyCities.length == 1 ? 'Moderate Risk' : 'High Risk');

    String result = '';
    if (rainyCities.isNotEmpty) {
      result += '🌧️ Rain expected in ${rainyCities.length} cities:\n';
      result += rainyCities.toList().map((city) => '- $city').join('\n');
      result += '\n\n';
    }

    if (clearCities.isNotEmpty) {
      result += '✅ Clear cities:\n';
      result += clearCities.toList().map((city) => '- $city').join('\n');
      result += '\n\n';
    }

    result += '☁️ Final Commute Score: $risk';

    return result;
  }

  Future<List<Map<String, double>>> _getRouteCoordinates(
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

      // Calculate route distance
      double totalDistance = 0;
      for (int i = 1; i < coords.length; i++) {
        final lat1 = coords[i - 1][1];
        final lon1 = coords[i - 1][0];
        final lat2 = coords[i][1];
        final lon2 = coords[i][0];
        totalDistance += _haversineDistance(lat1, lon1, lat2, lon2);
      }

      // Decide sampling rate
      double distanceThreshold;
      if (totalDistance <= 50) {
        distanceThreshold = 1.0; // more dense
      } else if (totalDistance <= 100) {
        distanceThreshold = 5.0;
      } else {
        distanceThreshold = 10.0;
      }

      // Filter points
      List<Map<String, double>> filtered = [];
      Map<String, double>? lastPoint;

      for (var coord in coords) {
        final point = {
          'lon': (coord[0] as num).toDouble(),
          'lat': (coord[1] as num).toDouble(),
        };

        if (lastPoint == null ||
            _haversineDistance(
                lastPoint['lat']!, lastPoint['lon']!, point['lat']!, point['lon']!) >= distanceThreshold) {
          filtered.add(point);
          lastPoint = point;
        }
      }

      return filtered;
    }

    return [];
  }

  Future<String?> _getCityName(double lat, double lon) async {
    final url = Uri.parse('https://geocode.maps.co/reverse?lat=$lat&lon=$lon&api_key=6831be12eb410024805231zwde1d9f3');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['address']?['city'] ??
          data['address']?['town'] ??
          data['address']?['village'] ??
          data['address']?['suburb'] ??
          data['display_name'];
    }

    return null;
  }

  Future<int?> _checkRainChance(
      double lat, double lon, DateTime start, DateTime end) async {
    final url = Uri.parse(
      'https://api.openweathermap.org/data/3.0/onecall?lat=$lat&lon=$lon&exclude=current,minutely,daily,alerts&appid=$openWeatherApiKey&units=metric',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final hourly = data['hourly'] as List;

      for (var hour in hourly) {
        final forecastTime =
        DateTime.fromMillisecondsSinceEpoch(hour['dt'] * 1000, isUtc: true);
        if (forecastTime.isAfter(start) && forecastTime.isBefore(end)) {
          final weatherMain = hour['weather'][0]['main'].toLowerCase();
          final rainChance = hour['pop'] != null
              ? (hour['pop'] * 100).round()
              : null;
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
