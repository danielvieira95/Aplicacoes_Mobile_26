import 'package:appaula11/screens/cadastroprod.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(AppAula11());
}

class AppAula11 extends StatelessWidget {
  const AppAula11({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
    home: CadastroProduto());
  }
}
