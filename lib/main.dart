import 'package:flutter/material.dart';
import 'add_route_screen.dart';
import 'route_weather_service.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(RainRideApp());
}

class RainRideApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RainRide',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Color(0xFF1C1C1E),
        appBarTheme: AppBarTheme(backgroundColor: Color(0xFF2C2C2E)),
        textTheme: ThemeData.dark().textTheme.apply(bodyColor: Colors.white),
        colorScheme: ColorScheme.dark(primary: Color(0xFFFFC857)),
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<Map<String, dynamic>> routes = [];
  int _selectedIndex = 0;
  bool _isLoading = false;

  void _onTabTapped(int index) async {
    if (index == 1) {
      final newRoute = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AddRouteScreen()),
      );
      if (newRoute != null) {
        setState(() {
          routes.add(newRoute);
        });
      }
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
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
      setState(() {
        routes[index] = updatedRoute;
      });
    }
  }

  void _deleteRoute(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Route"),
        content: Text("Are you sure you want to delete this route?"),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: Text("Delete", style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        routes.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      _buildRoutesView(),
      SizedBox.shrink(),
      _buildAboutSection(),
    ];

    return Scaffold(
      backgroundColor: Color(0xFF1C1C1E),
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/rainride_logo.png', height: 32),
            SizedBox(width: 10),
            Text('RainRide', style: TextStyle(color: Color(0xFFFFF6E0))),
          ],
        ),
      ),
      body: Stack(
        children: [
          _selectedIndex == 1 ? SizedBox.shrink() : pages[_selectedIndex],
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(child: CircularProgressIndicator(color: Color(0xFFFFC857))),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF2C2C2E),
        selectedItemColor: Color(0xFFFFC857),
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.route), label: 'Routes'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: 'Add'),
          BottomNavigationBarItem(icon: Icon(Icons.info_outline), label: 'About'),
        ],
      ),
    );
  }

  Widget _buildRoutesView() {
    if (routes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'No routes added yet.\nTap the "+" tab below to add one.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    return ListView(
      children: routes.asMap().entries.map((entry) {
        final index = entry.key;
        final route = entry.value;
        return Card(
          color: Color(0xFF2C2C2E),
          margin: EdgeInsets.all(8.0),
          child: ListTile(
            title: Text('${route['from']} → ${route['to']}', style: TextStyle(color: Colors.white)),
            subtitle: Text('Time: ${route['startHour']}:00 - ${route['endHour']}:00', style: TextStyle(color: Colors.white70)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.white),
                  onPressed: () => _editRoute(index),
                ),
                IconButton(
                  icon: Icon(Icons.check_circle, color: Colors.white),
                  onPressed: () async {
                    if (route['fromLat'] == null || route['toLat'] == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Missing coordinates. Please edit this route.")),
                      );
                      return;
                    }

                    setState(() => _isLoading = true);

                    final service = RouteWeatherService();
                    final result = await service.checkRainAlongRoute(
                      fromLat: route['fromLat'],
                      fromLon: route['fromLon'],
                      toLat: route['toLat'],
                      toLon: route['toLon'],
                      startHour: route['startHour'],
                      endHour: route['endHour'],
                    );

                    setState(() => _isLoading = false);

                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        backgroundColor: Color(0xFF2C2C2E),
                        title: Text('Rain Forecast', style: TextStyle(color: Colors.white)),
                        content: SingleChildScrollView(
                          child: Text(result, style: TextStyle(color: Colors.white70)),
                        ),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () => _deleteRoute(index),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAboutSection() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/rainride_logo.png', height: 100),
            SizedBox(height: 20),
            Text(
              'RainRide helps motorcyclists plan smarter routes by checking for rain not just at the start and end, but all cities in between.\n\n'
                  'Ride Dry, Ride Smart\n\n'
                  '📖 Visit the README on GitHub for full usage instructions.\n\n'
                  '🤝 Brought to you by silv3r\n'
                  '🔗 GitHub: github.com/jamalb84/rainride\n',
              style: TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(color: Colors.white70, fontSize: 16),
                children: [
                  TextSpan(text: '🐞 Found a bug or have feedback?\n'),
                  TextSpan(text: 'Just '),
                  TextSpan(
                    text: 'email me here.',
                    style: TextStyle(
                      color: Color(0xFFFFC857),
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        final Uri emailUri = Uri(
                          scheme: 'mailto',
                          path: 'silv3r84@gmail.com',
                          query: 'subject=RainRide Feedback or Bug Report',
                        );
                        if (await canLaunchUrl(emailUri)) {
                          await launchUrl(emailUri);
                        }
                      },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}
