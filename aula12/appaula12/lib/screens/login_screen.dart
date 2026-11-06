import 'package:appaula12/services/api_service.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  final ApiService api;
  const LoginScreen({super.key, required this.api});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usuario = TextEditingController();
  final _senha = TextEditingController();
  bool _carregando = false;

  Future<void> _entrar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _carregando = true);
    try{
      await widget.api.login(_usuario.text.trim(), _senha.text);
      if(!mounted) return;
      Navigator.push(
        context, MaterialPageRoute(builder: (_)=>)); // Chama a tela prodscreen
    }catch(e){
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Falha no Login: $e')));
      }
      
    }finally{
      if(mounted) setState(()=> _carregando = false);
    }
  }

  @override
  void dispose(){
    _usuario.dispose();
    _senha.dispose();
    super.dispose();
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(title: Text('App aula 12 - Django - Flutter'),),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 420,
          ),
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock_outline,size: 64,color: Colors.cyan,),
                  SizedBox(height: 20,),
                  TextFormField(
                    controller: _usuario,
                    decoration: InputDecoration(
                      labelText: 'Usuario',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v)=>v ==null ||v.isEmpty ?'Informe a senha':null,
                    onFieldSubmitted: (_)=> _carregando ? null: _entrar(),
                  ),
                  SizedBox(
                    width:  double.infinity,
                    child: FilledButton(
                      onPressed: _carregando ? null :_entrar,
                       child: Text(_carregando ? 'Entrando...': 'Entrar')),
                  ),
                  SizedBox(height: 12,),
                  Text('Utilize um usuario cadastrado no Django')

                ],
              )),
            ),
          ),
      ),
      
       );
  }
}
