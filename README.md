# RainRide

**RainRide** is a mobile app built to help motorcyclists plan smarter, safer commutes by checking rain forecasts not just at the start and end points, but across all major cities in between.


## 🌦️ Features

### For All Users:
- Set your commute route using location names with autocomplete support.
- Define custom start and end hours (including overnight commutes).
- Automatically checks weather conditions for cities along your route using OpenWeatherMap API.
- Identifies rain risks, classifies final commute score (Low / Moderate / High).
- View a scrollable result popup with copy-to-clipboard support.
- Keeps a history of previously searched routes, even after app restarts.
- Simple and responsive UI with dark theme and pastel-inspired highlights.

### Premium (Coming Soon):
- Route suggestion with alternate paths to avoid rain.
- Advanced analytics and hourly rain breakdown.
- Push notifications for urgent weather alerts (e.g., flash floods).
- Integration with real-time traffic data.

## 🧪 APIs Used

- [OpenRouteService](https://openrouteservice.org/) – for calculating the path between two locations.
- [OpenWeatherMap One Call API 3.0](https://openweathermap.org/api/one-call-3) – to get hourly rain forecast.
- [Maps.co Geocoding API](https://geocode.maps.co/) – to convert place names into coordinates.

## 🔧 Configuration

To run this app:

1. Clone the repo:
   ```bash
   git clone https://github.com/jamalb84/rainride.git
   cd rainride
   ```

2. Add your API keys in `route_weather_service.dart`:
   ```dart
   final String openRouteApiKey = 'YOUR_OPENROUTE_KEY';
   final String openWeatherApiKey = 'YOUR_OPENWEATHER_KEY';
   final String geocodeApiKey = 'YOUR_GEOCODE_KEY';
   ```

3. Run it:
   ```bash
   flutter pub get
   flutter run
   ```

## 📱 APK Build

To build a release APK:
```bash
flutter build apk --release --no-tree-shake-icons
```

## 📬 Feedback & Bugs

If you have feedback or found a bug, email the developer at:

📧 silv3r84@gmail.com

---

Made with ❤️ for Malaysian riders — *Ride Dry, Ride Smart*.
