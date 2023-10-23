import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_x_and_o/main.dart';
import 'package:my_x_and_o/model/card.dart';
import 'package:my_x_and_o/providers/cards_provider.dart';

final randomizer = Random();
int generateRandomPosition(maxNumber) {
  return randomizer.nextInt(maxNumber);
}

enum Cards { block, randomSwap, nullify, swap }

final regularCardsList = [Cards.block, Cards.randomSwap];
final specialCardsList = [Cards.nullify, Cards.swap];
int money = 10000;

void nothing() {}

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
    final cardsDisplayMap = {
      Cards.block: const BlockCardBig(onApply: nothing),
      Cards.nullify: const NullifyCardBig(onApply: nothing),
      Cards.randomSwap: const RandomSwapCardBig(onApply: nothing),
      Cards.swap: const SwapCardBig(onApply: nothing),
    };
    // common cards include block and randomSwap
    // special cards include nullify and swap

    List chooseCard(List<Enum> cardList, numberOfCards) {
      final selectedCardsDisplay = [];
      for (int i = 0; i < numberOfCards; i++) {
        final chosenCard = cardList[generateRandomPosition(cardList.length)];
        ref.read(cardProvider.notifier).addCard(chosenCard);
        selectedCardsDisplay.add(cardsDisplayMap[chosenCard]);
      }
      return selectedCardsDisplay;
    }

    void regularPack() {
      final selectedCards = chooseCard(regularCardsList, 1);
      print(selectedCards);
      setState(() {});

      //   setState(() {
      //     showDialog(
      //       context: context,
      //       builder: (context) {
      //         return SizedBox(
      //           child: Expanded(
      //             child: SingleChildScrollView(
      //               scrollDirection: Axis.horizontal,
      //               child: Row(
      //                 children: [
      //                   cardsDisplayMap[chosenCard]!,
      //                 ],
      //               ),
      //             ),
      //           ),
      //         );
      //       },
      //     );
      //   });
    }

    void specialPack() {
      final selectedCards = chooseCard(specialCardsList, 1);
      print(selectedCards);
      setState(() {});
    }

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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Card Packs",
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.monetization_on,
                    color: Colors.yellow,
                    size: 30,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    "$money",
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
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
                        onBuy: regularPack,
                        price: 500),
                    CardPack(
                        color: Colors.purple,
                        quantity: 1,
                        title: "Super",
                        cards: const [],
                        rarity: "Special",
                        onBuy: specialPack,
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
