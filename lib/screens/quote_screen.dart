import 'dart:math';

import 'package:flutter/material.dart';

final randomizer = Random();
int generateRandomPosition() {
  int randomValue = randomizer.nextInt(images.length);
  return randomValue;
}

final List<String> quotes = [
  "Thank God for life",
  "Stay Happy",
  "Joy Overflow"
];

final List<String> images = [];

class QuoteScreen extends StatelessWidget {
  const QuoteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Image.asset(
      images[generateRandomPosition()],
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
    ));
  }
}
