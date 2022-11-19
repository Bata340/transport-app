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

  static Future<List?> getColectivosStations(ramal) async {
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
        List stations = [];
        List routes = [];
        List names = [];
        Iterable csv = [];
        Iterable aux;
        Iterable stop_id_aux;
        Iterable stop_data_aux;
        final archive = ZipDecoder().decodeBytes(response.bodyBytes);
        print(ramal);

        Iterable trips_csv = [];
        Iterable stop_times_csv = [];
        Iterable stops_csv = [];

        var ramal_nombre = ramal.map((ram) => ram['id']);
        //print(ramal_nombre);
        //ArchiveFile trip_file = archive.where((file) => file.name == "trips.txt");
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
        // for (final file in archive) {
        //   if (file.name == 'trips.txt') {
        //     csv = CsvToListConverter().convert(utf8.decode(file.content))
        //       ..removeAt(0);
        //     csv = csv.where((element) => ramal_nombre.contains(element[1]));
        //     break;
        //   }
        // }
        aux = trips_csv.where((element) => ramal_nombre.contains(element[1]));
        aux = aux.map((ram) => ram[0]); //trips_id
        // print("trips_ids");
        // print(aux);
        // for (final file in archive) {
        //   if (file.name == 'stop_times.txt') {
        //     csv = CsvToListConverter().convert(utf8.decode(file.content))
        //       ..removeAt(0);
        //     csv = csv.where((element) => aux.contains(element[0]));
        //     break;
        //   }
        // }
        stop_id_aux =
            stop_times_csv.where((element) => aux.contains(element[0]));
        stop_id_aux = stop_id_aux.map((ram) => ram[2]); //stop_id
        print("stop_id");
        print(stop_id_aux);
        // for (final file in archive) {
        //   if (file.name == 'stops.txt') {
        //     csv = CsvToListConverter().convert(utf8.decode(file.content))
        //       ..removeAt(0);
        //     csv = csv.where((element) => aux.contains(element[0]));
        //     print(csv);
        //     break;
        //   }
        // }
        stop_data_aux =
            stops_csv.where((element) => stop_id_aux.contains(element[0]));
        print("stop_info");
        print(stop_data_aux);
        routes = stop_data_aux
            .map((e) => {
                  "station_id": e[0],
                  "name": e[2],
                  "lat": e[4],
                  "lon": e[5],
                  "route": 'Nombre Ruta' //TODO iterar por los seleccionados
                })
            .toList();
        print('estaciones');
        print(routes);
        return routes;
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
