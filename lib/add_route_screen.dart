import 'package:flutter/material.dart';
import 'geocoding_service.dart';

class AddRouteScreen extends StatefulWidget {
  final Map<String, dynamic>? existingRoute;
  final int? routeIndex;

  AddRouteScreen({this.existingRoute, this.routeIndex});

  @override
  _AddRouteScreenState createState() => _AddRouteScreenState();
}

class _AddRouteScreenState extends State<AddRouteScreen> {
  final _formKey = GlobalKey<FormState>();

  String from = '';
  String to = '';
  double? fromLat;
  double? fromLon;
  double? toLat;
  double? toLon;
  int? startHour;
  int? endHour;

  @override
  void initState() {
    super.initState();
    if (widget.existingRoute != null) {
      final route = widget.existingRoute!;
      from = route['from'];
      to = route['to'];
      fromLat = route['lat'];
      fromLon = route['lon'];
      toLat = route['toLat'];
      toLon = route['toLon'];
      startHour = route['startHour'];
      endHour = route['endHour'];
    }
  }

  @override
  Widget build(BuildContext context) {
    final inputStyle = InputDecorationTheme(
      labelStyle: TextStyle(color: Colors.white),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.tealAccent),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(widget.existingRoute == null ? 'Add New Route' : 'Edit Route')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Theme(
          data: Theme.of(context).copyWith(inputDecorationTheme: inputStyle),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  initialValue: from,
                  decoration: InputDecoration(labelText: 'From'),
                  style: TextStyle(color: Colors.white),
                  onSaved: (value) => from = value ?? '',
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
                SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.teal,
                  ),
                  onPressed: () async {
                    _formKey.currentState!.save();
                    if (from.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please enter a "From" location')),
                      );
                      return;
                    }
                    final geo = GeocodingService();
                    final coords = await geo.getCoordinatesFromPlace(from);
                    if (coords != null) {
                      setState(() {
                        fromLat = coords['lat'];
                        fromLon = coords['lon'];
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('From location found: (${fromLat!.toStringAsFixed(4)}, ${fromLon!.toStringAsFixed(4)})')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Could not find coordinates for "From"')),
                      );
                    }
                  },
                  child: Text('Find From Coordinates'),
                ),
                SizedBox(height: 20),
                TextFormField(
                  initialValue: to,
                  decoration: InputDecoration(labelText: 'To'),
                  style: TextStyle(color: Colors.white),
                  onSaved: (value) => to = value ?? '',
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
                SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.teal,
                  ),
                  onPressed: () async {
                    _formKey.currentState!.save();
                    if (to.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please enter a "To" location')),
                      );
                      return;
                    }
                    final geo = GeocodingService();
                    final coords = await geo.getCoordinatesFromPlace(to);
                    if (coords != null) {
                      setState(() {
                        toLat = coords['lat'];
                        toLon = coords['lon'];
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('To location found: (${toLat!.toStringAsFixed(4)}, ${toLon!.toStringAsFixed(4)})')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Could not find coordinates for "To"')),
                      );
                    }
                  },
                  child: Text('Find To Coordinates'),
                ),
                SizedBox(height: 20),
                TextFormField(
                  initialValue: startHour?.toString() ?? '',
                  decoration: InputDecoration(labelText: 'Start Hour (0-23)'),
                  style: TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => startHour = int.tryParse(value ?? ''),
                  validator: (value) {
                    final val = int.tryParse(value ?? '');
                    return (val == null || val < 0 || val > 23) ? 'Enter hour (0-23)' : null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  initialValue: endHour?.toString() ?? '',
                  decoration: InputDecoration(labelText: 'End Hour (0-23)'),
                  style: TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => endHour = int.tryParse(value ?? ''),
                  validator: (value) {
                    final val = int.tryParse(value ?? '');
                    return (val == null || val < 0 || val > 23) ? 'Enter hour (0-23)' : null;
                  },
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.teal,
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      if (fromLat == null || fromLon == null || toLat == null || toLon == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please find both From and To coordinates first')),
                        );
                        return;
                      }

                      Navigator.pop(context, {
                        'index': widget.routeIndex,
                        'data': {
                          'from': from,
                          'to': to,
                          'lat': fromLat,
                          'lon': fromLon,
                          'toLat': toLat,
                          'toLon': toLon,
                          'startHour': startHour,
                          'endHour': endHour,
                        }
                      });
                    }
                  },
                  child: Text(widget.existingRoute == null ? 'Add Route' : 'Update Route'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
