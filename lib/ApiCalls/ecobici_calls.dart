import 'dart:io';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Server{

  static Future<List?> getEcobiciStations() async{
    await dotenv.load();
    var clientId = dotenv.env["api_client_id"];
    var clientSecret = dotenv.env["api_client_secret"];
    var urlApi = dotenv.env["api_url"];

    final Map<String, String> qParams = {
      'client_id': clientId!,
      'client_secret': clientSecret!,
    };

    final response = await http.get(
      Uri.https(urlApi!, "/ecobici/gbfs/stationInformation", qParams),
    );
    switch (response.statusCode) {
      case HttpStatus.ok:
        var stations = jsonDecode(response.body)['data']['stations'];
        List list = json.decode(response.body)['data']['stations'].toList();
        return list;
      default:
        throw Exception("Fallo al recuperar las estaciones de Ecobici.");
    }
  }

}