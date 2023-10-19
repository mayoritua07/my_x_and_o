import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:my_x_and_o/model/card.dart';
import 'package:my_x_and_o/providers/o_player_provider.dart';
import 'package:my_x_and_o/providers/sound.dart';
import 'package:my_x_and_o/providers/x_player_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_x_and_o/widgets/container.dart';
import 'package:my_x_and_o/widgets/player.dart';
import 'package:flutter/material.dart';
import 'package:my_x_and_o/main.dart';

enum IncrementPattern { horizontal, vertical, leadingDiagonal, secondDiagonal }

Random randomizer = Random();

class SinglePlayer extends ConsumerStatefulWidget {
  const SinglePlayer({super.key, required this.value, required this.cards});

  final String value;
  final List cards;

  @override
  ConsumerState<SinglePlayer> createState() {
    return _GameScreenState();
  }
}

class _GameScreenState extends ConsumerState<SinglePlayer> {
  late Player xPlayer;
  late Player oPlayer;
  late String value;
  late String myValue;
  late String compValue;
  List<ContainerBox> containerList = [];
  List<int> xPositions = [];
  List<int> oPositions = [];
  int xScore = 0;
  int oScore = 0;
  int tap = 0;
  bool computerPlayed = true;
  bool userPlayed = false;
  String? decision;
  final winningSound = "audio/win_sound.mp3";
  final losingSound = "audio/lose_sound.mp3";
  bool userApplyingCard = false;
  bool getPosition = false;
  String? feedback;
  List<int> myCardPosition = [];
  List<int> computerCardPosition = [];
  Widget? userActiveCard;
  Widget? computerActiveCard;
  late Widget blockCard;
  late Widget nullifyCard;
  late Widget swapCard;
  late Widget randomSwapCard;
  List<Widget> cardListDisplay = [];

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
          ContainerBox(onClicked: userPlay, position: i, player: Player()));
    }
    value = widget.value;
    compValue = value == "X" ? "O" : "X";
    myValue = widget.value;
    blockCard = BlockCard(onApply: onBlockCard);
    nullifyCard = NullifyCard(onApply: onNullifyCard);
    swapCard = SwapCard(onApply: onSwapCard);
    randomSwapCard = RandomSwapCard(onApply: onRandomSwapCard);
    final possibleCardList = [
      blockCard,
      nullifyCard,
      randomSwapCard,
      swapCard,
    ];
    for (final item in widget.cards) {
      cardListDisplay.add(possibleCardList[item]);
    }
  }

  void endingSound(String sound, void Function() nextPage) async {
    if (ref.read(soundEffectProvider)) {
      final player = AudioPlayer();
      await player.setSource(AssetSource(sound));
      await player.resume();
      Timer(const Duration(seconds: 2, milliseconds: 500), () async {
        await player.stop();
      });
    }

    Timer(const Duration(milliseconds: 300), () {
      nextPage();
    });
  }

  bool spaceUsedUp() {
    return (xPositions.length + oPositions.length) == 9;
  }

  bool selectedTileUsedUp(pos) {
    if (oPositions.contains(pos) || xPositions.contains(pos)) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tile has already been allocated")));
    }

    return oPositions.contains(pos) || xPositions.contains(pos);
  }

  void userPlay(int pos) {
    if (computerActiveCard != null && !userApplyingCard && feedback == null) {
      if (computerActiveCard == blockCard) {
        if (computerCardPosition.contains(pos)) {
          setState(() {
            containerList[pos - 1].resetScreen();
            computerActiveCard = null;
            computerCardPosition = [];
            feedback = "You have been Blocked!";
            Timer(const Duration(milliseconds: 1000), () {
              setState(() {
                feedback = null;
              });
            });
          });
          userPlayed = !userPlayed;
          computerPlayed = !computerPlayed;
          value = compValue;
          computerPlay();
          return;
        }
      } else if (computerActiveCard == swapCard) {
        if (computerCardPosition.contains(pos)) {
          containerList[pos - 1].resetScreen();
          computerCardPosition.remove(pos);
          pos = computerCardPosition[0];
          setState(() {
            containerList[pos - 1].resetScreen();
            feedback = "Your tile has been swapped!";
            Timer(const Duration(milliseconds: 1000), () {
              setState(() {
                feedback = null;
              });
            });
          });
        }
      }
      setState(() {
        computerActiveCard = null;
        computerCardPosition = [];
      });
    } else if (userPlayed || userActiveCard == null) {
      if (selectedTileUsedUp(pos)) {
        containerList[pos - 1].resetScreen();
        return;
      }
    } else if (getPosition) {
      myCardPosition.add(pos);
      containerList[pos - 1].resetScreen();
      containerList[pos - 1].activePowerup();
      getPosition = false;
      setState(() {
        feedback = null;
      });
      if (userActiveCard == swapCard && myCardPosition.length == 1) {
        userApplyingCard = false;
        setState(() {
          getPosition = true;
          feedback = "Choose your location";
        });
      }

      return;
    }

    onClicked(pos);
  }

  void onClicked(int position) async {
    tap++;
    userApplyingCard = false;
    clickButton(() {});
    containerList[position - 1]
        .displayClicked(value == "X" ? xPlayer : oPlayer);
    userPlayed = !userPlayed;
    computerPlayed = !computerPlayed;
    if (value == 'X') {
      xPositions.add(position);
      if (winner(xPositions)) {
        decision = myValue == "X" ? "You win" : "You lose";
        xScore++;
        endingSound(myValue == "X" ? winningSound : losingSound, () {
          setState(() {
            value = 'O';
            popUp(false);
          });
        });

        return;
      }
      setState(() {
        value = 'O';
        computerPlay();
      });
    } else {
      oPositions.add(position);
      if (winner(oPositions)) {
        value = 'X';
        decision = myValue == "O" ? "You win" : "You lose";
        endingSound(myValue == "O" ? winningSound : losingSound, () {
          oScore++;
          setState(() {
            popUp(false);
          });
        });

        return;
      }
      setState(() {
        value = 'X';
        computerPlay();
      });
    }

    if (spaceUsedUp()) {
      setState(() {
        decision = "Draw";
        popUp(false);
      });
    }
  }

  int generateRandomPosition() {
    int randomValue = randomizer.nextInt(8) + 1;
    if (oPositions.contains(randomValue) ||
        xPositions.contains(randomValue) ||
        computerCardPosition.contains(randomValue)) {
      return generateRandomPosition();
    }
    return randomValue;
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

  void nullifyPowerupSound() async {
    final player = AudioPlayer();
    if (ref.read(soundEffectProvider)) {
      await player.setSource(AssetSource("audio/nullify_sound.mp3"));
      // await player.seek(const Duration(seconds: 3));
      await player.resume();
    }

    // Timer(const Duration(seconds: 3), () async {
    //   await player.release();
    // });
  }

  void computerPlay() {
    if (computerPlayed) {
      return;
    }
    if (tap < 4) {
      if (randomizer.nextBool()) {
        int num = 2;
        if (userActiveCard != null) {
          num = 3;
        }
        int choice = randomizer.nextInt(num);
        // Block is 0, swap is 1, nullify is 2
        if (choice == 0) {
          setState(() {
            computerActiveCard = blockCard;
            computerCardPosition.add(generateRandomPosition());
          });
        }
        if (choice == 1) {
          setState(() {
            computerActiveCard = swapCard;
            computerCardPosition.add(generateRandomPosition());
            computerCardPosition.add(generateRandomPosition());
          });
        }

        if (choice == 2) {
          setState(() {
            computerActiveCard = nullifyCard;
            if (userActiveCard != null) {
              feedback = "Your card was nullified!";
              containerList[myCardPosition[0] - 1].resetScreen();
            }
            userActiveCard = null;
            myCardPosition = [];

            Timer(const Duration(seconds: 1), () {
              setState(() {
                feedback = null;
                computerActiveCard = null;
              });
            });
          });
        }
      }
    }
    int randomValue = generateRandomPosition();

    if (userActiveCard != null) {
      if (userActiveCard == blockCard) {
        if (myCardPosition.contains(randomValue)) {
          setState(() {
            value = myValue;
            userPlayed = !userPlayed;
            computerPlayed = !computerPlayed;
            userActiveCard = null;
            powerupWorked();
            feedback = "Blocked!";
            for (final item in myCardPosition) {
              containerList[item - 1].resetScreen();
            }
            myCardPosition = [];
            Timer(const Duration(milliseconds: 1000), () {
              setState(() {
                feedback = null;
              });
            });
          });

          return;
        }
      } else if (userActiveCard == swapCard ||
          userActiveCard == randomSwapCard) {
        if (myCardPosition[0] == randomValue) {
          powerupWorked();
          randomValue = userActiveCard == swapCard
              ? myCardPosition[1]
              : generateRandomPosition();
          setState(() {
            feedback = "Swapped!";
            Timer(const Duration(milliseconds: 1000), () {
              setState(() {
                feedback = null;
              });
            });
          });
        }
      }

      setState(() {
        userActiveCard = null;
        for (final item in myCardPosition) {
          containerList[item - 1].resetScreen();
        }
        myCardPosition = [];
      });
    }

    Timer(Duration(milliseconds: randomizer.nextInt(200) + 200), () {
      setState(() {
        onClicked(randomValue);
        containerList[randomValue - 1].tapped = true;
      });
    });
  }

  void powerupWorked() async {
    if (ref.read(soundEffectProvider)) {
      final player = AudioPlayer();
      await player.setSource(AssetSource("audio/powerup.mp3"));
      await player.resume();
    }
  }

  void restartGame() {
    buttonSound(() {
      Navigator.of(context).pop();
      setState(() {
        for (final items in containerList) {
          items.resetScreen();
        }
      });
      oPositions = [];
      tap = 0;
      xPositions = [];
      decision = null;
      computerPlay();
    });
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
            child: StatefulBuilder(
              builder: (context, setState) => AlertDialog(
                title: Center(
                  child: Text(
                    decision ?? "Pause Menu",
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
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
                      height: 12,
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
                      height: 12,
                    ),
                    TextButton.icon(
                      onPressed: quitGame,
                      label: const Text('Quit'),
                      icon: const Icon(
                        Icons.cancel,
                        color: Colors.red,
                      ),
                    ),
                    if (isDismissible)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(ref.read(soundTrackProvider)
                                    ? Icons.music_note
                                    : Icons.music_off),
                                onPressed: () {
                                  setState(() {
                                    ref
                                        .read(soundTrackProvider.notifier)
                                        .toggleSoundTrack();
                                  });
                                  clickButton(() {});
                                },
                              ),
                              const Text("Sound Track")
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(ref.read(soundEffectProvider)
                                    ? Icons.volume_up
                                    : Icons.volume_off),
                                onPressed: () {
                                  setState(() {
                                    ref
                                        .read(soundEffectProvider.notifier)
                                        .toggleSoundEffect();
                                  });
                                  clickButton(() {});
                                },
                              ),
                              const Text("Sound Effects")
                            ],
                          )
                        ],
                      )
                  ],
                ),
              ),
            ),
          );
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

  void onBackCardTap() {
    if (tap > 3) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Can no longer activate cards")),
      );
      return;
    }
    if (userActiveCard != null) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("A card has been used")),
      );
      return;
    }
    setState(() {
      userApplyingCard = true;
    });
  }

  void onBlockCard() {
    setState(() {
      feedback = "Guess Opponent next position";
      getPosition = true;
      userApplyingCard = false;
      userActiveCard = blockCard;
    });
  }

  void onSwapCard() {
    setState(() {
      feedback = "Guess Opponent next position";
      getPosition = true;
      userActiveCard = swapCard;
    });
  }

  void onRandomSwapCard() {
    setState(() {
      feedback = "Guess Opponent next position";
      getPosition = true;
      userActiveCard = randomSwapCard;
      userApplyingCard = false;
    });
  }

  void onNullifyCard() {
    userActiveCard = nullifyCard;
    nullifyPowerupSound();
    setState(() {
      feedback = "Nullified!";
      Timer(const Duration(milliseconds: 1000), () {
        setState(() {
          feedback = null;
        });
      });
      computerCardPosition = [];
      computerActiveCard = null;
      userApplyingCard = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = ref.read(darkModeProvider);
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
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
                            if (computerActiveCard != null) const CardBack(),
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
                  SizedBox(height: height / 15),
                  Container(
                    height: width * 0.85,
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
                  const SizedBox(height: 30),
                  if (feedback != null)
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        feedback!,
                        style: const TextStyle(fontSize: 17),
                      ),
                    ),
                  SizedBox(
                    child: Column(
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              if (!userApplyingCard)
                                InkWell(
                                    onTap: onBackCardTap,
                                    child: const CardBack()),
                              if (userApplyingCard) ...cardListDisplay,
                              if (userApplyingCard)
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      userApplyingCard = false;
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.red,
                                  ),
                                )
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
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
                            const SizedBox(width: 10),
                            if (computerActiveCard != null) const CardBack(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (feedback != null)
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            feedback!,
                            style: const TextStyle(fontSize: 17),
                          ),
                        ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: width / 2,
                        // color: Colors.black54,
                        child: Column(
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Expanded(
                                child: Row(
                                  children: [
                                    if (!userApplyingCard)
                                      InkWell(
                                        onTap: onBackCardTap,
                                        child: const CardBack(),
                                      ),
                                    if (userApplyingCard) ...cardListDisplay,
                                  ],
                                ),
                              ),
                            ),
                            if (userApplyingCard)
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    userApplyingCard = false;
                                  });
                                },
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.red,
                                ),
                              )
                          ],
                        ),
                      )
                    ],
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
