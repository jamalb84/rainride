import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
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
                TypeAheadFormField<Map<String, dynamic>>(
                  textFieldConfiguration: TextFieldConfiguration(
                    decoration: InputDecoration(labelText: 'From'),
                    controller: TextEditingController(text: from),
                    style: TextStyle(color: Colors.white),
                  ),
                  suggestionsCallback: (pattern) async {
                    final geo = GeocodingService();
                    return await geo.getSuggestions(pattern);
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(suggestion['name']),
                    );
                  },
                  onSuggestionSelected: (suggestion) {
                    setState(() {
                      from = suggestion['name'];
                      fromLat = suggestion['lat'];
                      fromLon = suggestion['lon'];
                    });
                  },
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Required' : null,
                ),
                SizedBox(height: 20),
                TypeAheadFormField<Map<String, dynamic>>(
                  textFieldConfiguration: TextFieldConfiguration(
                    decoration: InputDecoration(labelText: 'To'),
                    controller: TextEditingController(text: to),
                    style: TextStyle(color: Colors.white),
                  ),
                  suggestionsCallback: (pattern) async {
                    final geo = GeocodingService();
                    return await geo.getSuggestions(pattern);
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(suggestion['name']),
                    );
                  },
                  onSuggestionSelected: (suggestion) {
                    setState(() {
                      to = suggestion['name'];
                      toLat = suggestion['lat'];
                      toLon = suggestion['lon'];
                    });
                  },
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Required' : null,
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
                    return (val == null || val < 0 || val > 23)
                        ? 'Enter hour (0-23)'
                        : null;
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
                    return (val == null || val < 0 || val > 23)
                        ? 'Enter hour (0-23)'
                        : null;
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
                          SnackBar(content: Text('Please select locations from suggestions')),
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
