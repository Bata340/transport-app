import 'dart:io';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:archive/archive_io.dart';
import 'package:csv/csv.dart';
import '../globals.dart' as globals;


class Server {
  static Future<List> getColectivosRamales() async {
    List ramales = [];

    final response = await globals.zipColectivosCall;
    switch (response.statusCode) {
      case HttpStatus.ok:
        final archive = ZipDecoder().decodeBytes(response.bodyBytes);
        final fileRoutes = archive
            .where((file) => file.name == "routes.txt")
            .toList()
            .elementAt(0);
        Iterable csv = CsvToListConverter()
            .convert(utf8.decode(fileRoutes.content))
          ..removeAt(0);
        ramales = csv
            .map((element) => {"id": element[0], "name": element[2], "agency_id": element[1]})
            .toList();
        return ramales;
      default:
        throw Exception("Error al recuperar los ramales de colectivos.");
    }
  }

  static Future<Map?> getColectivosStations(ramal) async {
    final response = await globals.zipColectivosCall;
    switch (response.statusCode) {
      case HttpStatus.ok:
        final archive = ZipDecoder().decodeBytes(response.bodyBytes);

        Iterable trips_csv = [];
        Iterable stop_times_csv = [];
        Iterable stops_csv = [];

        var route_ids = ramal.map((ram) => ram['id']).toList();

        for (final file in archive) {
          if (file.name == 'trips.txt') {
            trips_csv = CsvToListConverter().convert(utf8.decode(file.content))
              ..removeAt(0);
          }
          if (file.name == 'stop_times.txt') {
            stop_times_csv = CsvToListConverter()
                .convert(utf8.decode(file.content))
              ..removeAt(0);
          }
          if (file.name == 'stops.txt') {
            stops_csv = CsvToListConverter().convert(utf8.decode(file.content))
              ..removeAt(0);
          }
        }
        List trips_list =
          trips_csv.where((trip) => route_ids.contains(trip[1])).toList();
        var return_msg = {};
        for (var trip in trips_list) {
          Map stops_times_map = {};
          stop_times_csv
              .where((st) => st[0] == trip[0])
              .forEach((st) => {stops_times_map[st[2]] = st[1]});

          var stops = stops_csv
              .where((st) => stops_times_map.containsKey(st[0]))
              .map((e) => [e[0], stops_times_map[e[0]], e[2], e[4], e[5]])
              .toList();

          stops.sort((a, b) => a[1].compareTo(b[1]));
          if (return_msg.containsKey(trip[4].toString() + trip[5].toString())) {
            //return_msg[{trip[4], trip[5]}].add({"trip": trip, "stops": stops});
          } else {
            return_msg[trip[4].toString() + trip[5].toString()] = [
              {"trip": trip, "stops": stops}
            ];
          }
        }
        return return_msg;
      default:
        throw Exception("Fallo al recuperar las estaciones de Colectivo.");
    }
  }

  static Future<List?> getColectivosRamal(
      /*route_id, trip_id, agency_id*/
      route_short_name, trip_name) async {
    await dotenv.load();
    var clientId = dotenv.env["api_client_id"];
    var clientSecret = dotenv.env["api_client_secret"];
    var urlApi = dotenv.env["api_url"];

    final Map<String, String> qParams = {
      'client_id': clientId!,
      'client_secret': clientSecret!,
    };

    final response = await http.get(
      Uri.https(urlApi!, "/colectivos/vehiclePositionsSimple", qParams),
    );
    switch (response.statusCode) {
      case HttpStatus.ok:
        var jsonData = json.decode(response.body);
        var returnData =  (jsonData.where(
                (ColectivoData) => ColectivoData["route_short_name"] == route_short_name && ColectivoData["trip_headsign"] == trip_name
        ).toList());
        return returnData;
      default:
        throw Exception(
            "Fallo al recuperar los colectivos del ramal.");// $route_id.");
    }
  }
}
