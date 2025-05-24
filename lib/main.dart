import 'package:flutter/material.dart';
import 'add_route_screen.dart';
import 'weather_service.dart';

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
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> routes = [
    {
      'from': 'Home',
      'to': 'Office',
      'lat': 3.1390,
      'lon': 101.6869,
      'startHour': 6,
      'endHour': 8,
    },
    {
      'from': 'Home',
      'to': 'Gym',
      'lat': 3.1215,
      'lon': 101.6731,
      'startHour': 17,
      'endHour': 18,
    },
  ];

  void _addRoute(Map<String, dynamic> newRoute, {int? routeIndex}) {
    setState(() {
      if (routeIndex != null) {
        routes[routeIndex] = newRoute;
      } else {
        routes.add(newRoute);
      }
    });
  }

  void _editRoute(int index) async {
    final updatedRoute = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddRouteScreen(
          existingRoute: routes[index],
          routeIndex: index,
        ),
      ),
    );

    if (updatedRoute != null) {
      _addRoute(updatedRoute, routeIndex: index);
    }
  }

  void _deleteRoute(int index) {
    setState(() {
      routes.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('RainRide')),
      body: ListView.builder(
        itemCount: routes.length,
        itemBuilder: (context, index) {
          final route = routes[index];
          return Card(
            color: Colors.grey[900],
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text('${route['from']} → ${route['to']}'),
              subtitle: Text('Time: ${route['startHour']}:00 - ${route['endHour']}:00'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.check),
                    onPressed: () async {
                      final weatherService = WeatherService();
                      final rainExpected = await weatherService.willItRain(
                        lat: route['lat'],
                        lon: route['lon'],
                        startHour: route['startHour'],
                        endHour: route['endHour'],
                      );

                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text('Rain Forecast'),
                          content: Text(
                            rainExpected
                                ? 'Rain is expected on your way to ${route['to']}.'
                                : 'No rain expected on your way to ${route['to']}.',
                          ),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => _editRoute(index),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _deleteRoute(index),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          final newRoute = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddRouteScreen()),
          );

          if (newRoute != null) {
            _addRoute(newRoute);
          }
        },
      ),
    );
  }
}
