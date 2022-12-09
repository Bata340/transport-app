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

        Iterable frequencies_csv = [];
        Iterable stop_times_csv = [];
        Iterable stops_csv = [];

        final archive = ZipDecoder().decodeBytes(response.bodyBytes);
        for (final file in archive) {
          if (file.name == 'stops.txt') {
            Iterable csv = CsvToListConverter().convert(
                utf8.decode(file.content))
              ..removeAt(0);
            stops_csv = csv.where((element) =>
            element[0] is int &&
                element[0] < 10000); // Los menores a 10000 son subestaciones
          } else if (file.name == 'stop_times.txt') {
            stop_times_csv =
            CsvToListConverter().convert(utf8.decode(file.content))
              ..removeAt(0);
          } else if (file.name == 'frequencies.txt') {
            frequencies_csv = CsvToListConverter().convert(
                utf8.decode(file.content))
              ..removeAt(0);
          }
        }

        Map routes = {};
        Map arrival_delay0 = {};
        Map arrival_delay1 = {};
        stop_times_csv
          .forEach((elem){
            routes[elem[3].substring(0, elem[3].length - 1)] = (elem[0][0] == 'P')? elem[0].substring(0,2):elem[0][0];
                String direction = (elem[0][0] == 'P')? elem[0][3]:elem[0][1];
            int minutes = int.parse(elem[1].substring(3, 5));
            int seconds = int.parse(elem[1].substring(6, 8));
            if (direction == '1'){
              arrival_delay1[elem[3].substring(0, elem[3].length - 1)] = minutes*60+seconds;
            } else {
              arrival_delay0[elem[3].substring(0, elem[3].length - 1)] = minutes*60+seconds;
            }
          });

        Map start_times = {'A':[[],[]], 'B':[[],[]], 'C':[[],[]], 'D':[[],[]], 'E':[[],[]], 'H':[[],[]], 'P1':[[],[]], 'P2':[[],[]]};

        frequencies_csv
          .where((frec) => ((frec[0][0] == 'P')? frec[0][4]:frec[0][2]) == '1')
          .forEach((elem){
            String route = (elem[0][0]== 'P')? elem[0].substring(0,2):elem[0][0];
            String direction = (elem[0][0] == 'P')? elem[0][3]:elem[0][1];
            int start = int.parse(elem[1].substring(0, 2))*3600 + int.parse(elem[1].substring(3, 5))*60 + int.parse(elem[1].substring(6, 8));
            int end = int.parse(elem[2].substring(0, 2))*3600 + int.parse(elem[2].substring(3, 5))*60 + int.parse(elem[2].substring(6, 8));
            int headway_secs = elem[3];

            for(int i = start; i < end; i += headway_secs){
              start_times[route][int.parse(direction)].add(i);
            }
          });

        for(var v in start_times.values) {
          v[0].sort();
          v[1].sort();
        }

        stations = stops_csv.map((e) => {
          "station_id":e[0].toString(),
          "name":e[2],
          "lat":e[4],
          "lon":e[5],
          "route":routes[e[0].toString()],
          "programmed_arrivals":[
            start_times[routes[e[0].toString()]][0].map((time) => time + (arrival_delay0[e[0].toString()]??0)).toList(),
            start_times[routes[e[0].toString()]][1].map((time) => time + (arrival_delay1[e[0].toString()]??0)).toList()
          ]
        }).toList();

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
        List times = [null,null];
        for(final recorrido in json.decode(response.body)["Entity"]){
          int direccion = int.parse(recorrido["Linea"]["Trip_Id"][1]);
          for(final estacion in recorrido["Linea"]["Estaciones"]){
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