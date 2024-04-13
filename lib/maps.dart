import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'main.dart';
import 'networking.dart';

class MyMap extends StatefulWidget {
  final String device;
  const MyMap({super.key, required this.device});

  @override
  _MyMapState createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  MapController mapController = MapController();
  late LatLng currentLocation;
  late Marker currentLocationMarker;
  late Marker lockLocationMarker;
  final List<LatLng> polyPoints = [];
  final Set<Polyline> polyLines = {};
  var data;

  @override
  void initState() {
    super.initState();
    currentLocationMarker = const Marker(
      width: 30.0,
      height: 30.0,
      point: LatLng(0, 0),
      child: Icon(
        Icons.my_location_sharp,
        color: Colors.blue,
      ),
    );
    lockLocationMarker = const Marker(
      point: LatLng(0,0),
      child: Icon(
        Icons.location_pin,
        color: Colors.red,
      ),
    );
    _checkLocationPermission();
    getJsonData();
    _getCurrentLocation();
    _getLockerLocation();
  }

  Future<void> _checkLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          // Handle case where user denies location permissions
        } else if (permission == LocationPermission.deniedForever) {
          // Handle case where user denies location permissions permanently
        }
      }

      await _getCurrentLocation();
      await _getLockerLocation();
    } catch (e) {
      if (kDebugMode) {
        print("Error checking or requesting location permissions: $e");
      }
    }
  }

  Future<void> _getLockerLocation() async {
    final response = await supabase
        .from('DeviceStatus')
        .select('lat,lng')
        .eq('device', widget.device);

    final List<Map<String, dynamic>> value = (response).cast<Map<String, dynamic>>();

    final Map<String, dynamic> lockerPoint = value.first;
    final double endLat = lockerPoint['lat'] as double;
    final double endLng = lockerPoint['lng'] as double;

    setState(() {
      lockLocationMarker = Marker(
        point: LatLng(endLat, endLng),
        child: const Icon(
          Icons.location_pin,
          color: Colors.red,
        ),
      );
    });

    mapController.move(LatLng(endLat, endLng), 18.0);
  }

  Future<void> _getCurrentLocation() async {
    try {
      geolocator.Position position =
      await geolocator.Geolocator.getCurrentPosition(
        desiredAccuracy: geolocator.LocationAccuracy.high,
      );

      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
        currentLocationMarker = Marker(
          width: 30.0,
          height: 30.0,
          point: currentLocation,
          child: const Icon(
            Icons.my_location_sharp,
            color: Colors.blue,
          ),
        );
      });
      mapController.move(currentLocation, 18.0);
    } catch (e) {
      if (kDebugMode) {
        print("Error getting current location: $e");
      }
    }
  }

  void setPolyLines(List<LatLng> decodedPolyline) {
    setState(() {
      Polyline polyline = Polyline(
        strokeWidth: 9,
        color: Colors.lightBlue,
        points: decodedPolyline,
      );
      polyLines.add(polyline);
    });
  }

  void getJsonData() async {
    final response = await supabase
        .from('DeviceStatus')
        .select('lat,lng')
        .eq('device', widget.device);

    final List<Map<String, dynamic>> value = (response).cast<Map<String, dynamic>>();

    final Map<String, dynamic> lockerPoint = value.first;
    final double endLat = lockerPoint['lat'] as double;
    final double endLng = lockerPoint['lng'] as double;
    GraphHopperHelper network = GraphHopperHelper(
      startLat: currentLocation.latitude,
      startLng: currentLocation.longitude,
      endLat: endLat,
      endLng: endLng,
      apiKey: 'ae1c8de4-fc43-4b14-bc67-8c5db776030b',
    );

    try {
      data = await network.getDirections(
          startLat: currentLocation.latitude, startLng:currentLocation.longitude,
          endLat: endLat, endLng: endLng);

      List<dynamic> paths = data['paths'];
      print(paths);

      if (paths.isNotEmpty) {
        Map<String, dynamic> firstPath = paths.first;
        String encodedPolyline = firstPath['points'];
        List<LatLng> decodedPolyline = decodePolyline(encodedPolyline);
        setPolyLines(decodedPolyline);
        setState(() {});
      } else {
        if (kDebugMode) {
          print('No paths found in the API response');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  List<LatLng> decodePolyline(String encodedPolyline) {
    List<LatLng> polyPoints = PolylinePoints().decodePolyline(encodedPolyline)
        .map((PointLatLng point) => LatLng(point.latitude, point.longitude))
        .toList();
    return polyPoints;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(11.986739, 75.380985),
              initialZoom: 18.0,
            ),
            mapController: mapController,
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
              ),
              MarkerLayer(markers: [currentLocationMarker, lockLocationMarker]),
              PolylineLayer(polylines: polyLines.toList()),
            ],
          ),
          Positioned(
            bottom: 30,
            right: 16.0,
            child: FloatingActionButton(
              onPressed: () {
                _getCurrentLocation();
              },
              child: const Icon(Icons.gps_fixed),
            ),
          ),
        ],
      ),
    );
  }
}

class LineString {
  LineString(this.lineString);
  List<dynamic> lineString;
}