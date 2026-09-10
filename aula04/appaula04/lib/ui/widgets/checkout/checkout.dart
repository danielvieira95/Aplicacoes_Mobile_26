import 'package:appaula04/model/dish.dart';
import 'package:appaula04/ui/_core/app_colors.dart';
import 'package:appaula04/ui/widgets/bag_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  @override
  Widget build(BuildContext context) {
    BagProvider bagProvider = Provider.of<BagProvider>(context);
    // calcula o valor total
    double total = 0;
    bagProvider.getMapByAmount().forEach((dish, amount) {
      total += dish.price * amount;
    });
    return Scaffold(
        appBar: AppBar(
          title: Text('Sacola'),
          actions: [
            TextButton(
                onPressed: () {
                  bagProvider.clearBag();
                },
                child: Text('Limpar'))
          ],
        ),
        body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Pedidos',
                  textAlign: TextAlign.center,
                ),
                Column(
                  children: List.generate(
                      bagProvider.getMapByAmount().keys.length, (index) {
                    Dish dish =
                        bagProvider.getMapByAmount().keys.toList()[index];
                    return ListTile(
                      leading: Image.asset(
                        'assets/dishes/default.png',
                        width: 48,
                        height: 48,
                      ),
                      title: Text(dish.name),
                      subtitle: Text('R\$${dish.price.toStringAsFixed(2)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              onPressed: () {
                                bagProvider.removeDish(dish);
                              },
                              icon: Icon(Icons.remove)),
                          Text(bagProvider.getMapByAmount()[dish].toString()),
                          IconButton(
                              onPressed: () {
                                bagProvider.addAllDishes([dish]);
                              },
                              icon: Icon(Icons.add))
                        ],
                      ),
                    );
                  }),
                ),

                SizedBox(
                  height: 16,
                ),
                Text(
                  'Pagamento',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),

                Stack(alignment: Alignment.centerLeft, children: [
                  Container(
                    width: double.infinity,
                    height: 100,
                    color: AppColors.fundoCards,
                  ),
                  Container(
                    width: 100,
                    height: 80,
                    color: AppColors.fundoCards,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Image.asset(
                        'assets/others/visa.png',
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  Positioned(
                      left: 100,
                      child: Text(
                        'Visa Classic',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      )),
                ]),
                SizedBox(
                  height: 24,
                ),
                // total da compra
                Text(
                  'Total R\$ ${total.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.end,
                ),

                SizedBox(
                  height: 12,
                ),
                // botão pedir
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: EdgeInsets.symmetric(vertical: 16)),
                    onPressed: () {
                      bagProvider.clearBag();
                      // Aqui define a ação do pedido e exibe a mensagem
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Pedido realizado !')));
                    },
                    child: Text(
                      'Pedir',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ))
              ],
            ))));
  }
}
