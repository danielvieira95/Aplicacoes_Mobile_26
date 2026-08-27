import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart'; // importa a biblioteca que permite a manipulação do banco de dados
import 'package:path/path.dart'; // Importa a biblioteca que permite pegar o diretorio onde o banco de dados é criado

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Para garantir que o flutter esteja inicializado antes de acessar o banco de dados
  await _insertInitialDog();

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Home(),
  ));
}

// Função para inserir os dados no banco de dados

Future<void> _insertInitialDog() async {
  var database =
      await _initializeDatabase(); // armazena o banco de dados em database
  var Rocky = Dog(id: 1, nome: "Rocky", idade: 4);
  var Caju = Dog(id: 2, nome: "Caju", idade: 6);
}

// Função para inicializar o banco de dados

Future<Database> _initializeDatabase() async {
  return openDatabase(join(await getDatabasesPath(), 'dogs_a.db'),
      onCreate: (db, version) {
    db.execute(
        'CREATE TABLE dogsa(id INTEGER PRIMARY KEY, nome TEXT, idade INTEGER)');
  }, version: 1);
}

// Função para inserir informações no banco de dados

Future<void> _insertDog(Database database, Dog dog) async {
  await database.insert('dogsa', dog.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace);
}

// Função para deletar uma informação do banco de dados

Future<void> deleteDog(int id) async {
  final db = await _initializeDatabase();
  await db.delete('dogsa', where: 'id=?', whereArgs: [id]);
}

// Função para atualizar informação de um dado salvo no banco de dados

Future<void> updateDog(Dog dog) async {
  final db = await _initializeDatabase();
  await db.update('dogsa', dog.toMap(), where: 'id =?', whereArgs: [dog.id]);
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController nomedog = TextEditingController();
  TextEditingController idade = TextEditingController();
  int cont = 0;

  // late
  late Future<List<Dog>> _dogs;
  @override
  // initState permite carregar os dados
  void initState() {
    super.initState();
    _dogs = _fetchDogs();
  }

  Future<List<Dog>> _fetchDogs() async {
    var database = await _initializeDatabase();
    final List<Map<String, dynamic>> maps = await database.query('dogsa');
    return List.generate(maps.length, (i) {
      return Dog(
          id: maps[i]['id'], nome: maps[i]['nome'], idade: maps[i]['idade']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Text('Aula 04 - App BD'),
      ),
      body: Column(
        children: [
          TextField(
            keyboardType: TextInputType.name,
            controller: nomedog,
            decoration: InputDecoration(labelText: 'Digite o nome do dog'),
          ),
          TextField(
            keyboardType: TextInputType.number,
            controller: idade,
            decoration: InputDecoration(labelText: 'Digite a idade do dog'),
          ),
          ElevatedButton(
              onPressed: () async {
                final db = await _initializeDatabase();
                final dog = Dog(
                    id: cont, nome: nomedog.text, idade: int.parse(idade.text));
                await _insertDog(db, dog);
                setState(() {
                  cont = cont + 1;
                  _dogs = _fetchDogs();
                });
              },
              child: Text('Adicionar cachorro')),
          Expanded(
              child: FutureBuilder<List<Dog>>(
            future: _dogs,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else {
                final dogs = snapshot.data!; // armazena os dados
                return ListView.builder(
                    itemCount: dogs.length,
                    itemBuilder: (context, index) {
                      final dog = dogs[index];

                      return ListTile(
                        title: InkWell(
                          onTap: () async {
                            final confirmar = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: Text('Deletar'),
                                    content:
                                        Text('Deseja deletar ${dog.nome}?'),
                                    actions: [
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: Text('Deletar'))
                                    ],
                                  ),
                                ) ??
                                false;

                            if (!confirmar) return;

                            await deleteDog(dog.id);
                            setState(() {
                              _dogs = _fetchDogs(); // recarrega a lista
                            });
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('${dog.nome} deletado')));
                          },
                          child: Text(
                            dog.nome,
                            style: TextStyle(
                              decoration: TextDecoration
                                  .underline, // indica que o texto é clicavel
                            ),
                          ),
                        ),
                        subtitle: Text('Idade: ${dog.idade}'),
                        trailing: Text('ID: ${dog.id}'),
                      );
                    });
              }
            },
          ))
        ],
      ),
    );
  }
}

// Cria a classe Dog

class Dog {
  final int id;
  String nome;
  final int idade;

  // Cria o construtor
  Dog({required this.id, required this.nome, required this.idade});

  // Função para transformar os dados em Map para salvar no banco de dados

  Map<String, dynamic> toMap() {
    return {'id': id, 'nome': nome, 'idade': idade};
  }
}
