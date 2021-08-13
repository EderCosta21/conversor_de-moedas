import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

// var url_base =  Url.htpps("https://api.hgbrasil.com/finance?format=json&key=dbb78a35"); // url hg brasil para receber os dados para converter
var url =
    Uri.parse('https://api.hgbrasil.com/finance?format=json&key=dbb78a35');

Future<void> main() async {
  print(await getData());
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
      hintColor: Colors.white,
      primaryColor: Colors.white,
      // inputDecorationTheme: InputDecorationTheme(
      //   enabledBorder:
      //       OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
      //   focusedBorder:
      //       OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
      //   hintStyle: TextStyle(color: Colors.amber),
      // )
    ),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double dolar;
  double euro;
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  void realChange(String text) {
      if(text.isEmpty) {
      _clearAll();
      return;
    }
    double real = double.parse(text);
    dolarController.text = (real / dolar).toStringAsPrecision(2);
    euroController.text = (real / euro).toStringAsPrecision(2);
  }

  void dolarChange(String text) {
      if(text.isEmpty) {
      _clearAll();
      return;
    }
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsPrecision(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsPrecision(2);
  }

  void euroChange(String text) {
      if(text.isEmpty) {
      _clearAll();
      return;
    }
   double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsPrecision(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsPrecision(2);
  }

  void _clearAll(){
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      appBar: AppBar(
        title: Text(" \$ Conversor \$"),
        backgroundColor: Colors.red[900],
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text(
                  "Carregando dados",
                  style: TextStyle(color: Colors.white, fontSize: 25.0),
                  textAlign: TextAlign.center,
                ),
              );
            default:
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Erro ao carregar os dados",
                    style: TextStyle(color: Colors.white, fontSize: 25.0),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                return SingleChildScrollView(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.monetization_on,
                        size: 125.0,
                        color: Colors.amber[900],
                      ),
                      buildTexField("Reais", "R\$", realController, realChange),
                      Divider(),
                      buildTexField(
                          "Dolar", "US\$", dolarController, dolarChange),
                      Divider(),
                      buildTexField("euro", "€", euroController, euroChange),
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

buildTexField(
    String label, String prefix, TextEditingController c, Function change) {
// "€"
  return TextField(
    controller: c,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: Colors.white,
      ),
      border: OutlineInputBorder(),
      prefixText: prefix,
    ),
    style: TextStyle(
      color: Colors.white,
      fontSize: 25.0,
    ),
    onChanged: change,
   keyboardType: TextInputType.numberWithOptions(decimal: true),
  );
}

Future<Map> getData() async {
  http.Response response = await http.get(url);

// json.decode(response.body)["results"]["currencies"]["USD"]; exemploo de acesso a tal elemento
  return json.decode(response.body);
}
