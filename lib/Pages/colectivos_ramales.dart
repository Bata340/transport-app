import 'dart:collection';
import 'dart:convert';

import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';
import '../ApiCalls/colectivos_calls.dart';
import 'package:flutter/material.dart';
import "./colectivos_map.dart";

class ColectivosRamales extends StatefulWidget {
  const ColectivosRamales({super.key, required this.title});

  final String? title;

  @override
  State<ColectivosRamales> createState() => _ColectivosRamalesState();
}

class _ColectivosRamalesState extends State<ColectivosRamales> {
  List ramales = [];
  List _ramalesSeleccionados = [];
  List<MultiSelectItem>? ramalesItems;
  bool loading = true;
  final Key _multiSelectKey = const Key("multiSelectKey");

  Future<void>? fetchData() async {
    List ramalesRecvd = await Server.getColectivosRamales();
    setState(() {
      ramales = ramalesRecvd;
      loading = false;
      ramalesItems = ramales
          .map((ramal) => MultiSelectItem(
          ramal, ramal["name"].toString()))
          .toList();
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
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                  "assets/colectivo_detail/background_colectivos.png"),
              fit: BoxFit.fitHeight,
            ),
          ),
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : Container(
                  child: Column(mainAxisSize: MainAxisSize.max, children: [
                    const SizedBox(height: 50),
                    Container(
                      margin: EdgeInsets.symmetric(
                          horizontal:
                              MediaQuery.of(context).size.width * 0.025),
                      child: Column(children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: const [
                              Text(
                                "Seleccione los ramales a visualizar:",
                                style: TextStyle(
                                    backgroundColor:
                                        Color.fromARGB(201, 172, 202, 212),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              ),
                            ]),
                        MultiSelectDialogField(
                          items: ramalesItems!,
                          initialValue: _ramalesSeleccionados,
                          listType: MultiSelectListType.LIST,
                          searchable: true,
                          onConfirm: (values) {
                            _ramalesSeleccionados = values;
                          },
                          onSelectionChanged: (values) {
                            if (values.length > 3){
                              AlertDialog alert = AlertDialog(
                                title: const Text("Error"),
                                content: const Text("You can not select more than 3 items."),
                                actions: [
                                  ElevatedButton(
                                      child: const Text("OK"),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      }
                                  ),
                                ],
                              );
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return alert;
                                },
                              );
                              ramalesItems!.elementAt(
                                  ramalesItems!.indexOf(
                                      ramalesItems!.where(
                                              (ramal) =>
                                          ramal.value["id"] == values[3]["id"]).elementAt(0)
                                  )
                              ).selected = false;
                              values.removeAt(3);
                            }else{
                              _ramalesSeleccionados = values;
                            }
                          },
                          chipDisplay: MultiSelectChipDisplay(
                            items: _ramalesSeleccionados
                                .map((e) =>
                                    MultiSelectItem(e, e["name"].toString()))
                                .toList(),
                            onTap: (value) {
                              setState(() {
                                _ramalesSeleccionados.remove(value);
                              });
                            },
                          )
                        ),
                        const SizedBox(height: 50),
                        ElevatedButton(
                            key: const Key("button_buscar_ramales"),
                            child: const Text(
                              "Buscar Ramales",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              final ramalesSelected = _ramalesSeleccionados;
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ColectivosMap(
                                          title: "Ramales de Colectivo",
                                          routes: ramalesSelected)));
                            }),
                        ]),
                    ),
                  ]),
                ),
        ));
  }
}
