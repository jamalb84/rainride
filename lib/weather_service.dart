import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey = '92b7dca1b56135088337a92f901b4d47'; // Replace with your real API key

  Future<bool> willItRain({
    required double lat,
    required double lon,
    required int startHour,
    required int endHour,
  }) async {
    final url = Uri.parse(
        'https://api.openweathermap.org/data/3.0/onecall?lat=$lat&lon=$lon&exclude=current,minutely,daily,alerts&appid=$apiKey'
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final hourly = data['hourly'] as List;

      final now = DateTime.now().toUtc();
      final startTime = now.copyWith(hour: startHour, minute: 0);
      final endTime = now.copyWith(hour: endHour, minute: 0);

      for (var hour in hourly) {
        final forecastTime = DateTime.fromMillisecondsSinceEpoch(hour['dt'] * 1000, isUtc: true);
        if (forecastTime.isAfter(startTime) && forecastTime.isBefore(endTime)) {
          final weatherMain = hour['weather'][0]['main'].toLowerCase();
          if (weatherMain.contains('rain')) {
            return true;
          }
        }
      }
    }

    return false;
  }
}
