import 'package:appaula04/data/categories_data.dart';
import 'package:appaula04/data/restaurant_data.dart';
import 'package:appaula04/model/restaurant.dart';
import 'package:appaula04/ui/_core/app_colors.dart';
import 'package:appaula04/ui/widgets/home/widget/category_widget.dart';
import 'package:appaula04/ui/widgets/home/widget/restaurant_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  // RestaurantData
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Cria o restaurantData
    RestaurantData restaurantData = Provider.of<RestaurantData>(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      drawer: Drawer(),
      appBar: AppBar(
        title: Text(
          'App Delivery',
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              spacing: 32,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/logo.png',
                  width: 147,
                ),
                Text('Boas vindas !'),
                Text('Escolha por categoria'),
                // Scroll na horizontal
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                      spacing: 10,
                      children: List.generate(
                          CategoriesData.listCategories.length, (index) {
                        return CategoryWidget(
                            category: CategoriesData.listCategories[index]);
                      })),
                ),

                Image.asset('assets/banners/banner_promo.png'),
                Text(
                  'Bem avaliados',
                  style: TextStyle(
                      color: AppColors.mainColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),

                Column(
                  spacing: 16,
                  children: List.generate(restaurantData.listRestaurant.length,
                      (index) {
                    Restaurant restaurant =
                        restaurantData.listRestaurant[index];
                    return RestaurantWidget(restaurant: restaurant);
                  }),
                ),
                SizedBox(
                  height: 64,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
