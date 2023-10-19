import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:my_x_and_o/providers/o_player_provider.dart';
import 'package:my_x_and_o/providers/sound.dart';
import 'package:my_x_and_o/providers/x_player_provider.dart';

import 'package:my_x_and_o/widgets/container.dart';
import 'package:my_x_and_o/widgets/player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_x_and_o/main.dart';

enum IncrementPattern { horizontal, vertical, leadingDiagonal, secondDiagonal }

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() {
    return _GameScreenState();
  }
}

class _GameScreenState extends ConsumerState<GameScreen> {
  late Player xPlayer;
  late Player oPlayer;
  String value = 'X';

  List<ContainerBox> containerList = [];
  List<int> xPositions = [];
  List<int> oPositions = [];
  int xScore = 0;
  int oScore = 0;
  String? decision;

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
  }

  void onClicked(int position) async {
    clickButton(() {});
    containerList[position - 1]
        .displayClicked(value == "X" ? xPlayer : oPlayer);
    if (value == 'X') {
      xPositions.add(position);
      if (winner(xPositions)) {
        winningSound(() {
          setState(() {
            decision = 'X wins';
            xScore++;
            popUp(false);
            value = 'O';
          });
        });
        return;
      }

      setState(() {
        value = 'O';
      });
    } else {
      oPositions.add(position);
      if (winner(oPositions)) {
        winningSound(() {
          setState(() {
            decision = 'O wins';
            oScore++;
            popUp(false);
            value = 'X';
          });
        });
        return;
      }
      setState(() {
        value = 'X';
      });
    }
    if (xPositions.length + oPositions.length == 9) {
      setState(() {
        decision == "Draw";
        popUp(false);
      });
    }
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

  void winningSound(void Function() nextPage) async {
    if (ref.read(soundEffectProvider)) {
      final player = AudioPlayer();
      await player.setSource(AssetSource("audio/win_sound.mp3"));
      await player.resume();
      Timer(const Duration(seconds: 2), () async {
        await player.stop();
      });
    }

    Timer(const Duration(milliseconds: 300), () {
      nextPage();
    });
  }

  void restartGame() {
    buttonSound(() {
      setState(() {
        Navigator.of(context).pop();
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
          return WillPopScope(
            onWillPop: () => Future(() => isDismissible),
            child: AlertDialog(
              title: Center(child: Text(decision ?? "Pause Menu")),
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
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = ref.read(darkModeProvider);

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    bool isLandscape = width > 650;

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
      body: SingleChildScrollView(
        child: !isLandscape
            ? Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 30),
                              decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.tertiary,
                                  borderRadius: BorderRadius.circular(15)),
                              child: Row(
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
                                  const SizedBox(width: 20),
                                  Text(
                                    ':',
                                    style: TextStyle(
                                        fontSize: width / 8,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary),
                                  ),
                                  const SizedBox(width: 20),
                                  Text(
                                    '$oScore',
                                    style: TextStyle(
                                        fontSize: width / 6,
                                        color: oPlayer.color,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            ref
                                .read(value == "X"
                                    ? xPlayerProvider
                                    : oPlayerProvider)
                                .nextPlayerImage,
                          ],
                        )),
                  ),
                  SizedBox(
                    height: height / 10,
                  ),
                  Container(
                    height: width * 0.9,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    width: double.infinity,
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: containerList.sublist(0, 3),
                            ),
                            const Divider(
                              thickness: 7,
                              color: Colors.black,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: containerList.sublist(3, 6),
                            ),
                            const Divider(
                              thickness: 7,
                              color: Colors.black,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: containerList.sublist(6, 9),
                            ),
                          ],
                        ),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            VerticalDivider(
                              thickness: 7,
                              color: Colors.black,
                            ),
                            VerticalDivider(
                              thickness: 7,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ref
                            .read(value == "X"
                                ? xPlayerProvider
                                : oPlayerProvider)
                            .nextPlayerImage,
                        const SizedBox(
                          width: 15,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 30),
                          decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.tertiary,
                              borderRadius: BorderRadius.circular(15)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '$xScore',
                                style: TextStyle(
                                    fontSize: height / 6,
                                    color: xPlayer.color,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 20),
                              Text(
                                ':',
                                style: TextStyle(
                                    fontSize: height / 6,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary),
                              ),
                              const SizedBox(width: 20),
                              Text(
                                '$oScore',
                                style: TextStyle(
                                    fontSize: height / 6,
                                    color: oPlayer.color,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: height * 0.8,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                    ),
                    width: height * 0.85,
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: containerList.sublist(0, 3),
                            ),
                            const Divider(
                              thickness: 7,
                              color: Colors.black,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: containerList.sublist(3, 6),
                            ),
                            const Divider(
                              thickness: 7,
                              color: Colors.black,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: containerList.sublist(6, 9),
                            ),
                          ],
                        ),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            VerticalDivider(
                              thickness: 7,
                              color: Colors.black,
                            ),
                            VerticalDivider(
                              thickness: 7,
                              color: Colors.black,
                            ),
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
