import '../ApiCalls/ecobici_calls.dart';
import 'package:flutter/material.dart';



class EcobiciDetail extends StatefulWidget {
  const EcobiciDetail(
    {
      super.key,
      required this.stationId,
      required this.stationName,
      required this.rentalMethods,
      required this.capacity,
      required this.address
    }
  );

  final String? stationId;
  final String? stationName;
  final List? rentalMethods;
  final int? capacity;
  final String? address;

  @override
  State<EcobiciDetail> createState() => _EcobiciDetail();
}

class _EcobiciDetail extends State<EcobiciDetail> {

  int? numBikesAvailable;
  int? numBikesDisabled;
  int? numDocksAvailable;
  int? numDocksDisabled;
  String? status;
  DateTime? lastUpdated;
  bool loading = true;


  Future<void>? fetchData() async{
    var stationDetail = await Server.getEcobiciStationDetail( widget.stationId );
    setState((){
      numBikesAvailable = stationDetail!["num_bikes_available"];
      numBikesDisabled = stationDetail!["num_bikes_disabled"];
      numDocksAvailable = stationDetail!["num_docks_available"];
      numDocksDisabled = stationDetail!["num_docks_disabled"];
      status = stationDetail!["status"];
      lastUpdated = DateTime.fromMillisecondsSinceEpoch(stationDetail["last_reported"]);
      loading = false;
    });

  }

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detalle de estación"),
      ),
      body:
      loading? const Center(child: CircularProgressIndicator()) :
      SingleChildScrollView(
        child:Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:[
                Container(
                  color: Colors.orange,
                  width: MediaQuery.of(context).size.width,
                  height: 125,
                  child: Image.asset(
                    "logoEcobici.png",
                    height:100
                  )
                )
              ]
            ),
            const SizedBox(height:30),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black26),
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.black26,
              ),
              padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.025),
              margin: EdgeInsets.symmetric(horizontal:MediaQuery.of(context).size.width*0.025),
              child: Column(
                children:[
                  const Text(
                      "Datos de la estación",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24.0,
                      )
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Nombre: ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Flexible(
                        child: Text(widget.stationName!)
                      )
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Dirección: ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Flexible(
                        child: Text(widget.address!)
                      )
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Estado: ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold
                        )
                      ),
                      Container(
                        height: 10,
                        width: 10,
                        decoration: BoxDecoration(
                            color: status! == 'IN_SERVICE' ? Colors.green : Colors.red,
                            borderRadius: BorderRadius.circular(10)
                        ),
                      ),
                      Text(status! == 'IN_SERVICE' ? '  En servicio' : '  Fuera de servicio'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                          "Medios de pago: ",
                          style: TextStyle(
                              fontWeight: FontWeight.bold
                          )
                      ),
                    ]
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width*0.5,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Column(
                            children:[
                              ListView(
                                shrinkWrap: true,

                                children: widget.rentalMethods!.map(
                                        (item) => Row(
                                      children:[
                                        const Icon(Icons.account_balance_wallet_outlined),
                                        Text(item == 'KEY' ? 'Llave' : (item == 'TRANSITCARD' ? 'Tarjeta de Tránsito': (item == 'PHONE' ? 'Celular': item)))
                                      ],
                                    )
                                ).toList(),
                              ),
                            ],
                          ),
                        )

                      ),
                    ],
                  ),
                ]
              )
            ),
            const SizedBox(height:30),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.amberAccent),
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.amberAccent,
              ),
              padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.025),
              margin: EdgeInsets.symmetric(horizontal:MediaQuery.of(context).size.width*0.025),
              child: Row(
                children:[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Docks de Bicicletas",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24.0,
                        )
                      ),
                      Image.asset(
                        "ecobiciStand.png",
                        height: 75.0
                      ),
                      const SizedBox(height:20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width*0.295,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  "Capacidad",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  )
                                ),
                                Text(widget.capacity!.toString())
                              ],
                            )
                          ),
                          Container(
                              decoration: const BoxDecoration(
                                border: Border(
                                  right: BorderSide(color: Colors.black),
                                  left: BorderSide(color: Colors.black),
                                ),
                              ),
                              width: MediaQuery.of(context).size.width*0.295,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Disponibles",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    )
                                  ),
                                  Text(numDocksAvailable.toString())
                                ],
                              )
                          ),
                          Container(
                              width: MediaQuery.of(context).size.width*0.295,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Deshabilitados",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    )
                                  ),
                                  Text(numDocksDisabled.toString())
                                ],
                              )
                          ),
                        ],
                      ),
                    ],
                  ),
                ]
              ),
            ),
            const SizedBox(height:30),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.amberAccent),
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.amberAccent,
              ),
              padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.025),
              margin: EdgeInsets.symmetric(horizontal:MediaQuery.of(context).size.width*0.025),
              child: Row(
                  children:[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "Bicicletas en la estación",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24.0,
                          )
                        ),
                        Image.asset(
                            "ecobiciBike.png",
                            height: 75.0
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                                decoration: const BoxDecoration(
                                  border: Border(
                                    right: BorderSide(color: Colors.black),
                                  ),
                                ),
                                width: MediaQuery.of(context).size.width*0.445,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "Disponibles",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold
                                      )
                                    ),
                                    Text(numBikesAvailable.toString())
                                  ],
                                )
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width*0.445,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Deshabilitadas",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold
                                    )
                                  ),
                                  Text(numBikesDisabled.toString())
                                ],
                              )
                            ),
                          ],
                        ),
                      ],
                    ),
                  ]
              )
            ),
            const SizedBox(height: 30),
          ]
        ),
      ),
    );
  }
}