import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_x_and_o/providers/o_player_provider.dart';
import 'package:my_x_and_o/providers/sound.dart';
import 'package:my_x_and_o/providers/x_player_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_x_and_o/widgets/container.dart';
import 'package:my_x_and_o/widgets/player.dart';
import 'package:flutter/material.dart';

enum IncrementPattern { horizontal, vertical, leadingDiagonal, secondDiagonal }

Random randomNumber = Random();

class OnlinePlay extends ConsumerStatefulWidget {
  const OnlinePlay({super.key, required this.value, required this.cards});

  final String value;
  final List cards;

  @override
  ConsumerState<OnlinePlay> createState() {
    return _GameScreenState();
  }
}

class _GameScreenState extends ConsumerState<OnlinePlay> {
  late Player xPlayer;
  late Player oPlayer;
  late String value;
  late String myValue;
  late List cards;
  final db = FirebaseFirestore.instance;
  final player = AudioPlayer();

  List<ContainerBox> containerList = [];
  List<int> xPositions = [];
  List<int> oPositions = [];
  int xScore = 0;
  int oScore = 0;
  String? decision;
  bool buildValue = false;

  bool check(int position, List<int> positions, IncrementPattern pattern) {
    int incrementValue;
    if (pattern == IncrementPattern.horizontal) {
      incrementValue = 1;
    } else if (pattern == IncrementPattern.vertical) {
      incrementValue = 3;
    } else if (pattern == IncrementPattern.leadingDiagonal) {
      incrementValue = 4;
    } else {
      incrementValue = 2;
    }
    if (positions.contains(position + incrementValue)) {
      if (positions.contains(position + (incrementValue * 2))) {
        return true;
      }
    }
    return false;
  }

  bool winner(List<int> positions) {
    if (positions.length < 3) {
      return false;
    }
    positions.sort();
    for (final position in positions.sublist(0, positions.length - 2)) {
      if (position == 1) {
        if (check(position, positions, IncrementPattern.horizontal)) {
          return true;
        }
        if (check(position, positions, IncrementPattern.vertical)) {
          return true;
        }
        if (check(position, positions, IncrementPattern.leadingDiagonal)) {
          return true;
        }
      }
      if (position == 2) {
        if (check(position, positions, IncrementPattern.vertical)) {
          return true;
        }
      }
      if (position == 3) {
        if (check(position, positions, IncrementPattern.vertical)) {
          return true;
        }
        if (check(position, positions, IncrementPattern.secondDiagonal)) {
          return true;
        }
      }
      if (position == 4) {
        if (check(position, positions, IncrementPattern.horizontal)) {
          return true;
        }
      }
      if (position == 7) {
        if (check(position, positions, IncrementPattern.horizontal)) {
          return true;
        }
      }
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    xPlayer = ref.read(xPlayerProvider);
    oPlayer = ref.read(oPlayerProvider);
    for (int i = 1; i < 10; i++) {
      containerList.add(
          ContainerBox(onClicked: onClicked, position: i, player: Player()));
    }
    value = widget.value;
    myValue = widget.value;
    cards = widget.cards;
  }

  void onClicked(int position) async {
    clickButton(() {});
    containerList[position - 1]
        .displayClicked(value == "X" ? xPlayer : oPlayer);
    if (value == 'X') {
      xPositions.add(position);
      if (winner(xPositions)) {
        setState(() {
          value = 'O';
          decision = myValue == "X" ? "You win" : "Computer wins";
          xScore++;
          popUp(false);
        });
        return;
      }
      setState(() {
        value = 'O';
      });
      return;
    }
    oPositions.add(position);
    if (winner(oPositions)) {
      setState(() {
        value = 'X';
        decision = myValue == "O" ? "You win" : "Computer wins";
        oScore++;
        popUp(false);
      });
      return;
    }
    setState(() {
      value = 'X';
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

  void restartGame() {
    buttonSound(() {
      Navigator.of(context).pop();
      setState(() {
        for (final items in containerList) {
          items.resetScreen();
        }
      });
    });
    oPositions = [];
    xPositions = [];
    decision = null;
  }

  void quitGame() {
    buttonSound(() {
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    });
  }

  void popUp(bool isDismissible) {
    showDialog(
        barrierDismissible: isDismissible,
        context: context,
        builder: (ctx) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      restartGame();
                      xScore = 0;
                      oScore = 0;
                    });
                  },
                  label: const Text('Restart'),
                  icon: const Icon(Icons.restart_alt),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      restartGame();
                    });
                  },
                  label: const Text('Rematch'),
                  icon: const Icon(Icons.redo_rounded),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextButton.icon(
                  onPressed: quitGame,
                  label: const Text('Quit'),
                  icon: const Icon(
                    Icons.cancel,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    double width = MediaQuery.of(context).size.width - 40;

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
          title: const Row(
            children: [
              Text(
                'My ',
                style: TextStyle(
                  color: Color.fromARGB(255, 223, 214, 224),
                ),
              ),
              Text(
                'X ',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
              Text(
                'and ',
                style: TextStyle(
                  color: Color.fromARGB(255, 223, 214, 224),
                ),
              ),
              Text(
                'O',
                style: TextStyle(
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () {
                buttonSound(() {
                  popUp(true);
                });
              },
              icon: const Icon(
                Icons.pause,
              ),
            )
          ],
        ),
        body: StreamBuilder(
          stream: db.collection("username").snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 40,
                          ),
                          child: ((oScore + xScore) > 0)
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      '$xScore',
                                      style: TextStyle(
                                          fontSize: width / 6,
                                          color: xPlayer.color,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      ':',
                                      style: TextStyle(
                                          fontSize: width / 8,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary),
                                    ),
                                    Text(
                                      '$oScore',
                                      style: TextStyle(
                                          fontSize: width / 6,
                                          color: oPlayer.color,
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                )
                              : null),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      width: double.infinity,
                      child: Stack(
                        children: [
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: containerList.sublist(0, 3),
                              ),
                              const Divider(
                                thickness: 10,
                                color: Colors.black,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: containerList.sublist(3, 6),
                              ),
                              const Divider(
                                thickness: 10,
                                color: Colors.black,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: containerList.sublist(6, 9),
                              ),
                            ],
                          ),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              VerticalDivider(
                                thickness: 10,
                                color: Colors.black,
                              ),
                              VerticalDivider(
                                thickness: 10,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 30,
                      ),
                      child: Text(
                        oPositions.length + xPositions.length != 9
                            ? decision ??
                                (myValue == value
                                    ? "Your turn"
                                    : "Computer Turn")
                            : decision ?? "DRAW",
                        style: TextStyle(
                            fontSize: width / 7,
                            color: Theme.of(context).colorScheme.onBackground),
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
              );
            }
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  color: Theme.of(context).colorScheme.tertiary,
                  width: double.infinity,
                  height: 150,
                  child: Center(child: Text("Waiting for user")),
                ),
              ),
            );
          },
        ));
  }
}
