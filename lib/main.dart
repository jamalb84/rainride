import 'package:flutter/material.dart';

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

class HomeScreen extends StatelessWidget {
  final List<Map<String, String>> routes = [
    {'from': 'Home', 'to': 'Office', 'time': '6:00 AM - 8:00 AM'},
    {'from': 'Home', 'to': 'Gym', 'time': '5:00 PM - 6:00 PM'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('RainRide')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Text('Your Commute Routes:', style: TextStyle(fontSize: 18)),
          SizedBox(height: 10),
          ...routes.map((route) => Card(
            color: Colors.grey[900],
            child: ListTile(
              title: Text('${route['from']} → ${route['to']}'),
              subtitle: Text('Time: ${route['time']}'),
            ),
          )),
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              // Placeholder for weather check
            },
            child: Text('Check Weather'),
          ),
        ],
      ),
    );
  }
}
