import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final TextEditingController _placeController = TextEditingController();
  late GoogleMapController _mapController;

  LatLng _currentLatLng = const LatLng(14.5995, 120.9842); // Default: Manila
  String _temperature = '';
  String _weatherDesc = '';
  Marker? _marker;

  final String weatherApiKey = 'ddcbd636ab518e28afb69da8854a4352';

  @override
  void initState() {
    super.initState();
    fetchWeather(_currentLatLng);
  }

  Future<void> fetchWeather(LatLng coords) async {
    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?lat=${coords.latitude}&lon=${coords.longitude}&appid=$weatherApiKey&units=metric',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final temp = data['main']['temp'];
        final desc = data['weather'][0]['description'];

        if (mounted) {
          setState(() {
            _temperature = '$temp°C';
            _weatherDesc = desc;
          });
        }
      } else {
        setState(() {
          _temperature = 'Weather data unavailable';
        });
      }
    } catch (e) {
      setState(() {
        _temperature = 'Error fetching weather';
      });
    }
  }

  Future<void> _searchPlace() async {
    final place = _placeController.text.trim();
    if (place.isEmpty) return;

    try {
      List<Location> locations = await locationFromAddress(place);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        final latLng = LatLng(loc.latitude, loc.longitude);

        setState(() {
          _currentLatLng = latLng;
          _marker = Marker(
            markerId: const MarkerId('searchPlace'),
            position: latLng,
            infoWindow: InfoWindow(title: place),
          );
        });

        _mapController.animateCamera(CameraUpdate.newLatLngZoom(latLng, 12));

        fetchWeather(latLng);
      } else {
        setState(() {
          _temperature = 'Location not found';
        });
      }
    } catch (e) {
      setState(() {
        _temperature = 'Error: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weather Map Viewer')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _placeController,
                    decoration: const InputDecoration(
                      labelText: 'Enter a place',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _searchPlace,
                  child: const Text('Search'),
                ),
              ],
            ),
          ),
          Expanded(
            child: GoogleMap(
              onMapCreated: (controller) => _mapController = controller,
              initialCameraPosition: CameraPosition(
                target: _currentLatLng,
                zoom: 10,
              ),
              markers: _marker != null ? {_marker!} : {},
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Temperature: $_temperature',
                  style: const TextStyle(fontSize: 18),
                ),
                if (_weatherDesc.isNotEmpty)
                  Text(
                    'Condition: $_weatherDesc',
                    style: const TextStyle(fontSize: 16),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
