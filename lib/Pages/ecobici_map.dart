import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../ApiCalls/ecobici_calls.dart';
import 'package:flutter/material.dart';



class EcobiciMap extends StatefulWidget {
  const EcobiciMap({super.key, required this.title});

  final String title;

  @override
  State<EcobiciMap> createState() => _EcobiciMapState();
}

class _EcobiciMapState extends State<EcobiciMap> {

  LatLng? currentLatLng;
  var stations;
  Future<void>? _fetchData;



  Future<LatLng?> getCurrentLocation() async {
    if (await Permission.location.request().isGranted) {
      Position currLocation = await Geolocator.getCurrentPosition();
      return LatLng(currLocation.latitude, currLocation.longitude);
    } else {
      //Default: Microcentro
      return LatLng(
          -34.603722,
          -58.381592
      );
    }
  }

  void seeDetailsStation (id) {
    print(id.toString());
  }

  Future<void>? fetchData() async{
    LatLng? latLong = await getCurrentLocation();
    List? stationsRecvd = await Server.getEcobiciStations();
    var markers = <Marker>[];
    stationsRecvd?.forEach((station) {
      markers.add(
          Marker(
              point: LatLng(
                  station["lat"],
                  station["lon"]
              ),
              builder: (context) => FloatingActionButton(
                heroTag: ("marker_${station["station_id"]}"),
                key: Key("marker_${station["station_id"]}"),
                backgroundColor: Colors.white12.withOpacity(0.1),
                child: Container(
                  child: Image.asset(
                    "EcoBiciMarker.png",
                    height: 45.0,

                    fit: BoxFit.cover,
                  ),
                ),
                onPressed: (){seeDetailsStation(station["station_id"]);},
              )
          )
      );
    });
    setState((){
      currentLatLng = latLong;
      stations = markers;
    });

  }

  @override
  void initState() {
    _fetchData = fetchData();
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