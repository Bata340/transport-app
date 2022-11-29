import 'dart:convert';

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
  Map? stationsData;
  var stations;
  var routesPolylines;
  List<Marker> colectivosMarkers = [];

  Future<LatLng?> getCurrentLocation() async {
    if (await Permission.location.request().isGranted) {
      Position currLocation = await Geolocator.getCurrentPosition();
      return LatLng(currLocation.latitude, currLocation.longitude);
    } else {
      //Default: Microcentro
      return LatLng(-34.603722, -58.381592);
    }
  }


  /*void getMarkersColectivos() async {
    List<Marker> markersColectivos = stations;
    print("call");
    if (stationsData != null){
      stationsData!.forEach((key, arrayRamales) async {
        arrayRamales!.forEach((trips_and_stops) async{
          Map route = widget.routes!.where(
                  (route) => route["id"] == trips_and_stops["trip"][1]
          ).toList().elementAt(0);
          String name = route["name"];
          List? colectivosRecvd = await Server.getColectivosRamal(
            name,
            trips_and_stops["trip"][3]
          );
          colectivosRecvd!.forEach((datosColectivos){
            markersColectivos.add(
              Marker(
                point: LatLng(
                  datosColectivos["latitude"], //Lat
                  datosColectivos["longitude"] //Lon
                ),
                builder: (context) =>
                  FloatingActionButton(
                    heroTag: ("marker_${datosColectivos["tip_id"]}"),
                    key: Key("marker_${datosColectivos["tip_id"]}"),
                    backgroundColor:
                    Color(datosColectivos.keys.toList().indexOf(key)),
                    child: Container(
                      child: Image.asset(
                        "assets/colectivo_detail/Colectivo.png",/* +
                        stationsRecvd.keys
                            .toList()
                            .indexOf(key)
                            .toString() +
                        ".png",*/
                        height: 65.0,
                        fit: BoxFit.cover,
                      ),
                    ),
                  onPressed: () => {},
                )
              )
            );
          });
        });
      });
      setState (() {
        colectivosMarkers = markersColectivos;
      });
    }
  }*/

  Future<void>? fetchData() async {
    LatLng? latLong = await getCurrentLocation();
    Map? stationsRecvd = await Server.getColectivosStations(widget.routes);
    var markers = <Marker>[];
    var polylines = <Polyline>[];
    var colors = [
      0xFFE34135,
      0xFFD5AE2C,
      0xFF2D9243,
      0xFFE634CF,
      0xFF7626EF,
      0xFFF19535
    ];
    var aux = 0;
    stationsRecvd?.forEach((key, trips) {
      trips.forEach((trip_and_stops) {
        //print(trip_and_stops);
        var stops_pos = <LatLng>[];
        trip_and_stops["stops"].forEach((stop) {
          markers.add(Marker(
              point: LatLng(
                  stop[3], //Lat
                  stop[4] //Lon
                  ),
              builder: (context) => FloatingActionButton(
                    heroTag: ("marker_${stop[0]}"),
                    key: Key("marker_${stop[0]}"),
                    backgroundColor:
                        Color(stationsRecvd.keys.toList().indexOf(key)),
                    child: Container(
                      child: Tooltip(
                        showDuration: Duration(days: 1),
                        triggerMode: TooltipTriggerMode.tap,
                        message: "Ramal: ${trip_and_stops["trip"][4]}\nSentido: ${trip_and_stops["trip"][3]}\nDirección: ${stop[2]}",
                        child: Image.asset(
                          "assets/colectivo_detail/stop_marker" +
                              stationsRecvd.keys
                                  .toList()
                                  .indexOf(key)
                                  .toString() +
                              ".png",
                          height: 65.0,
                          fit: BoxFit.cover,
                        ),
                      )
                    ),
                    onPressed: () {

                    },
                  )));
          stops_pos.add(
            LatLng(
                stop[3], //Lat
                stop[4] //Lon
                ),
          );
        });
        polylines.add(Polyline(
            strokeWidth: 3, points: stops_pos, color: Color(colors[aux])));
      });
      aux += 1;
    });
    setState(() {
      currentLatLng = latLong;
      stations = markers;
      //colectivosMarkers = markers;
      stationsData = stationsRecvd;
      routesPolylines = polylines;
    });
    //getMarkersColectivos();
  }

  @override
  void initState() {
    fetchData();
    /*Stream.periodic(
        const Duration(seconds: 10),
            (count) async {getMarkersColectivos();}
    );*/
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                  "assets/colectivo_detail/background_colectivos.png"),
              fit: BoxFit.fitHeight,
            ),
          ),
          child: currentLatLng == null
              ? const Center(child: CircularProgressIndicator())
              : FlutterMap(
                  options: MapOptions(
                    center: currentLatLng,
                    zoom: 16,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    ),
                    PolylineLayer(
                      polylineCulling: true,
                      polylines: routesPolylines,
                    ),
                    //MarkerLayer(markers: stations),
                    MarkerLayer(markers: stations)
                  ],
                )
        )
    );
  }
}
