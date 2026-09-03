// importando a biblioteca flutter material.dart

import 'package:appaula04/ui/_core/app_colors.dart';
import 'package:appaula04/ui/widgets/home/home_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 25),
        child: Stack(
          children: [
            Image.asset('assets/banners/banner_splash.png'),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 32,
                children: [
                  Image.asset(
                    'assets/logo.png',
                    width: 192,
                  ),
                  Column(
                    children: [
                      Text(
                        'Um parceiro inovador para sua',
                        style: TextStyle(color: Colors.white, fontSize: 22),
                      ),
                      Text('Melhor experiência culinária',
                          style: TextStyle(
                              color: AppColors.mainColor,
                              fontSize: 22,
                              fontWeight: FontWeight.bold)),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HomeScreen()));
                            },
                            child: Text('Bora')),
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
