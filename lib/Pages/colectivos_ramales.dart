import 'dart:convert';

import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';
import '../ApiCalls/colectivos_calls.dart';
import 'package:flutter/material.dart';
import "./colectivos_map.dart";

class ColectivosRamales extends StatefulWidget {
  const ColectivosRamales(
    {
      super.key,
      required this.title
    }
  );

  final String? title;

  @override
  State<ColectivosRamales> createState() => _ColectivosRamalesState();
}

class _ColectivosRamalesState extends State<ColectivosRamales> {

  List ramales = [];
  List _ramalesSeleccionados = [];
  bool loading = true;


  Future<void>? fetchData() async{
    List ramalesRecvd = await Server.getColectivosRamales();
    setState((){
      ramales = ramalesRecvd;
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
        title: Text(widget.title!),
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
                        color: Colors.grey,
                        width: MediaQuery.of(context).size.width,
                        height: 125,
                        child: Image.asset(
                            "colectivoHorizontal.png",
                            height:100
                        )
                    )
                  ]
              ),
              const SizedBox(height:50),
              Container(
                margin: EdgeInsets.symmetric(horizontal:MediaQuery.of(context).size.width*0.025),
                child: Column(
                  children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: const [
                      Text(
                        "Seleccione los ramales a visualizar:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18
                        ),
                      ),
                    ]
                  ),
                  MultiSelectDialogField(
                    items: ramales.map((ramal) => MultiSelectItem(
                        ramal,
                        ramal["name"].toString())
                    ).toList(),
                    listType: MultiSelectListType.CHIP,
                    searchable: true,
                    onConfirm: (values) {
                      _ramalesSeleccionados = values;
                    },
                    chipDisplay: MultiSelectChipDisplay(
                      items: _ramalesSeleccionados.map((e) => MultiSelectItem(
                          e,
                          e["name"].toString())
                      ).toList(),
                      onTap: (value) {
                        setState(() {
                          _ramalesSeleccionados.remove(value);
                        });
                      },
                    )
                  ),
                  const SizedBox(height:50),
                  ElevatedButton(
                    key: const Key("button_buscar_ramales"),
                    child: const Text(
                      "Buscar Ramales",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    onPressed: () {
                      final ramalesSelected = _ramalesSeleccionados;
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ColectivosMap(
                            title: "Ramales de Colectivo",
                            routes: ramalesSelected
                        ))
                      );
                    }
                  ),
                ]
                ),
              ),
            ]
        ),
      ),
    );
  }
}