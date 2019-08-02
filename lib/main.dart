import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Tarefas",
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List _tarefas = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de tarefas"),
      ),
    );
  }

  // Retorna o arquivo .json onde as tarefas serão salvas ou 
  // cria um novo arquivo se não houver um
  Future<File> _getFile() async {
    Directory directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  // Salva as tarefas no arquivo data.json
  Future<File> _saveData() async {
    String data = json.encode(_tarefas);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  // Tenta ler o arquivo data.json
  Future<String> _readData() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      return null;
    }
  }
}
