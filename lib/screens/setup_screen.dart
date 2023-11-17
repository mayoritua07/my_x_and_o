import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_x_and_o/main.dart';
import 'package:my_x_and_o/model/card.dart';
import 'package:my_x_and_o/providers/cards_provider.dart';
import 'package:my_x_and_o/providers/o_player_provider.dart';
import 'package:my_x_and_o/providers/sound.dart';
import 'package:my_x_and_o/providers/x_player_provider.dart';
import 'package:my_x_and_o/screens/quote_screen.dart';
import 'package:my_x_and_o/screens/shop.dart';
import 'package:my_x_and_o/widgets/snackbar.dart';

class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({
    super.key,
    required this.changePage,
  });

  final void Function(
          BuildContext context, String value, List<Enum> cards, bool? useCards)
      changePage;

  @override
  ConsumerState<SetupScreen> createState() {
    return _SetupScreenState();
  }
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  bool tapped = true;
  bool useCards = false;
  Map<Enum, Widget> cardsDisplayList = {};
  Map<Enum, Widget> originalCards = {};
  List<Enum> cards = [];
  String value = "X";

  final db = FirebaseFirestore.instance;

  @override
  void initState() {
    final blockCard = BlockCardBig(onApply: () {
      addingCards(Cards.block);
    });
    final nullifyCard = NullifyCardBig(onApply: () {
      addingCards(Cards.nullify);
    });
    final randomSwapCard = RandomSwapCardBig(onApply: () {
      addingCards(Cards.randomSwap);
    });
    final swapCard = SwapCardBig(onApply: () {
      addingCards(Cards.swap);
    });
    originalCards = {
      Cards.block: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          blockCard,
        ],
      ),
      Cards.nullify: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          nullifyCard,
        ],
      ),
      Cards.randomSwap: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          randomSwapCard,
        ],
      ),
      Cards.swap: Column(
        mainAxisSize: MainAxisSize.min,
        children: [const SizedBox(height: 20), swapCard],
      ),
    };

    for (final item in ref.read(cardProvider).entries) {
      if (item.value > 0) {
        cardsDisplayList.addAll({item.key: originalCards[item.key]!});
      }
    }

    super.initState();
  }

  void buttonSound(void Function() nextPage) async {
    if (ref.read(soundEffectProvider)) {
      final player = AudioPlayer();
      await player.setSource(AssetSource("audio/button_sound.mp3"));
      await player.resume();
    }

    Timer(const Duration(milliseconds: 200), () async {
      nextPage();
    });
  }

  void addingCards(Enum value) {
    setState(() {
      if (cards.contains(value)) {
        cards.remove(value);
        cardsDisplayList[value] = Column(
          mainAxisSize: MainAxisSize.min,
          children: [const SizedBox(height: 20), originalCards[value]!],
        );
      } else if (cards.length < 2) {
        cards.add(value);
        cardsDisplayList[value] = Column(
          mainAxisSize: MainAxisSize.min,
          children: [const Icon(Icons.check), originalCards[value]!],
        );
      } else {
        displayMySnackBar(context, "You can't selct more than 2 cards");
      }
    });
  }

  void clickButton(void Function() nextPage) async {
    if (ref.read(soundEffectProvider)) {
      final player = AudioPlayer();
      await player.setSource(AssetSource("audio/click_button.mp3"));
      await player.resume();
    }

    Timer(const Duration(milliseconds: 200), () async {
      nextPage();
    });
  }

  void nextPage() async {
    widget.changePage(context, value, cards, useCards);
    BuildContext? newContext;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          newContext = context;
          return const QuoteScreen();
        },
      ),
    );
    Timer(const Duration(seconds: 5), () {
      Navigator.of(newContext!).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = ref.read(darkModeProvider);
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final isLandscape = width > 650;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
            onPressed: () {
              clickButton(() {
                Navigator.of(context).pop();
              });
            },
            icon: const Icon(Icons.arrow_back_rounded)),
        backgroundColor: isDarkMode
            ? Theme.of(context).colorScheme.background
            : Theme.of(context).colorScheme.onBackground,
        foregroundColor: isDarkMode
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSecondary,
        title: const Text(
          'Set up Match',
          style: TextStyle(
            fontSize: 24,
          ),
        ),
      ),
      body: !isLandscape
          ? Padding(
              padding: const EdgeInsets.all(0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.tertiary,
                        borderRadius: BorderRadius.circular(0)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                tapped = true;
                                value = "X";
                              });
                            },
                            child: Container(
                              height: tapped ? 105 : 100,
                              width: tapped ? 105 : 100,
                              decoration: BoxDecoration(
                                  border: tapped
                                      ? Border.all(
                                          width: 5.0,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary)
                                      : null),
                              child: Center(
                                child: ref.read(xPlayerProvider),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                tapped = false;
                                value = "O";
                              });
                            },
                            child: Container(
                              height: !tapped ? 105 : 100,
                              width: !tapped ? 105 : 100,
                              decoration: BoxDecoration(
                                  border: !tapped
                                      ? Border.all(
                                          width: 5.0,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary)
                                      : null),
                              child: Center(
                                child: ref.read(oPlayerProvider),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Text(
                          "Use Cards",
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSecondaryContainer,
                              fontSize: 20,
                              fontWeight: useCards ? FontWeight.bold : null),
                        ),
                      ),
                      Checkbox(
                          value: useCards,
                          onChanged: (boolValue) {
                            setState(() {
                              useCards = boolValue!;
                            });
                          })
                    ],
                  ),
                  if (useCards)
                    Column(
                      children: [
                        Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Select cards from here",
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSecondaryContainer,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500),
                            )),
                        SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                                children: cardsDisplayList.values.toList())),
                      ],
                    ),
                  ElevatedButton(
                    onPressed: nextPage,
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      child: Text(
                        "Next",
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.w400),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: useCards ? width / 2 : width,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.tertiary,
                            borderRadius: BorderRadius.circular(0)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    tapped = true;
                                    value = "X";
                                  });
                                },
                                child: Container(
                                  height: tapped ? 105 : 100,
                                  width: tapped ? 105 : 100,
                                  decoration: BoxDecoration(
                                      border: tapped
                                          ? Border.all(
                                              width: 5.0,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary)
                                          : null),
                                  child: Center(
                                    child: ref.read(xPlayerProvider),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    tapped = false;
                                    value = "O";
                                  });
                                },
                                child: Container(
                                  height: !tapped ? 105 : 100,
                                  width: !tapped ? 105 : 100,
                                  decoration: BoxDecoration(
                                      border: !tapped
                                          ? Border.all(
                                              width: 5.0,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary)
                                          : null),
                                  child: Center(
                                    child: ref.read(oPlayerProvider),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text(
                              "Use Cards",
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSecondaryContainer,
                                  fontSize: 20,
                                  fontWeight:
                                      useCards ? FontWeight.bold : null),
                            ),
                          ),
                          Checkbox(
                              value: useCards,
                              onChanged: (boolValue) {
                                setState(() {
                                  useCards = boolValue!;
                                });
                              }),
                          // SizedBox(width: width / 6),
                          // const Padding(
                          //   padding: EdgeInsets.only(left: 10),
                          //   child: Text("Timed"),
                          // ),
                          // Checkbox(
                          //     value: useCards,
                          //     onChanged: (boolValue) {
                          //       setState(() {
                          //         useCards = boolValue!;
                          //       });
                          //     })
                        ],
                      ),
                      SizedBox(height: height / 12),
                      ElevatedButton(
                        onPressed: nextPage,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 20, horizontal: 20),
                          child: Text(
                            "Next",
                            style: TextStyle(
                                fontSize: 25, fontWeight: FontWeight.w400),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        if (useCards)
                          Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Select cards from here",
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondaryContainer,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                      children:
                                          cardsDisplayList.values.toList())),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
