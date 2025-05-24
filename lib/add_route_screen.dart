import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'geocoding_service.dart';

class AddRouteScreen extends StatefulWidget {
  final Map<String, dynamic>? existingRoute;
  final int? routeIndex;

  const AddRouteScreen({Key? key, this.existingRoute, this.routeIndex}) : super(key: key);

  @override
  _AddRouteScreenState createState() => _AddRouteScreenState();
}

class _AddRouteScreenState extends State<AddRouteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fromController = TextEditingController();
  final _toController = TextEditingController();

  double? lat;
  double? lon;
  int? startHour;
  int? endHour;
  String? favoriteLabel;

  Map<String, String> favoritePlaces = {};

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    if (widget.existingRoute != null) {
      _fromController.text = widget.existingRoute!['from'];
      _toController.text = widget.existingRoute!['to'];
      lat = widget.existingRoute!['lat'];
      lon = widget.existingRoute!['lon'];
      startHour = widget.existingRoute!['startHour'];
      endHour = widget.existingRoute!['endHour'];
    }
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      favoritePlaces = {
        'Home': prefs.getString('fav_home') ?? '',
        'Office': prefs.getString('fav_office') ?? '',
        'Gym': prefs.getString('fav_gym') ?? '',
      }..removeWhere((key, value) => value.isEmpty);
    });
  }

  Future<void> _saveFavorite(String label, String location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fav_${label.toLowerCase()}', location);
    _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    final inputStyle = TextStyle(color: Colors.white);
    final labelStyle = TextStyle(color: Color(0xFFFFC857)); // racing yellow-orange

    return Scaffold(
      backgroundColor: Color(0xFF1C1C1E),
      appBar: AppBar(
        backgroundColor: Color(0xFF2C2C2E),
        title: Text('Add New Route', style: TextStyle(color: Color(0xFFFFF6E0))),
        iconTheme: IconThemeData(color: Color(0xFFFFF6E0)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (favoritePlaces.isNotEmpty) ...[
                Text('Quick Select Favorite:', style: labelStyle),
                Wrap(
                  spacing: 10,
                  children: favoritePlaces.entries.map((entry) => ActionChip(
                    label: Text(entry.key),
                    backgroundColor: Color(0xFF5856D6),
                    labelStyle: TextStyle(color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _fromController.text = entry.value;
                      });
                    },
                  )).toList(),
                ),
                SizedBox(height: 20),
              ],
              TypeAheadFormField(
                textFieldConfiguration: TextFieldConfiguration(
                  controller: _fromController,
                  style: inputStyle,
                  decoration: InputDecoration(
                    labelText: 'From',
                    labelStyle: labelStyle,
                    filled: true,
                    fillColor: Color(0xFF2C2C2E),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                suggestionsCallback: (pattern) async {
                  return await GeocodingService().suggestLocations(pattern);
                },
                itemBuilder: (context, suggestion) {
                  return ListTile(
                    tileColor: Colors.white,
                    title: Text(suggestion.toString(), style: TextStyle(color: Colors.black)),
                  );
                },
                onSuggestionSelected: (suggestion) async {
                  _fromController.text = suggestion.toString();
                  final coords = await GeocodingService().getCoordinatesFromPlace(suggestion.toString());
                  if (coords != null) {
                    lat = coords['lat'];
                    lon = coords['lon'];
                  }
                },
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 10),
              TypeAheadFormField(
                textFieldConfiguration: TextFieldConfiguration(
                  controller: _toController,
                  style: inputStyle,
                  decoration: InputDecoration(
                    labelText: 'To',
                    labelStyle: labelStyle,
                    filled: true,
                    fillColor: Color(0xFF2C2C2E),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                suggestionsCallback: (pattern) async {
                  return await GeocodingService().suggestLocations(pattern);
                },
                itemBuilder: (context, suggestion) {
                  return ListTile(
                    tileColor: Colors.white,
                    title: Text(suggestion.toString(), style: TextStyle(color: Colors.black)),
                  );
                },
                onSuggestionSelected: (suggestion) async {
                  _toController.text = suggestion.toString();
                  final coords = await GeocodingService().getCoordinatesFromPlace(suggestion.toString());
                  if (coords != null) {
                    lat = coords['lat'];
                    lon = coords['lon'];
                  }
                },
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Mark "From" as Favorite',
                  labelStyle: labelStyle,
                  filled: true,
                  fillColor: Color(0xFF2C2C2E),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                dropdownColor: Color(0xFF2C2C2E),
                style: inputStyle,
                items: ['Home', 'Office', 'Gym'].map((label) => DropdownMenuItem(
                  value: label,
                  child: Text(label, style: TextStyle(color: Colors.white)),
                )).toList(),
                onChanged: (value) {
                  if (value != null && _fromController.text.isNotEmpty) {
                    _saveFavorite(value, _fromController.text);
                  }
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Start Hour (0-23)',
                  labelStyle: labelStyle,
                  filled: true,
                  fillColor: Color(0xFF2C2C2E),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                style: inputStyle,
                keyboardType: TextInputType.number,
                onSaved: (value) => startHour = int.tryParse(value ?? ''),
                validator: (value) {
                  final val = int.tryParse(value ?? '');
                  return (val == null || val < 0 || val > 23) ? 'Enter hour (0-23)' : null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'End Hour (0-23)',
                  labelStyle: labelStyle,
                  filled: true,
                  fillColor: Color(0xFF2C2C2E),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                style: inputStyle,
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
                  backgroundColor: Color(0xFF5856D6), // sporty blue-purple
                  foregroundColor: Colors.white,
                ),
                child: Text('Add Route'),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    Navigator.pop(context, {
                      'from': _fromController.text,
                      'to': _toController.text,
                      'lat': lat,
                      'lon': lon,
                      'startHour': startHour,
                      'endHour': endHour,
                    });
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
