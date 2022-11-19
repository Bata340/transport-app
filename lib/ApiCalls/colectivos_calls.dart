import 'dart:io';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:archive/archive_io.dart';
import 'package:csv/csv.dart';

class Server{

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
        final fileRoutes = archive.where((file) => file.name == "routes.txt").toList().elementAt(0);
        Iterable csv = CsvToListConverter().convert(
            utf8.decode(fileRoutes.content))
          ..removeAt(0);
        ramales = csv.map((element) => {"id":element[0], "name":element[2]}).toList();
        return ramales;
      default:
        throw Exception("Error al recuperar los ramales de colectivos.");
    }
  }

  static Future<List?> getColectivosStations(ramal) async{
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
        Map routes = {};
        final archive = ZipDecoder().decodeBytes(response.bodyBytes);
        // Como buscar un file dentro del archive vvv:
        //archive.where((file) => file.name == "routes.txt").toList().elementAt(0);
        return stations;
      default:
        throw Exception("Fallo al recuperar las estaciones de Subte.");
    }
  }


  static Future<dynamic?> getColectivosRamal( route_id, trip_id, agency_id ) async{
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
        throw Exception("Fallo al recuperar los colectivos del ramal $route_id.");
    }
  }

}