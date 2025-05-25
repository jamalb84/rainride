import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
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

  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();

  int? _startHour;
  int? _endHour;
  double? _fromLat, _fromLon;
  double? _toLat, _toLon;

  @override
  void initState() {
    super.initState();
    if (widget.existingRoute != null) {
      final route = widget.existingRoute!;
      _fromController.text = route['from'] ?? '';
      _toController.text = route['to'] ?? '';
      _startHour = route['startHour'];
      _endHour = route['endHour'];
      _fromLat = route['fromLat'];
      _fromLon = route['fromLon'];
      _toLat = route['toLat'];
      _toLon = route['toLon'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(title: const Text('Add Route')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTypeAheadField(
                label: 'From',
                controller: _fromController,
                onSuggestionSelected: (suggestion) async {
                  _fromController.text = suggestion;
                  final coords = await GeocodingService().getCoordinatesFromPlace(suggestion);
                  if (coords != null) {
                    _fromLat = coords['lat'];
                    _fromLon = coords['lon'];
                  }
                },
              ),
              const SizedBox(height: 16),
              _buildTypeAheadField(
                label: 'To',
                controller: _toController,
                onSuggestionSelected: (suggestion) async {
                  _toController.text = suggestion;
                  final coords = await GeocodingService().getCoordinatesFromPlace(suggestion);
                  if (coords != null) {
                    _toLat = coords['lat'];
                    _toLon = coords['lon'];
                  }
                },
              ),
              const SizedBox(height: 24),
              _buildHourDropdown(
                label: 'Start Hour',
                value: _startHour,
                onChanged: (val) {
                  setState(() {
                    _startHour = val;
                    if (_endHour != null && (_endHour! <= _startHour!)) {
                      _endHour = null;
                    }
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildHourDropdown(
                label: 'End Hour',
                value: _endHour,
                onChanged: (val) => setState(() => _endHour = val),
                startHour: _startHour,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.pop(context, {
                      'from': _fromController.text,
                      'to': _toController.text,
                      'startHour': _startHour,
                      'endHour': _endHour,
                      'fromLat': _fromLat,
                      'fromLon': _fromLon,
                      'toLat': _toLat,
                      'toLon': _toLon,
                    });
                  }
                },
                child: const Text('Add Route'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC857),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeAheadField({
    required String label,
    required TextEditingController controller,
    required Function(String) onSuggestionSelected,
  }) {
    return TypeAheadFormField(
      textFieldConfiguration: TextFieldConfiguration(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: const Color(0xFF2C2C2E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      suggestionsCallback: (pattern) => GeocodingService().suggestLocations(pattern),
      itemBuilder: (context, suggestion) {
        return ListTile(
          title: Text(suggestion, style: const TextStyle(color: Colors.white)),
          tileColor: const Color(0xFF3A3A3C),
        );
      },
      onSuggestionSelected: onSuggestionSelected,
      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
    );
  }

  Widget _buildHourDropdown({
    required String label,
    required int? value,
    required Function(int?) onChanged,
    int? startHour,
  }) {
    final options = List.generate(24, (i) => i)
        .where((h) => startHour == null || h > startHour)
        .toList();

    return DropdownButtonFormField<int>(
      value: value,
      dropdownColor: const Color(0xFF2C2C2E),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFF2C2C2E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      style: const TextStyle(color: Colors.white),
      items: options
          .map((hour) => DropdownMenuItem(
        value: hour,
        child: Text('${hour.toString().padLeft(2, '0')}:00'),
      ))
          .toList(),
      onChanged: onChanged,
      validator: (val) => val == null ? 'Required' : null,
    );
  }
}
