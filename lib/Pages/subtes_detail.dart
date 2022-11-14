import '../ApiCalls/subtes_calls.dart';
import 'package:flutter/material.dart';



class SubteDetail extends StatefulWidget {
  const SubteDetail(
    {
      super.key,
      required this.stationId,
      required this.stationName,
      required this.route,
      //required this.address
    }
  );

  final String? stationId;
  final String? stationName;
  final String? route;
  static const Map directions = {
    'A':['San Pedro', 'Plaza de Mayo'],
    'B':['Juan Manuel de Rosas', 'Leandro N. Alem'],
    'D':['Congreso de Tucuman', 'Catedral'],
    'E':['Plaza de los Virreyes', 'Retiro'],
  };
  //final String? address;

  @override
  State<SubteDetail> createState() => _SubteDetail();
}

class _SubteDetail extends State<SubteDetail> {

  int? minsToArrival0;
  int? minsToArrival1;
  //DateTime? lastUpdated;
  bool loading = true;


  Future<void>? fetchData() async{
    var stationDetail = await Server.getSubteStationDetail( widget.stationId );
    setState((){
      minsToArrival0 = stationDetail![0]~/60;
      minsToArrival1 = stationDetail![1]~/60;
      //lastUpdated = DateTime.fromMillisecondsSinceEpoch(stationDetail["last_reported"]);
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
                  )
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
                      Text(
                        "a "+SubteDetail.directions[widget.route][0],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24.0,
                        )
                      ),
                      Container(
                          width: MediaQuery.of(context).size.width*0.295,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                  "Tiempo",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  )
                              ),
                              Text(((){
                                if(minsToArrival0 == 0){
                                  return "Menos de un minuto";
                                } else if (minsToArrival0 == 1){
                                  return minsToArrival0.toString() + " minuto";
                                }
                                return minsToArrival0.toString() + " minutos";
                              })())
                            ],
                          )
                      )
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
                        Text(
                            "a "+SubteDetail.directions[widget.route][1],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24.0,
                            )
                        ),
                        Container(
                            width: MediaQuery.of(context).size.width*0.295,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                    "Tiempo",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    )
                                ),
                                Text(((){
                                  if(minsToArrival1 == 0){
                                    return "Menos de un minuto";
                                  } else if (minsToArrival1 == 1){
                                    return minsToArrival1.toString() + " minuto";
                                  }
                                  return minsToArrival1.toString() + " minutos";
                                })())
                              ],
                            )
                        )
                      ],
                    ),
                  ]
              ),
            ),
            const SizedBox(height: 30),
          ]
        ),
      ),
    );
  }
}