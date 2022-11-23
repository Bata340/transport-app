import 'dart:io';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:archive/archive_io.dart';
import 'package:csv/csv.dart';

class Server {
  static Future<List> getColectivosRamales() async {
    await dotenv.load();
    var clientId = dotenv.env["api_client_id"];
    var clientSecret = dotenv.env["api_client_secret"];
    var urlApi = dotenv.env["api_url"];

    final Map<String, String> qParams = {
      'client_id': clientId!,
      'client_secret': clientSecret!,
    };
    List ramales = [];

    final response = await http.get(
      Uri.https(urlApi!, "/colectivos/feed-gtfs", qParams),
    );
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
            .map((element) => {"id": element[0], "name": element[2]})
            .toList();
        return ramales;
      default:
        throw Exception("Error al recuperar los ramales de colectivos.");
    }
  }

  static Future<Map?> getColectivosStations(ramal) async {
    await dotenv.load();
    var clientId = dotenv.env["api_client_id"];
    var clientSecret = dotenv.env["api_client_secret"];
    var urlApi = dotenv.env["api_url"];

    final Map<String, String> qParams = {
      'client_id': clientId!,
      'client_secret': clientSecret!,
    };

    final response = await http.get(
      Uri.https(urlApi!, "/colectivos/feed-gtfs", qParams),
    );
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
        List trips_list = trips_csv.where((trip) => route_ids.contains(trip[1])).toList();
        var return_msg = {};
        for(var trip in trips_list){
          var stops_times_list = stop_times_csv.where((st) => st[0] == trip[0]).map((st)=>st[2]).toList();
          var stops = stops_csv.where((st) => stops_times_list.contains(st[0])).toList();
          if(return_msg.containsKey(trip[1])){
            return_msg[trip[1]].add({
              "trip": trip,
              "stops": stops
            });
          }else {
            return_msg[trip[1]] = [{
              "trip": trip,
              "stops": stops
            }];
          }
        }
        return return_msg;
      default:
        throw Exception("Fallo al recuperar las estaciones de Colectivo.");
    }
  }

  static Future<dynamic?> getColectivosRamal(
      route_id, trip_id, agency_id) async {
    await dotenv.load();
    var clientId = dotenv.env["api_client_id"];
    var clientSecret = dotenv.env["api_client_secret"];
    var urlApi = dotenv.env["api_url"];

    final Map<String, String> qParams = {
      'client_id': clientId!,
      'client_secret': clientSecret!,
      "route_id": route_id,
      "trip_id": trip_id,
      "agency_id": agency_id
    };

    final response = await http.get(
      Uri.https(urlApi!, "/colectivos/vehiclePositionsSimple", qParams),
    );
    switch (response.statusCode) {
      case HttpStatus.ok:

      default:
        throw Exception(
            "Fallo al recuperar los colectivos del ramal $route_id.");
    }
  }
}
