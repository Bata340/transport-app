import 'package:flutter/material.dart';
import './Pages/homepage.dart';

import 'globals.dart' as globals;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:archive/archive_io.dart';

void main() {
  runApp(const MyApp());
}


void defineGlobalZip() async{
  await dotenv.load();
  var clientId = dotenv.env["api_client_id"];
  var clientSecret = dotenv.env["api_client_secret"];
  var urlApi = dotenv.env["api_url"];

  final Map<String, String> qParams = {
    'client_id': clientId!,
    'client_secret': clientSecret!,
  };

  globals.zipColectivosCall = http.get(
    Uri.https(urlApi!, "/colectivos/feed-gtfs", qParams),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    defineGlobalZip();

    return MaterialApp(
      title: 'Movete!',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}
