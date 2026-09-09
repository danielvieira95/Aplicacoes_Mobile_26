// Importa as bibliotecas

import 'package:appaula04/model/dish.dart';
import 'package:flutter/material.dart';

// Cria uma classe denominada BagProvider

class BagProvider extends ChangeNotifier {
  List<Dish> dishesOnBag =
      []; // cria uma lista vazia para carregar os itens a sacola

  // metodo para adicionar os itens ao carrinho

  addAllDishes(List<Dish> dishes) {
    // metodo para adicionar os itens ao carrinho
    dishesOnBag.addAll(dishes);
    // notifica cada item adicionado ao carrinho
    notifyListeners();
  }

  // metodo para remover os itens do carrinho
  removeDish(Dish dish) {
    dishesOnBag.remove(dish);
    notifyListeners();
  }

  @override
  String toString() {
    return 'BagProvider(dishesOnBag:$dishesOnBag)';
  }

  // Função para limpar a sacola

  clearBag() {
    dishesOnBag.clear();
    notifyListeners();
  }

  // Função para calcular o total do carrinho

  Map<Dish, int> getMapByAmount() {
    Map<Dish, int> mapResult = {};
    for (Dish dish in dishesOnBag) {
      if (mapResult[dish] == null) {
        mapResult[dish] = 1;
      } else {
        mapResult[dish] = mapResult[dish]! + 1;
      }
    }

    return mapResult;
  }
}
