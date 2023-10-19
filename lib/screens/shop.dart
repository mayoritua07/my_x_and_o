import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_x_and_o/main.dart';
import 'package:my_x_and_o/model/card.dart';

class Shop extends ConsumerStatefulWidget {
  const Shop({super.key});

  @override
  ConsumerState<Shop> createState() {
    return _ShopState();
  }
}

class _ShopState extends ConsumerState<Shop> {
  @override
  Widget build(BuildContext context) {
    ref.watch(darkModeProvider);
    final isDarkMode = ref.read(darkModeProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDarkMode
            ? Theme.of(context).colorScheme.background
            : Theme.of(context).colorScheme.onBackground,
        foregroundColor: isDarkMode
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSecondary,
        title: const Text("Shop"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Card Packs",
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.monetization_on,
                    color: Colors.yellow,
                    size: 30,
                  ),
                  SizedBox(width: 5),
                  Text(
                    "1000",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    CardPack(
                        color: Colors.red,
                        quantity: 1,
                        title: "Regular",
                        cards: const [],
                        rarity: "Common",
                        onBuy: () {},
                        price: 500),
                    CardPack(
                        color: Colors.purple,
                        quantity: 1,
                        title: "Super",
                        cards: const [],
                        rarity: "Special",
                        onBuy: () {},
                        price: 800)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
