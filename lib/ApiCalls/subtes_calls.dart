import 'dart:io';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:archive/archive_io.dart';
import 'package:csv/csv.dart';

class Server{

  static Future<List?> getSubtesStations() async{
    await dotenv.load();
    var clientId = dotenv.env["api_client_id"];
    var clientSecret = dotenv.env["api_client_secret"];
    var urlApi = dotenv.env["api_url"];

    final Map<String, String> qParams = {
      'client_id': clientId!,
      'client_secret': clientSecret!,
    };

    final response = await http.get(
      Uri.https(urlApi!, "/subtes/feed-gtfs", qParams),
    );
    switch (response.statusCode) {
      case HttpStatus.ok:
        List stations = [];
        Map routes = {};
        final archive = ZipDecoder().decodeBytes(response.bodyBytes);
        for (final file in archive) {
          if(file.name == 'stops.txt'){
            Iterable csv = CsvToListConverter().convert(utf8.decode(file.content))..removeAt(0);
            csv = csv.where((element) => element[0] is int && element[0] < 10000); // Los menores a 10000 son subestaciones
            stations = csv.map((e) => {"station_id":e[0].toString(), "name":e[2], "lat":e[4], "lon":e[5], "route":routes[e[0].toString()]}).toList();
          } else if (file.name == 'stop_times.txt'){
            Iterable csv = CsvToListConverter().convert(utf8.decode(file.content))..removeAt(0);
            for(final elem in csv){
              routes[elem[3].substring(0, elem[3].length - 1)] = elem[0][0];//(elem[0][0] == 'P')? elem[0].substring(0,2):elem[0][0];
            }
            print(routes);
          }
        }
        return stations;
      default:
        throw Exception("Fallo al recuperar las estaciones de Subte.");
    }
  }


  static Future<dynamic?> getSubteStationDetail( stationId ) async{
    await dotenv.load();
    var clientId = dotenv.env["api_client_id"];
    var clientSecret = dotenv.env["api_client_secret"];
    var urlApi = dotenv.env["api_url"];

    final Map<String, String> qParams = {
      'client_id': clientId!,
      'client_secret': clientSecret!,
    };

    final response = await http.get(
      Uri.https(urlApi!, "/subtes/forecastGTFS", qParams),
    );
    switch (response.statusCode) {
      case HttpStatus.ok:
        List times = [0,0];
         print(stationId);
        for(final recorrido in json.decode(response.body)["Entity"]){
          int direccion = int.parse(recorrido["Linea"]["Trip_Id"][1]);
          for(final estacion in recorrido["Linea"]["Estaciones"]){
            print(estacion);
            if(estacion["stop_id"].substring(0, estacion["stop_id"].length - 1) == stationId){
              times[direccion] = estacion["arrival"]["delay"];
            }
          }
        }
        return times;
      default:
        throw Exception("Fallo al recuperar las estaciones de Subtes.");
    }
  }

}