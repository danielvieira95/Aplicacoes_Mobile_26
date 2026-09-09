// Cria a classe restaurant data

import 'package:appaula04/model/restaurant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class RestaurantData extends ChangeNotifier {
  // Cria uma lista para carregar os restaurantes

  List<Restaurant> _listRestaurant = [];
  List<Restaurant> get listRestaurant => _listRestaurant;

  // Cria uma função Future

  Future<List<Restaurant>> getRestaurant() async {
    if (_listRestaurant.isNotEmpty) {
      return _listRestaurant; // evita recarregar se já tiver caregado uma vez
    }

    try {
      final String jsonString = await rootBundle.loadString('assets/data.json');
      final Map<String, dynamic> data = json.decode(jsonString);
      final List<dynamic> restaurantData = data['restaurants'];
      _listRestaurant
          .addAll(restaurantData.map((e) => Restaurant.fromMap(e)).toList());
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao carregar restaurants $e');
    }

    return _listRestaurant;
  }
}
