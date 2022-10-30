import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import './ecobici_calls.dart';

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
      home: const MyHomePage(title: 'Transport App'),
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
  Future<void>? _fetchData;

  Future<LatLng?> getCurrentLocation() async {
    try {
      if (await Permission.location
          .request()
          .isGranted) {
        Geolocator.getCurrentPosition().then((currLocation) {
          return LatLng(currLocation.latitude, currLocation.longitude);
        });
      } else {
        return LatLng(
            -34.603722,
            -58.381592
        );
      }
    }on Exception catch (exc) {
      throw Exception("Error on location service. $exc");
    }
  }

  Future<void>? fetchData() async{
    LatLng? latLong = await getCurrentLocation();
    List? stationsRecvd = await Server.getEcobiciStations();
    print(stationsRecvd?.elementAt(0).toString());
    setState(() {
      currentLatLng = latLong;
    });
  }

  @override
  void initState() {
    _fetchData = fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _fetchData,
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
