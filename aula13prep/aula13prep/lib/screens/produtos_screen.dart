import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/token_service.dart';
import 'login_screen.dart';

class ProdutosScreen extends StatefulWidget {
  const ProdutosScreen({super.key, required this.tokenService});
  final TokenService tokenService;
  @override
  State<ProdutosScreen> createState() => _ProdutosScreenState();
}

class _ProdutosScreenState extends State<ProdutosScreen> {
  late Future<dynamic> products;
  @override
  void initState() {
    super.initState();
    products = loadProducts();
  }

  Future<dynamic> loadProducts() =>
      ApiService(token: widget.tokenService.accessToken).get('/produtos/');

  Future<void> createProduct() async {
    final name = TextEditingController();
    final price = TextEditingController();
    final description = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final created = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Cadastrar produto'),
              content: Form(
                  key: formKey,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    TextFormField(
                        controller: name,
                        decoration: const InputDecoration(labelText: 'Nome'),
                        validator: (v) => v!.isEmpty ? 'Informe o nome' : null),
                    TextFormField(
                        controller: price,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Preço'),
                        validator: (v) =>
                            v!.isEmpty ? 'Informe o preço' : null),
                    TextFormField(
                        controller: description,
                        decoration:
                            const InputDecoration(labelText: 'Descrição')),
                  ])),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancelar')),
                FilledButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      try {
                        await ApiService(token: widget.tokenService.accessToken)
                            .post('/produtos/', {
                          'nome': name.text.trim(),
                          'preco': price.text.trim(),
                          'descricao': description.text.trim()
                        });
                        if (context.mounted) Navigator.pop(context, true);
                      } on ApiException catch (error) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(error.message)));
                        }
                      }
                    },
                    child: const Text('Salvar'))
              ],
            ));
    name.dispose();
    price.dispose();
    description.dispose();
    if (created == true && mounted) setState(() => products = loadProducts());
  }

  Future<void> createOrder(Map<String, dynamic> product) async {
    final productId = product['id'];
    if (productId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produto sem identificador.')));
      return;
    }
    try {
      await ApiService(token: widget.tokenService.accessToken)
          .post('/pedidos/', {
        'produto': productId,
        'quantidade': 1,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pedido realizado com sucesso.')));
      }
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    }
  }

  void logout() {
    widget.tokenService.clearToken();
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (_) => LoginScreen(
                authService: AuthService(tokenService: widget.tokenService))),
        (_) => false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Produtos'), actions: [
          IconButton(onPressed: logout, icon: const Icon(Icons.logout))
        ]),
        floatingActionButton: FloatingActionButton.extended(
            onPressed: createProduct,
            icon: const Icon(Icons.add),
            label: const Text('Produto')),
        body: FutureBuilder<dynamic>(
            future: products,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                    child:
                        Text('Erro ao carregar produtos.\n${snapshot.error}'));
              }
              final data = snapshot.data;
              final list = data is List
                  ? data
                  : data is Map<String, dynamic>
                      ? (data['results'] as List? ?? [])
                      : <dynamic>[];
              if (list.isEmpty) {
                return const Center(child: Text('Nenhum produto encontrado.'));
              }
              return RefreshIndicator(
                  onRefresh: () async =>
                      setState(() => products = loadProducts()),
                  child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final product = list[index] as Map<String, dynamic>;
                        return Card(
                            child: ListTile(
                                title: Text(
                                    '${product['nome'] ?? product['name'] ?? 'Produto'}'),
                                subtitle: Text(
                                    '${product['descricao'] ?? product['description'] ?? ''}'),
                                trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                          'R\$ ${product['preco'] ?? product['price'] ?? '-'}'),
                                      IconButton(
                                        tooltip: 'Fazer pedido',
                                        onPressed: () => createOrder(product),
                                        icon: const Icon(Icons.shopping_cart),
                                      ),
                                    ])));
                      }));
            }),
      );
}
