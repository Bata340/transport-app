import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Transport App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Transport App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  LatLng? currentLatLng;

  Future<void>? setCurrentLocation() async {
    if (await Permission.location.request().isGranted){
      Geolocator.getCurrentPosition().then((currLocation) {
        setState(() {
          currentLatLng = LatLng(currLocation.latitude, currLocation.longitude);
        });
      });
    }else{
      if (await Permission.location.isPermanentlyDenied) {
        openAppSettings();
      }
      setState((){
        currentLatLng = LatLng(
            -34.603722,
            -58.381592
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: setCurrentLocation(),
        builder: (context, AsyncSnapshot snapshot) {
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.title),
            ),
            body: currentLatLng == null ?
            const Center(child: CircularProgressIndicator()) :
            FlutterMap(
              options: MapOptions(
                center: currentLatLng,
                zoom: 16,
              ),
              nonRotatedChildren: [
                AttributionWidget.defaultWidget(
                  source: 'OpenStreetMap contributors',
                  onSourceTapped: null,
                ),
              ],
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                ),
              ],
            ),
          );
        }
    );
  }
}
