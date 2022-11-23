import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../ApiCalls/colectivos_calls.dart';
import 'package:flutter/material.dart';

class ColectivosMap extends StatefulWidget {
  ColectivosMap({super.key, required this.title, required this.routes});

  final String title;
  final List? routes;

  @override
  State<ColectivosMap> createState() => _ColectivosMapState();
}

class _ColectivosMapState extends State<ColectivosMap> {
  LatLng? currentLatLng;
  var stations;

  Future<LatLng?> getCurrentLocation() async {
    if (await Permission.location.request().isGranted) {
      Position currLocation = await Geolocator.getCurrentPosition();
      return LatLng(currLocation.latitude, currLocation.longitude);
    } else {
      //Default: Microcentro
      return LatLng(-34.603722, -58.381592);
    }
  }

  Future<void>? fetchData() async {
    LatLng? latLong = await getCurrentLocation();
    Map? stationsRecvd = await Server.getColectivosStations(widget.routes);
    var markers = <Marker>[];
    stationsRecvd?.forEach((key, trips) {
      trips.forEach((trip_and_stops) {
        trip_and_stops["stops"].forEach((stop) {
          markers.add(
              Marker(
                  point: LatLng(
                      stop[4], //Lat
                      stop[5] //Lon
                  ),
                  builder: (context) =>
                      FloatingActionButton(
                        heroTag: ("marker_${stop[0]}"),
                        key: Key("marker_${stop[0]}"),
                        backgroundColor: Colors.white12.withOpacity(0.1),
                        child: Container(
                          child: Image.asset(
                            "EcoBiciMarker.png",
                            height: 45.0,
                            fit: BoxFit.cover,
                          ),
                        ),
                        onPressed: () {
                          print("TOUCH ${stop[0]}");
                        },
                      )
              )
          );
        });
      });
    });
    setState((){
      currentLatLng = latLong;
      stations = markers;
    });
    return;
  }

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body:
      currentLatLng == null ? const Center(child: CircularProgressIndicator()) :
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
          MarkerLayer(markers: stations)
        ],
      ),
    );
  }
}
