import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';

class Prodscreen extends StatefulWidget {
  const Prodscreen({super.key});

  @override
  State<Prodscreen> createState() => _ProdscreenState();
}

class _ProdscreenState extends State<Prodscreen> {
  final String baseUrl = "http://10.109.84.8:8000/api/produtos/";

  @override
  // função que atualiza o status das telas
  void initState() {
    super.initState();
    leituradados();
  }

  // Lista de produtos
  List<Map<String, dynamic>> dado = [];

  // Função para a leitura da lista dos produtos

  Future<void> leituradados() async {
    final resp = await http.get(Uri.parse(baseUrl));
    if (resp.statusCode == 200) {
      final lista =
          (jsonDecode(resp.body) as List<dynamic>).cast<Map<String, dynamic>>();

      setState(() {
        dado = lista;
      });
    } else {
      throw Exception('Falha ao consumir API (${resp.statusCode})');
    }
  }

  Future<void> _atualizarProduto(
      {required int id,
      required String nome,
      required double preco,
      required int quantidade}) async {
    final url = Uri.parse('$baseUrl$id/');
    final body =
        jsonEncode({"nome": nome, "preco": preco, "quantidade": quantidade});

    final resp = await http.put(url,
        headers: {"Content-Type": "application/json"}, body: body);
    if (resp.statusCode == 200) {
      await leituradados();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Produto atuzlizado com sucesso !')));
      } else {
        final msg = resp.body.isNotEmpty ? resp.body : 'Erro desconhecido';
        throw Exception('Falha ao atualizar (${resp.statusCode}):$msg');
      }
    }
  }

  // Função para deletar o produto
  Future<void> _deletarProduto(int id) async {
    final url = Uri.parse('$baseUrl$id/');
    final resp = await http.delete(url);
    if (resp.statusCode == 204 || resp.statusCode == 200) {
      // atualiza a lista local sem refazer Get (mais rapido)
      setState(() {
        dado.removeWhere((e) => (e["id"] as num).toInt() == id);
      });
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Produto deletado !')));
      } else {
        final msg = resp.body.isEmpty ? resp.body : 'Erro desconhecido';
        throw Exception('Falha ao deletar ${resp.statusCode}):$msg');
      }
    }
  }

  // Função para poder editar o produto

  Future<void> _abrirDialogEdicao(Map<String, dynamic> item) async {
    final TextEditingController nomeCtrl =
        TextEditingController(text: item["nome"]?.toString() ?? "");
    final TextEditingController precoCtrl =
        TextEditingController(text: item["preco"]?.toString() ?? "");
    final TextEditingController qtdCtrl =
        TextEditingController(text: item["quantidade"]?.toString() ?? "");

    await showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text('Editar produto'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nomeCtrl,
                    decoration: InputDecoration(labelText: 'Nome'),
                  ),
                  TextField(
                    controller: precoCtrl,
                    decoration: InputDecoration(labelText: 'Preço R\$'),
                  ),
                  TextField(
                    controller: qtdCtrl,
                    decoration: InputDecoration(labelText: 'Quantidade'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancelar')),
                ElevatedButton(
                    onPressed: () async {
                      try {
                        final id = (item['id'] as num).toInt();
                        final nome = nomeCtrl.text.trim();
                        final preco =
                            double.parse(precoCtrl.text.replaceAll(',', '.'));
                        final qtd = int.parse(qtdCtrl.text);
                        await _atualizarProduto(
                            id: id, nome: nome, preco: preco, quantidade: qtd);
                        if (mounted) Navigator.pop(context);
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text('erro:$e')));
                        }
                      }
                    },
                    child: Text('Salvar'))
              ],
            ));
  }

  // Widgets Dismissible
  Widget _bgDismissLeft() => Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: 16),
        color: Colors.red,
        child: Row(
          children: [
            Icon(
              Icons.delete,
              color: Colors.white,
            ),
            SizedBox(
              width: 8,
            ),
            Text(
              'Apagar',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            )
          ],
        ),
      );

  Widget _bgDismissRight() => Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 16),
        color: Colors.red,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              Icons.delete,
              color: Colors.white,
            ),
            SizedBox(
              width: 8,
            ),
            Text(
              'Apagar',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            )
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        title: Text("Aula 11 Flutter e Django"),
      ),
      body: RefreshIndicator(
          onRefresh: leituradados,
          child: ListView.builder(
              // Para poder rolar a lista
              physics: AlwaysScrollableScrollPhysics(),
              itemCount: dado.length,
              itemBuilder: (context, index) {
                final item = dado[index];
                final id = (item["id"] as num).toInt();
                return Dismissible(
                    key: ValueKey<int>(id),
                    background: _bgDismissLeft(),
                    secondaryBackground: _bgDismissRight(),
                    direction: DismissDirection.horizontal,
                    confirmDismiss: (direction) async {
                      // confirmação antes de apagar
                      return await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                                title: Text('Confirmar exclusão'),
                                content:
                                    Text('Apagar o produto ${item['nome']}?'),
                                actions: [
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: Text('Cancelar')),
                                  ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.cyanAccent),
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: Text('Apagar'))
                                ],
                              ));
                    },
                    onDismissed: (direction) async {
                      try {
                        await _deletarProduto(id);
                      } catch (e) {
                        // Se falhar recarregar a lista
                        await leituradados();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Falha ao deletar: $e')));
                        }
                      }
                    },
                    child: Card(
                      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        title: Text(
                          'Nome: ${item['nome']}',
                          style: TextStyle(fontSize: 18),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Valor: R\$ ${item['preco']}',
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              'Qtde: ${item['quantidade']}',
                              style: TextStyle(fontSize: 16),
                            )
                          ],
                        ),
                        trailing: Icon(Icons.edit),
                        onTap: () => _abrirDialogEdicao(item),
                      ),
                    ));
              })),
    );
  }
}
