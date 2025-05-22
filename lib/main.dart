import 'package:flutter/material.dart';
import 'add_route_screen.dart';
import 'route_weather_service.dart';

void main() {
  runApp(RainRideApp());
}

class RainRideApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RainRide',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.black,
        textTheme: TextTheme(bodyMedium: TextStyle(color: Colors.white)),
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> routes = [
    {
      'from': 'Home',
      'to': 'Office',
      'lat': 3.1390,
      'lon': 101.6869,
      'toLat': 3.0738,
      'toLon': 101.5183,
      'startHour': 6,
      'endHour': 8,
    },
    {
      'from': 'Home',
      'to': 'Gym',
      'lat': 3.1200,
      'lon': 101.7000,
      'toLat': 3.0433,
      'toLon': 101.5806,
      'startHour': 17,
      'endHour': 18,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('RainRide')),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: routes.length,
        itemBuilder: (context, index) {
          final route = routes[index];
          return Card(
            color: Colors.grey[900],
            child: ListTile(
              title: Text('${route['from']} → ${route['to']}'),
              subtitle: Text('Time: ${route['startHour']}:00 - ${route['endHour']}:00'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                    child: Text('Check'),
                    onPressed: () async {
                      final weatherService = RouteWeatherService();
                      final result = await weatherService.checkRainAlongRoute(
                        fromLat: route['lat'],
                        fromLon: route['lon'],
                        toLat: route['toLat'],
                        toLon: route['toLon'],
                        startHour: route['startHour'],
                        endHour: route['endHour'],
                      );

                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text('Rain Forecast'),
                          content: Text('Route Status: $result'),
                        ),
                      );
                    },
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.white),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddRouteScreen(
                            existingRoute: route,
                            routeIndex: index,
                          ),
                        ),
                      );

                      if (result != null && result['data'] != null) {
                        setState(() {
                          routes[result['index']] = result['data'];
                        });
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () {
                      setState(() {
                        routes.removeAt(index);
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newRoute = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddRouteScreen()),
          );

          if (newRoute != null && newRoute['data'] != null) {
            setState(() {
              routes.add(newRoute['data']);
            });
          }
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.teal,
      ),
    );
  }
}
