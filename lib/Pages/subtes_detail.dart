import 'dart:ffi';

import '../ApiCalls/subtes_calls.dart';
import 'package:flutter/material.dart';



class SubteDetail extends StatefulWidget {
  const SubteDetail(
    {
      super.key,
      required this.stationId,
      required this.stationName,
      required this.route,
      required this.programmed_arrivals
      //required this.address
    }
  );

  final String? stationId;
  final String? stationName;
  final String? route;
  final List? programmed_arrivals;
  static const Map directions = {
    'A':['San Pedrito', 'Plaza de Mayo'],
    'B':['Juan Manuel de Rosas', 'Leandro N. Alem'],
    'C':['Constitucion', 'Retiro'],
    'D':['Congreso de Tucuman', 'Catedral'],
    'E':['Plaza de los Virreyes', 'Retiro'],
    'H':['Hospitales', 'Facultad de Derecho'],
    'P1':['Centro Civico','Intendente Saguier'],
    'P2':['General Savio','Intendente Saguier'],
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
    //var stationDetail = [0,0];
    print(widget);
    setState((){
      minsToArrival0 = (stationDetail![0]??getProgrammedArrivalTime(0))~/60;
      minsToArrival1 = (stationDetail![1]??getProgrammedArrivalTime(1))~/60;
      //lastUpdated = DateTime.fromMillisecondsSinceEpoch(stationDetail["last_reported"]);
      loading = false;
    });

  }

  num getProgrammedArrivalTime(direction){
    DateTime today = DateTime.now();
    int secsToday = today.hour*3600+today.minute*60+today.second;
    for(int arrival in widget.programmed_arrivals?[direction]){
      if(arrival > secsToday){
        print(arrival-secsToday);
        return arrival-secsToday;
      }
    }
    return 86400-secsToday+widget.programmed_arrivals?[direction][0];
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
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/background_subtes.png"),
            fit: BoxFit.fitHeight,
          ),
        ),
        child: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
          child:Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:[
                  Container(
                    color: Color(0xFFF6CD19),
                    width: MediaQuery.of(context).size.width,
                    height: 125,
                    child: Image.asset(
                      "logoSubte.png"
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
              Visibility(
                visible: SubteDetail.directions[widget.route][0] != widget.stationName,
                child: Container(
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
                            "Hacia "+ SubteDetail.directions[widget.route][0],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24.0,
                            )
                          ),
                          const SizedBox(height:10),
                          Container(
                              width: MediaQuery.of(context).size.width*0.885,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                      ((){
                                        if(minsToArrival0 == 0){
                                          return "Llega en menos de un minuto";
                                        } else if (minsToArrival0 == 1){
                                          return "Llega en " + minsToArrival0.toString() + " minuto";
                                        }
                                        return "Llega en " + minsToArrival0.toString() + " minutos";
                                      })(),
                                      style: TextStyle(
                                        fontSize: 16.0,
                                      )
                                  ),
                                ],
                              )
                          )
                        ],
                      ),
                    ]
                  ),
                )
              ),
              const SizedBox(height:30),
              Visibility(
              visible: SubteDetail.directions[widget.route][1] != widget.stationName,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.amberAccent),
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.amberAccent
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
                              "Hacia "+SubteDetail.directions[widget.route][1],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24.0,
                              )
                          ),
                          const SizedBox(height:10),
                          Container(
                              width: MediaQuery.of(context).size.width*0.885,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                      ((){
                                        if(minsToArrival1 == 0){
                                          return "Llega en menos de un minuto";
                                        } else if (minsToArrival1 == 1){
                                          return "Llega en " + minsToArrival1.toString() + " minuto";
                                        }
                                        return "Llega en " + minsToArrival1.toString() + " minutos";
                                      })(),
                                      style: TextStyle(
                                        fontSize: 16.0,
                                      )
                                  ),
                                ],
                              )
                          )
                        ],
                      ),
                    ]
                  ),
                )
              ),
              const SizedBox(height: 900),
            ]
          ),
        ),
     )
    );
  }
}