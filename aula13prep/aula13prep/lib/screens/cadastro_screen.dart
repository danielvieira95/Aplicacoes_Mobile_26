import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key, required this.authService});
  final AuthService authService;
  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final username = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final tel = TextEditingController();
  bool loading = false;

  @override
  void dispose() {
    username.dispose();
    email.dispose();
    password.dispose();
    tel.dispose();
    super.dispose();
  }

  Future<void> register() async {
    if (username.text.trim().isEmpty ||
        email.text.trim().isEmpty ||
        password.text.isEmpty ||
        tel.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preencha todos os campos.')));
      return;
    }
    setState(() => loading = true);
    try {
      await widget.authService.register(
          username: username.text.trim(),
          email: email.text.trim(),
          password: password.text,
          telefone: tel.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário cadastrado com sucesso.')));
      Navigator.pop(context);
    } on ApiException catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Novo usuário')),
        body: ListView(padding: const EdgeInsets.all(24), children: [
          TextField(
              controller: username,
              decoration: const InputDecoration(labelText: 'Usuário')),
          const SizedBox(height: 16),
          TextField(
              controller: tel,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Telefone')),
          const SizedBox(height: 16),
          TextField(
              controller: email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'E-mail')),
          const SizedBox(height: 16),
          TextField(
              controller: password,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Senha')),
          const SizedBox(height: 24),
          FilledButton(
              onPressed: loading ? null : register,
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text('Cadastrar')),
        ]),
      );
}
