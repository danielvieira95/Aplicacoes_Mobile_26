import 'package:appaula11/screens/prodscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart'
    as http; // Biblioteca para realizar requisições http
import 'dart:convert';

class CadastroProduto extends StatefulWidget {
  const CadastroProduto({super.key});

  @override
  State<CadastroProduto> createState() => _CadastroProdutoState();
}

class _CadastroProdutoState extends State<CadastroProduto> {
  // Criando as variaveis para cadastro dos produtos
  TextEditingController nomeprod = TextEditingController();
  TextEditingController qtde = TextEditingController();
  TextEditingController price = TextEditingController();

  // Função para fazer o cadastro dos produtos
  _cadastroproduto() async {
    String url = "http://10.109.84.8:8000/api/produtos/";

    // Cria a estrutura da mensagem para cadastro dos produtos
    Map<String, dynamic> prod = {
      "nome": nomeprod.text,
      "quantidade": qtde.text,
      "preco": price.text
    };

    await http.post(Uri.parse(url),
        headers: <String, String>{
          'Content-type': 'application/json; charset=UTF-8'
        },
        body: jsonEncode(prod));

    nomeprod.text = "";
    price.text = "";
    qtde.text = "";

    // Função para cadastrar um produto
    showDialog(
        context: context,
        builder: (BuildContext) {
          return AlertDialog(
            content: Text("Produto ${nomeprod.text} cadastrado !"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Fechar'))
            ],
          );
        });
  }

  // Função de deletar o produto
  _deletarProduto() {
    // Metodo para deletar um produto
    http.delete(Uri.parse('http://10.109.84.8/api/produtos/${nomeprod.text}/'));
    nomeprod.text = "";
    showDialog(
        context: context,
        builder: (BuildContext) {
          return AlertDialog(
            content: Text("Produto ${nomeprod.text} deletado !"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Fechar'))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        title: Text("App aula 11 - Flutter e Django"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              keyboardType: TextInputType.name,
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  hintText: "Digite o nome do produto"),
              controller: nomeprod,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              keyboardType: TextInputType.name,
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  hintText: "Digite o valor do produto"),
              controller: price,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  hintText: "Digite a qtde do produto"),
              controller: qtde,
            ),
          ),
          ElevatedButton(
              onPressed: _cadastroproduto, child: Text("Cadastrar produto")),
          ElevatedButton(
              onPressed: _deletarProduto, child: Text('Deletar produto')),
          ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Prodscreen()));
              },
              child: Text('Produtos Screen'))
        ],
      ),
    );
  }
}
