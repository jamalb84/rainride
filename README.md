# RainRide

RainRide is a smart weather-checking app designed specifically for **motorcyclists**. It helps you avoid rain on your daily commute by checking the weather not only at your starting point and destination—but **along the entire route**.

## 🚀 Features

### ✅ For All Users

* **Route-Based Rain Check**: Predicts if it will rain between two locations during a custom time window.
* **Smart City Detection**: Identifies major cities along your route and checks each one for rain.
* **Quick Route Add**: Save frequently used commutes like Home → Office.
* **Favorite Places**: Save "Home", "Office", or "Gym" for quick access.
* **Auto-Complete for Location Input**: Suggests place names while you type.
* **Dark Mode Theme**: Designed with a sleek, motorcyclist-inspired dark theme.
* **Bottom Tab Navigation**: Familiar layout like Instagram/TikTok with quick access to features.

### 🔐 Premium Features (Coming Soon)

* **Confidence Score**: Calculates an overall route rain score based on multiple cities.
* **Alternate Routes**: Suggests better paths to avoid rain.
* **Best Departure Time Suggestions**: Recommends optimal time to leave based on weather.
* **Built-in Notifications**: Sends alerts before commute if rain is expected.
* **Multiple Notification Times**: Customize more than one rain-check window.

## 📱 Screens

* **Main Tab**: List of saved routes with check, edit, and delete buttons
* **Add Tab**: Add new route with auto-complete, favorite saving, and time window
* **About Tab**: App overview, contact, and GitHub link

## 📦 Installation

**Android APK (Beta)**

* [Available on GitHub Repo](https://github.com/jamalb84/rainride)

Clone this repo and run:

```bash
flutter pub get
flutter run
```

Ensure you have:

* Flutter SDK
* Android Studio or emulator
* API keys configured in `geocoding_service.dart` and `weather_service.dart`

## 🔧 Configuration

1. **Geocoding API**: Maps.co API used to convert place names to coordinates
2. **Weather API**: Open-Meteo used to get hourly weather forecast per city
3. **Auto-Complete**: Location suggestions fetched live via Maps.co


## 👤 Author

* Developed by **silv3r**
* Email: [silv3r84@gmail.com](mailto:silv3r84@gmail.com)
* GitHub: [github.com/jamalb84/rainride](https://github.com/jamalb84/rainride)

---

## 📌 Notes

* Best used by daily riders, especially in cities with unpredictable weather.
* APK is currently in **beta** — feedback is welcomed!

Ride dry, ride smart 🌧️🏍️

— RainRide Team
