import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
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
  @override
  void initState() {
    super.initState();
    _readData().then((data) {
      setState(() {
        _tarefas = json.decode(data);
      });
    });
  }

  final _tarefaController = TextEditingController();

  List _tarefas = [];
  Map<String, dynamic> _ultimaRemovida;
  int _ultimaRemovidaIndex;

  void _addTarefa() {
    if (_tarefaController.text.isNotEmpty) {
      setState(() {
        Map<String, dynamic> novaTarefa = Map();
        novaTarefa["title"] = _tarefaController.text;
        novaTarefa["ok"] = false;
        _tarefaController.clear();
        _tarefas.add(novaTarefa);
        _saveData();
      });
    }
  }

  Future<Null> _refresh() async {
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _tarefas.sort((a, b) {
        if (a["ok"] && !b["ok"])
          return 1;
        else if (!a["ok"] && b["ok"])
          return -1;
        else
          return 0;
      });

      _saveData();
    });
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de tarefas"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.builder(
                  itemCount: _tarefas.length, itemBuilder: buidItem),
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
                    child: Text("Adicionar", style: TextStyle(color: Colors.indigo)),
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

  Widget buidItem(context, index) {
    return Dismissible(
      key: ObjectKey(_tarefas[index]),
      direction: DismissDirection.startToEnd,
      background: Container(color: Colors.red),
      onDismissed: (direction) {
        setState(() {
          _ultimaRemovida = Map.from(_tarefas[index]);
          _ultimaRemovidaIndex = index;
          _tarefas.removeAt(index);
          _saveData();
          final snack = SnackBar(
            content: Text("Tarefa \"${_ultimaRemovida["title"]}\" removida"),
            action: SnackBarAction(
              label: "Desfazer",
              onPressed: () {
                setState(() {
                  _tarefas.insert(_ultimaRemovidaIndex, _ultimaRemovida);
                  _saveData();
                });
              },
            ),
            duration: Duration(seconds: 3),
          );

          Scaffold.of(context).removeCurrentSnackBar();
          Scaffold.of(context).showSnackBar(snack);
        });
      },
      child: CheckboxListTile(
        title: Text(_tarefas[index]["title"]),
        value: _tarefas[index]["ok"],
        secondary: CircleAvatar(
          backgroundColor: _tarefas[index]["ok"] ? Colors.green : Colors.indigo,
          child: Icon(_tarefas[index]["ok"] ? Icons.done : Icons.short_text,
              color: Colors.white),
        ),
        onChanged: (check) {
          setState(() {
            _tarefas[index]["ok"] = check;
            _saveData();
          });
        },
      ),
    );
  }
}
