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
  final _tarefaController = TextEditingController();
  ScrollController _scrollController = new ScrollController();

  List _tarefas = [];

  void _addTarefa() {
    setState(() {
      Map<String, dynamic> novaTarefa = Map();
      novaTarefa["title"] = _tarefaController.text;
      novaTarefa["ok"] = false;
      _tarefaController.clear();
      _tarefas.add(novaTarefa);
      _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 56,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de tarefas"),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _tarefas.length,
              itemBuilder: (context, index) {
                return CheckboxListTile(
                  title: Text(_tarefas[index]["title"]),
                  value: _tarefas[index]["ok"],
                  secondary: CircleAvatar(
                    backgroundColor:
                        _tarefas[index]["ok"] ? Colors.green : Colors.indigo,
                    child: Icon(
                        _tarefas[index]["ok"] ? Icons.done : Icons.short_text,
                        color: Colors.white),
                  ),
                  onChanged: (check) {
                    setState(() {
                      _tarefas[index]["ok"] = check;
                    });
                  },
                );
              },
            ),
          ),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
            elevation: 8,
            margin: EdgeInsets.only(top: 4),
            child: Container(
              padding: EdgeInsets.all(8),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _tarefaController,
                      decoration: InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(),
                          hintText: "Nova tarefa"),
                    ),
                  ),
                  SizedBox(width: 8),
                  OutlineButton(
                    child: Text("Adicionar"),
                    onPressed: _addTarefa,
                  )
                ],
              ),
            ),
          )
        ],
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
