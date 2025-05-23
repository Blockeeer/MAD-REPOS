import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(GoogleApp());
}

class GoogleApp extends StatelessWidget {
  const GoogleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: GoogleMapScreen());
  }
}

class GoogleMapScreen extends StatefulWidget {
  const GoogleMapScreen({super.key});

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  late GoogleMapController mapController;
  int id = 1;
  Set<Marker> markers = {
    Marker(
      markerId: MarkerId('${1}'),
      position: LatLng(15.955998, 120.589919),
      infoWindow: InfoWindow(title: 'Urdaneta'),
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GoogleMap(
          markers: markers,
          mapType: MapType.normal,
          mapToolbarEnabled: true,
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
          zoomControlsEnabled: true,
          zoomGesturesEnabled: true,
          onMapCreated: (controller) {
            mapController = controller;
          },
          initialCameraPosition: CameraPosition(
            target: LatLng(15.994390832541512, 120.57699239405258),
            zoom: 10,
            // tilt: 60,
          ),
          onTap: (positions) {
            // markers.clear();
            print(positions.latitude);
            print(positions.longitude);
            goToLocation(positions);
            markers.add(
              Marker(
                markerId: MarkerId('${positions}'),
                position: LatLng(positions.latitude, positions.longitude),
              ),
            );
            setState(() {});
          },
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

  void goToCurrectLocation() async {
    if (!await checkLocationServicePermission()) {
      return;
    }

    Geolocator.getPositionStream().listen((geoPosition) {
      goToLocation(LatLng(geoPosition.latitude, geoPosition.longitude));
    });
  }

  void goToLocation(LatLng position) {
    markers.clear();
    markers.add(Marker(markerId: MarkerId('${position}'), position: position));
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: 10),
      ),
    );
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // goToLocation(position);
    goToCurrectLocation();
  }
}
