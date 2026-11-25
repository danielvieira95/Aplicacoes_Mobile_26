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
  List<Map<String, dynamic>> products = [];
  bool loadingProducts = true;
  String? productsError;
  @override
  void initState() {
    super.initState();
    refreshProducts();
  }

  Future<dynamic> loadProducts() =>
      ApiService(token: widget.tokenService.accessToken).get('/produtos/');

  Future<void> refreshProducts() async {
    setState(() {
      loadingProducts = true;
      productsError = null;
    });
    try {
      final data = await loadProducts();
      final list = data is List
          ? data
          : data is Map<String, dynamic>
              ? (data['results'] as List? ?? [])
              : <dynamic>[];
      if (!mounted) return;
      setState(() {
        products = list.whereType<Map<String, dynamic>>().toList();
        loadingProducts = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        productsError = error.toString();
        loadingProducts = false;
      });
    }
  }

  Future<void> createProduct() async {
    final name = TextEditingController();
    final price = TextEditingController();
    final description = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final created = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Cadastrar produto'),
              content: SingleChildScrollView(
                  child: Form(
                      key: formKey,
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        TextFormField(
                            controller: name,
                            decoration:
                                const InputDecoration(labelText: 'Nome'),
                            validator: (v) =>
                                v!.isEmpty ? 'Informe o nome' : null),
                        TextFormField(
                            controller: price,
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(labelText: 'Preço'),
                            validator: (v) =>
                                v!.isEmpty ? 'Informe o preço' : null),
                        TextFormField(
                            controller: description,
                            decoration:
                                const InputDecoration(labelText: 'Descrição')),
                      ]))),
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
    if (created == true && mounted) await refreshProducts();
  }

  Future<void> createOrder(Map<String, dynamic> product) async {
    final productName = product['nome'] ?? product['name'];
    if (productName == null || productName.toString().trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Produto sem nome.')));
      return;
    }

    final quantityController = TextEditingController(text: '1');
    final quantity = await showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Fazer pedido'),
        content: TextField(
          controller: quantityController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Quantidade'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final value = int.tryParse(quantityController.text.trim());
              if (value == null || value <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Informe uma quantidade válida.')));
                return;
              }
              Navigator.pop(dialogContext, value);
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    if (quantity == null || !mounted) return;

    try {
      await ApiService(token: widget.tokenService.accessToken)
          .post('/pedidos/', {
        'produto': productName,
        'quantidade': quantity,
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

  Future<bool> deleteProduct(Map<String, dynamic> product) async {
    final productId = product['id'];
    if (productId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produto sem identificador.')));
      return false;
    }

    try {
      await ApiService(token: widget.tokenService.accessToken)
          .delete('/produtos/$productId/');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Produto excluído com sucesso.')));
      }
      return true;
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
      return false;
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
        body: loadingProducts
            ? const Center(child: CircularProgressIndicator())
            : productsError != null
                ? Center(
                    child: Text('Erro ao carregar produtos.\n$productsError'))
                : RefreshIndicator(
                    onRefresh: refreshProducts,
                    child: products.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 240),
                              Center(child: Text('Nenhum produto encontrado.')),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final product = products[index];
                              return Dismissible(
                                key: ValueKey(product['id'] ?? index),
                                direction: DismissDirection.endToStart,
                                confirmDismiss: (_) => deleteProduct(product),
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 24),
                                  color: Colors.red,
                                  child: const Icon(Icons.delete,
                                      color: Colors.white),
                                ),
                                child: Card(
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
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
      );
}
