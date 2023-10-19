import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_x_and_o/model/card.dart';
import 'package:my_x_and_o/providers/o_player_provider.dart';
import 'package:my_x_and_o/providers/sound.dart';
import 'package:my_x_and_o/providers/x_player_provider.dart';

class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({
    super.key,
    required this.changePage,
  });

  final void Function(BuildContext context, String value, List cards)
      changePage;

  @override
  ConsumerState<SetupScreen> createState() {
    return _SetupScreenState();
  }
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  bool tapped = true;
  bool useCards = false;
  List<Widget> cardsDisplayList = [];
  List originalCards = [];
  String value = "X";
  List<int> cards = [];
  final db = FirebaseFirestore.instance;

  @override
  void initState() {
    final blockCard = BlockCardBig(onApply: () {
      addingCards(0);
    });
    final nullifyCard = NullifyCardBig(onApply: () {
      addingCards(1);
    });
    final randomSwapCard = RandomSwapCardBig(onApply: () {
      addingCards(2);
    });
    final swapCard = SwapCardBig(onApply: () {
      addingCards(3);
    });
    originalCards = [blockCard, nullifyCard, randomSwapCard, swapCard];
    cardsDisplayList = [
      blockCard,
      nullifyCard,
      randomSwapCard,
      swapCard,
    ];

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

  void addingCards(int value) {
    setState(() {
      if (cards.contains(value)) {
        cards.remove(value);
        cardsDisplayList[value] = originalCards[value];
      } else if (cards.length < 2) {
        cards.add(value);
        cardsDisplayList[value] = Column(
          mainAxisSize: MainAxisSize.min,
          children: [const Icon(Icons.check), originalCards[value]],
        );
      } else {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("You can't selct more than 2 cards")));
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

  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        MediaQuery.platformBrightnessOf(context) == Brightness.dark;
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
                              height: 100,
                              width: 100,
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
                              height: 100,
                              width: 100,
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
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Text("Use Cards"),
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
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text("Select cards from here"),
                        ),
                        SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: cardsDisplayList,
                            )),
                      ],
                    ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.changePage(context, value, cards);
                    },
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
              ))
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
                                  height: 100,
                                  width: 100,
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
                                  height: 100,
                                  width: 100,
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
                          const Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Text("Use Cards"),
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
                        onPressed: () {
                          Navigator.of(context).pop();
                          widget.changePage(context, value, cards);
                        },
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
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text("Select cards from here"),
                              ),
                              SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: cardsDisplayList,
                                  )),
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
