import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tdl_transporte_divs_centrados/Pages/subtes_detail.dart';
import '../ApiCalls/subtes_calls.dart';
import 'package:flutter/material.dart';



class SubteMap extends StatefulWidget {
  const SubteMap({super.key, required this.title});

  final String title;

  @override
  State<SubteMap> createState() => _SubteMapState();
}

class _SubteMapState extends State<SubteMap> {

  LatLng? currentLatLng;
  var stations;



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

  void seeDetailsStation (id, name, route) {
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SubteDetail(
            stationId: id,
            stationName: name,
            route: route,
        ))
    );
  }

  Future<void>? fetchData() async{
    LatLng? latLong = await getCurrentLocation();
    List? stationsRecvd = await Server.getSubtesStations();
    var markers = <Marker>[];
    stationsRecvd?.forEach((station) {
      print(station);
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
                    station["route"]+"Marker.png",
                    height: 20.0,

                    fit: BoxFit.cover,
                  ),
                ),
                onPressed: (){
                  seeDetailsStation(
                      station["station_id"],
                      station["name"],
                      station["route"],
                  );
                },
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