// Arquivo responsável por realizar as requisições com a API em Django

import 'dart:convert';
import 'package:http/http.dart' as http;

// classe abstrata
class ApiException implements Exception {
  final int? statusCode;
  final String mensagem;
  ApiException(this.mensagem, [this.statusCode]);

  @override
  String toString() => mensagem;
}

class ApiService {
  // Celular fisico use o IP do computador na mesma rede
  // Emulador Android geralmente http://10.0.2.2:8000/api
  static const String baseUrl = 'http://10.109.84.8:8000/api/';

  String? _accessToken;
  String? _refreshToken;
  void logout() {
    _accessToken = null;
    _refreshToken = null;
  }

  Future<void> login(String usuario, String senha) async {
    final resposta = await http.post(Uri.parse('${baseUrl}token/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': usuario, 'password': senha}));

    if (resposta.statusCode != 200) {
      throw ApiException('Usuario ou senha invalidos (${resposta.statusCode})',
          resposta.statusCode);
    }

    final dados =
        jsonDecode(utf8.decode(resposta.bodyBytes)) as Map<String, dynamic>;
    _accessToken = dados['access'] as String;
    _refreshToken = dados['refresh'] as String;
  }

  // Função para renovar o token

  Future<bool> _renovarToken() async {
    if (_refreshToken == null) return false;
    try {
      final resp = await http.post(Uri.parse('${baseUrl}token/refresh'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'refresh': _refreshToken}));
      if (resp.statusCode != 200) return false;
      final dados =
          jsonDecode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>;
      _accessToken = dados['access'] as String;
      if (dados['refresh'] is String) {
        _refreshToken = dados['refresh'] as String;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<http.Response> _enviar(
    String metodo,
    String caminho, {
    Map<String, dynamic>? dados,
  }) async {
    Future<http.Response> requisicao() {
      final uri = Uri.parse('$baseUrl$caminho');
      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (_accessToken != null) 'Authorizaion': 'Bearer $_accessToken',
      };
      final corpo = dados == null ? null : jsonEncode(dados);
      switch (metodo) {
        case 'GET':
          return http.get(uri, headers: headers);
        case 'POST':
          return http.post(uri, headers: headers, body: corpo);
        case 'PUT':
          return http.put(uri, headers: headers, body: corpo);
        case 'DELETE':
          return http.delete(uri, headers: headers);
        default:
          throw ArgumentError('Metodo HTTP nao suportado');
      }
    }

    var resposta = await requisicao();
    if (resposta.statusCode == 401 && await _renovarToken()) {
      resposta = await requisicao();
    }

    if (resposta.statusCode < 200 || resposta.statusCode >= 300) {
      final corpo = utf8.decode(resposta.bodyBytes);
      throw ApiException(
          resposta.statusCode == 401
              ? 'Sessão expirada ! Faça Login novamente'
              : 'Erro HTTP ${resposta.statusCode}: $corpo',
          resposta.statusCode);
    }
    return resposta;
  }

  Future<List<Map<String, dynamic>>> listarProdutos() async {
    final resp = await _enviar('GET', 'produtos/');
    final corpo = jsonDecode(utf8.decode(resp.bodyBytes));
    // DRF pode retornar uma lista ou um objeto com a chave results
    final lista = corpo is List
        ? corpo
        : (corpo as Map<String, dynamic>)['results'] as List;
    return lista.map((item) => Map<String, dynamic>.from(item as Map)).toList();
  }

  Future<void> cadastrarProduto(
      {required String nome,
      required double preco,
      required int quantidade}) async {
    await _enviar('POST', 'produtos/',
        dados: {'nome': nome, 'preco': preco, 'quantidade': quantidade});
  }

  Future<void> atualizarProduto(
      {required int id,
      required String nome,
      required double preco,
      required int quantidade}) async {
    await _enviar('PUT', 'produtos/$id/',
        dados: {'nome': nome, 'preco': preco, 'quantidade': quantidade});
  }

  Future<void> deletarProduto(int id) async {
    await _enviar('DELETE', 'produtos/$id/');
  }
}
