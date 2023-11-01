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
    final Map<Enum, Widget> cardsDisplayMap = {
      Cards.block: const BlockCardBig(onApply: nothing),
      Cards.nullify: const NullifyCardBig(onApply: nothing),
      Cards.randomSwap: const RandomSwapCardBig(onApply: nothing),
      Cards.swap: const SwapCardBig(onApply: nothing),
    };
    Map<Enum, int> selectedCardsMap = {};
    // common cards include block and randomSwap
    // special cards include nullify and swap

    Map<Enum, int> chooseCard(List<Enum> cardList, numberOfCards) {
      selectedCardsMap = {};
      for (int i = 0; i < numberOfCards; i++) {
        final chosenCard = cardList[generateRandomPosition(cardList.length)];
        ref.read(cardProvider.notifier).addCard(chosenCard);
        if (selectedCardsMap[chosenCard] != null) {
          selectedCardsMap[chosenCard] = selectedCardsMap[chosenCard]! + 1;
        } else {
          selectedCardsMap[chosenCard] = 1;
        }
      }
      return selectedCardsMap;
    }

    void showBoughtCards(Map<Enum, int> selectedCards) {
      setState(() {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              actions: [
                const SizedBox(height: 12),
                if (selectedCardsMap.length == 1)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ...selectedCards.entries.map(
                        (item) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 15,
                              backgroundColor:
                                  Theme.of(context).colorScheme.tertiary,
                              foregroundColor: Theme.of(context)
                                  .colorScheme
                                  .tertiaryContainer,
                              child: Text(
                                "${item.value}",
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                            ),
                            cardsDisplayMap[item.key]!
                          ],
                        ),
                      ),
                    ],
                  ),
                if (selectedCardsMap.length > 1)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ...selectedCards.entries.map(
                          (item) => Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 15,
                                backgroundColor:
                                    Theme.of(context).colorScheme.tertiary,
                                foregroundColor: Theme.of(context)
                                    .colorScheme
                                    .tertiaryContainer,
                                child: Text(
                                  "${item.value}",
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              cardsDisplayMap[item.key]!
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    )),
                    onPressed: (() {
                      Navigator.of(context).pop();
                    }),
                    child: Text(
                      "Ok",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      });
    }

    void regularPack() {
      final selectedCards = chooseCard(regularCardsList, 1);
      showBoughtCards(selectedCards);
    }

    void specialPack() {
      final selectedCards = chooseCard(specialCardsList, 1);
      showBoughtCards(selectedCards);
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
