import 'package:appaula09/screen/Scanner_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(TelaAppLeitorQRcode());
}

class TelaAppLeitorQRcode extends StatelessWidget {
  const TelaAppLeitorQRcode({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'App aula 09 Leitor de QRCode',
      theme:  ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: TelaHome(),
    );
  }
}


class TelaHome extends StatefulWidget {
  const TelaHome({super.key});

  @override
  State<TelaHome> createState() => _TelaHomeState();
}

class _TelaHomeState extends State<TelaHome> {
  String ? _ultimoConteudo;

  Future<void> _abrirLeitor()async{
    // abre a camera QRScannerPage e retorna a string com Navigator.pop
    final resultado = await Navigator.push<String>(context,MaterialPageRoute(builder: (_)=>QRScannerPage()));
    if(!mounted) return;
    if(resultado !=null && resultado.isNotEmpty){
      setState(()=> _ultimoConteudo = resultado);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('QR Code lido com sucesso')));
    }

  }
  @override
  Widget build(BuildContext context) {
    final conteudo = _ultimoConteudo ?? 'Nada lido ainda ! Toque no botão abaixo';
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title:  Text('Ler QRCode', style: TextStyle(color: Colors.white),),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300)
              ),
              child: SelectableText(conteudo,style: TextStyle(fontSize: 16),),
            ),

            SizedBox(height: 12,),
            Row(
              children: [
                Expanded(child: FilledButton.icon(
                  onPressed: _abrirLeitor, label: Text('Abrir camera')),
                  
                 ),
                 SizedBox(width: 12,),
                 IconButton.filledTonal(onPressed: _ultimoConteudo == null ? null:()async{
                  await Clipboard.setData(ClipboardData(text: _ultimoConteudo!));

                  if(!mounted)return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Copiado')));

                 }, icon: Icon(Icons.copy)),
                 SizedBox(width: 8,),
                 IconButton.filled(onPressed: _ultimoConteudo==null?null:()=>setState(()=>_ultimoConteudo=null),icon: Icon(
                  Icons.clear ),
                   
                 ),
                               
                 
                 
                 
                 
                 
              ],
            )

          ],
          
        ),
      ),
    );
  }
}