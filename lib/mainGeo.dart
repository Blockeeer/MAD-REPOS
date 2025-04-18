import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geocode;
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(GeoApp());
}

class GeoApp extends StatelessWidget {
  const GeoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: GeoScreen());
  }
}

class GeoScreen extends StatefulWidget {
  const GeoScreen({super.key});

  @override
  State<GeoScreen> createState() => _GeoScreenState();
}

class _GeoScreenState extends State<GeoScreen> {
  Position? position;
  geocode.Location? location;
  var locationCtrl = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text('Geolocation')),
        body: Column(
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 4,
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
              ),
              onPressed: getCurrentLocation,
              child: Text('Get location'),
            ),
            Text('Lat : ${position?.latitude}'),
            Text('Long : ${position?.longitude}'),
            Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: locationCtrl,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: geoCode,
              child: Text('Get location from address'),
            ),
            Text('Location: ${location?.latitude} ${location?.longitude}'),
          ],
        ),
      ),
    );
  }

  Future<bool> checkLocationServicePermission() async {
    bool isEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Location service is turn off, please enable it in the settings for the app',
          ),
        ),
      );
      return false;
    }
    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Permission to use devices location is denied. please enable it in settings',
            ),
          ),
        );
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Permission to use devices location is denied. please enable it in settings',
          ),
        ),
      );
      return false;
    }
    return true;
  }

  void getCurrentLocation() async {
    if (!await checkLocationServicePermission()) {
      return;
    }
    position = await Geolocator.getCurrentPosition();
    setState(() {});
    print('asas ${position?.latitude} ${position?.longitude}');
  }

  void geoCode() async {
    var locations = await geocode.locationFromAddress(locationCtrl.text);
    location = locations.first;
    setState(() {});
    print('${location?.latitude}, ${location?.longitude}');
  }
}
