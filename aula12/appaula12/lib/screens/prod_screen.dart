import 'package:appaula12/screens/login_screen.dart';
import 'package:appaula12/services/api_service.dart';
import 'package:flutter/material.dart';

class ProdScreen extends StatefulWidget {
  final ApiService api;
  const ProdScreen({super.key, required this.api});

  @override
  State<ProdScreen> createState() => _ProdScreenState();
}

class _ProdScreenState extends State<ProdScreen> {
  List<Map<String, dynamic>> dado = [];
  bool carregando = true;
  String? erro;
  @override
  void initState() {
    super.initState();
    leituradados();
  }

  Future<void> leituradados() async {
    setState(() {
      carregando = true;
      erro = null;
    });

    try {
      final lista = await widget.api.listarProdutos();
      if (!mounted) return;
      setState(() => dado = lista);
    } catch (e) {
      if (!mounted) return;
      setState(() => erro = e.toString());
    } finally {
      if (mounted) setState(() => carregando = false);
    }
  }

  void _mensagem(String texto) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> _abrirCadastro()async{
    final cadastrado = await Navigator.push<bool>(context, 
    MaterialPageRoute(builder: (_)=>));// chama a tela de cadastro de produto

    if(!mounted) return;
    if(cadastrado == true){
      _mensagem('Produto cadastrado com sucesso');
      await leituradados();
    }
  }

  Future<void> _abrirDialogEdicao(Map<String,dynamic>item)async{
    final nomeCtrl = TextEditingController(text:'${item['nome']??''}');
    final precoCtrl = TextEditingController(text: '${item['preco']??''}');
    final qtdCtrl = TextEditingController(text:'${item['quantidade']??''}' );
    // o dialog retorn os dados: a requisição e fecha depois do fechamento

    final valores = await showDialog(
      context: context, builder: (ctx)=>AlertDialog(
        title: Text('Editar produto'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomeCtrl,
                decoration: InputDecoration(labelText: 'Nome') ,
              ),
              TextField(
                controller: precoCtrl,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: 'Preco (R\$)') ,
              ),

              TextField(
                controller: qtdCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Quantidade'),
              ),

            ],
          )
        ),
        actions: [
          TextButton(
            onPressed: ()=>Navigator.pop(ctx), 
            child: Text('Cancelar')),
            FilledButton(
              onPressed: (){
                final nome = nomeCtrl.text.trim();
                final preco = double.tryParse(precoCtrl.text.replaceAll(',', '.'));
                final quantidade = int.tryParse(qtdCtrl.text);
                if(nome.isEmpty || preco == null || !preco.isFinite || preco <0 || quantidade == null || quantidade<0){
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Preencha os campos corretamente')));
                  return;
                }
                Navigator.pop(ctx,{
                  'nome':nome,'preco':preco,'quantidade':quantidade
                });
              },
              child: Text('Salvar')),
                     
        ],
      ));

      nomeCtrl.dispose();
      precoCtrl.dispose();
      qtdCtrl.dispose();
      if(!mounted || valores == null) return;
      try{
        await widget.api.atualizarProduto(
          id: (item['id'] as num).toInt(), 
          nome: valores['nome']as String, 
          preco: valores['preco'] as double,
          quantidade: valores['quantidade'] as int);
          if(!mounted)return;
          _mensagem('Produto atualizado com sucesso !');
          await leituradados();
      }catch(e){
        _mensagem('Erro ao atualizar: $e');
      }
  }

  Future<bool> _confirmarExclusao(Map<String,dynamic>item)async{
    final confirmado = await showDialog<bool>(
      context: context, builder: (ctx)=>AlertDialog(
        title: Text('Confirmar exclusão'),
        content: Text('Apagar o produto ${item['nome']}?'),
        actions: [
          TextButton(
            onPressed: ()=>Navigator.pop(ctx,false),
             child: Text('Cancelar')),
             FilledButton(
              onPressed: ()=>Navigator.pop(ctx,true), 
              child: Text('Apagar'))
        ],
      ));

      if(confirmado !=true || !mounted) return false;
      try{
        await widget.api.deletarProduto((item['id']as num).toInt());
        if(!mounted) return false;
        setState(() {
          dado.removeWhere((e)=>e['id']==item['id']);
          _mensagem('Produto deletado');
        });
      }catch(e){
        _mensagem('Erro ao deletar: $e');
      }
      return false;
  }

  void _sair(){
    widget.api.logout();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>LoginScreen(api: widget.api)));
  }

  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
