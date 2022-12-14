import 'package:flutter/material.dart';
import './ecobici_map.dart';
import './subtes_map.dart';
import './colectivos_ramales.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Movete!"),
        backgroundColor: Colors.black12,
      ),
      body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/background_homepage.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Column(
                mainAxisSize: MainAxisSize.max,
                //mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  const Text("¬°Bienvenido a Movete!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 32.0,
                        backgroundColor: Color.fromARGB(66, 255, 255, 255),
                      )),
                  const SizedBox(height: 100),
                  const Text("Me voy a mover con...",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25.0,
                        backgroundColor: Color.fromARGB(66, 255, 255, 255),
                      )),
                  const SizedBox(height: 50),
                  ElevatedButton(
                    key: const Key("button_ecobici"),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const EcobiciMap(
                                  title: "Estaciones de Ecobici")));
                    },
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Color(0xFFF39119)),
                        elevation: MaterialStateProperty.resolveWith<double?>(
                            (states) => 1.5),
                        maximumSize: MaterialStateProperty.resolveWith<Size?>(
                            (states) => Size(
                                MediaQuery.of(context).size.width * 0.7,
                                MediaQuery.of(context).size.height * 0.1)),
                        minimumSize: MaterialStateProperty.resolveWith<Size?>(
                            (states) => Size(
                                MediaQuery.of(context).size.width * 0.6,
                                MediaQuery.of(context).size.height * 0.1)),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ))),
                    child: Row(
                      children: [
                        Image.asset(
                          "EcoBiciMarker.png",
                          height: 45.0,
                          fit: BoxFit.cover,
                        ),
                        const Spacer(),
                        const Text('EcoBici',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 32.0,
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    key: const Key("button_colectivo"),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ColectivosRamales(
                                  title: "Ramales de Colectivo")));
                    },
                    style: ButtonStyle(
                        elevation: MaterialStateProperty.resolveWith<double?>(
                            (states) => 1.5),
                        maximumSize: MaterialStateProperty.resolveWith<Size?>(
                            (states) => Size(
                                MediaQuery.of(context).size.width * 0.7,
                                MediaQuery.of(context).size.height * 0.1)),
                        minimumSize: MaterialStateProperty.resolveWith<Size?>(
                            (states) => Size(
                                MediaQuery.of(context).size.width * 0.6,
                                MediaQuery.of(context).size.height * 0.1)),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ))),
                    child: Row(
                      children: [
                        Image.asset(
                          "Colectivo.png",
                          height: 45.0,
                          fit: BoxFit.cover,
                        ),
                        const Spacer(),
                        const Text('Colectivo',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 32.0,
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    key: const Key("button_subte"),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SubteMap(
                                  title: "Estaciones de Subte")));
                    },
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            Color.fromARGB(255, 245, 183, 25)),
                        elevation: MaterialStateProperty.resolveWith<double?>(
                            (states) => 1.5),
                        maximumSize: MaterialStateProperty.resolveWith<Size?>((states) => Size(
                            MediaQuery.of(context).size.width * 0.7,
                            MediaQuery.of(context).size.height * 0.1)),
                        minimumSize: MaterialStateProperty.resolveWith<Size?>(
                            (states) => Size(
                                MediaQuery.of(context).size.width * 0.6,
                                MediaQuery.of(context).size.height * 0.1)),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ))),
                    child: Row(
                      children: [
                        Image.asset(
                          "Subte.png",
                          height: 45.0,
                          fit: BoxFit.cover,
                        ),
                        const Spacer(),
                        const Text('Subte',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 32.0,
                            )),
                      ],
                    ),
                  ),
                ]),
          )),
    );
  }
}
