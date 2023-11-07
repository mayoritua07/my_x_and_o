import 'dart:math';

import 'package:flutter/material.dart';

final randomizer = Random();
int generateRandomPosition() {
  int randomValue = randomizer.nextInt(18) + 1;
  return randomValue;
}

class QuoteScreen extends StatelessWidget {
  const QuoteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Image.asset(
      "assets/images/splash_image/images${generateRandomPosition()}.jpeg",
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.fill,
    ));
  }
}
