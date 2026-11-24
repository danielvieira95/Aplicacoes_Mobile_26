import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'cadastro_screen.dart';
import 'produtos_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.authService});
  final AuthService authService;
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final username = TextEditingController();
  final password = TextEditingController();
  bool loading = false;

  @override
  void dispose() {
    username.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (username.text.trim().isEmpty || password.text.isEmpty) {
      message('Informe usuário e senha.');
      return;
    }
    setState(() => loading = true);
    try {
      await widget.authService
          .login(username: username.text.trim(), password: password.text);
      if (!mounted) return;
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => ProdutosScreen(
                  tokenService: widget.authService.tokenService)));
    } on ApiException catch (error) {
      message(error.message);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void message(String value) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(value)));

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Entrar')),
      body: Center(
        child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(children: [
                  const Icon(Icons.shopping_bag, size: 72),
                  const SizedBox(height: 20),
                  TextField(
                      controller: username,
                      decoration: const InputDecoration(labelText: 'Usuário')),
                  const SizedBox(height: 16),
                  TextField(
                      controller: password,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Senha')),
                  const SizedBox(height: 24),
                  FilledButton(
                      onPressed: loading ? null : login,
                      child: loading
                          ? const CircularProgressIndicator()
                          : const Text('Entrar')),
                  TextButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => CadastroScreen(
                                  authService: widget.authService))),
                      child: const Text('Criar novo usuário')),
                ]))),
      ));
}
