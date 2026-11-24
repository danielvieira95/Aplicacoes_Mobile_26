import 'api_service.dart';
import 'token_service.dart';

class AuthService {
  AuthService({required this.tokenService});
  final TokenService tokenService;

  Future<void> login(
      {required String username, required String password}) async {
    final data = await ApiService()
        .post('/token/', {'username': username, 'password': password});
    final token =
        data is Map<String, dynamic> ? data['access'] as String? : null;
    if (token == null) {
      throw ApiException('Token não retornado pelo servidor.', 200);
    }
    tokenService.saveToken(token);
  }

  Future<void> register(
      {required String username,
      required String nome,
      required String email,
      required String password,
      required String telefone}) async {
    await ApiService().post('/usuarios/cadastrar/', {
      'username': username,
      'nome': nome,
      'email': email,
      'password': password,
      'telefone': telefone
    });
  }
}
