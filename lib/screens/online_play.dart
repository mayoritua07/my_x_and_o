import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_x_and_o/providers/cards_provider.dart';
import 'package:my_x_and_o/screens/shop.dart';
import 'package:my_x_and_o/widgets/code_input.dart';
import 'package:my_x_and_o/widgets/info_page.dart';
import 'package:my_x_and_o/widgets/snackbar.dart';
import 'package:vibration/vibration.dart';
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

String username = "Mayoritua07";

final randomizer = Random();

final kCardsList = [Cards.block, Cards.nullify, Cards.randomSwap, Cards.swap];

class OnlinePlay extends ConsumerStatefulWidget {
  OnlinePlay.host(
      {super.key,
      required this.value,
      required this.cards,
      required this.useCards,
      this.isHosting = true});
  OnlinePlay.join(
      {super.key,
      required this.value,
      this.useCards = false,
      required this.cards,
      this.isHosting = false});

  final bool isHosting;
  final String value;
  List<Enum> cards;
  final bool useCards;

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
  late String opponentValue;
  late bool isDarkMode;
  late bool useCards;
  List<ContainerBox> containerList = [];
  List<int> xPositions = [];
  List<int> oPositions = [];
  int xScore = 0;
  int oScore = 0;
  int tap = 0;
  String? decision;
  bool isConnected = false;
  final winningSound = "audio/win_sound.mp3";
  final losingSound = "audio/lose_sound.mp3";
  bool userApplyingCard = false;
  bool getPosition = false;
  String? feedback;
  List myCardPosition = [];
  List opponentCardPosition = [];
  Cards? myActiveCard;
  Cards? opponentActiveCard;
  Map<String, dynamic> messageDetails = {};
  late Widget blockCard;
  late Widget nullifyCard;
  late Widget swapCard;
  late Widget randomSwapCard;
  List<int> winningPositions = [];
  Map<Enum, Widget> cardListDisplay = {};
  late AudioPlayer player;
  late String matchCode;
  late Map<Enum, Widget> possibleCardList = {};
  final db = FirebaseFirestore.instance;
  late Widget joinWidget;
  int roundNumber = 1;

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
          winningPositions = [1, 2, 3];
          return true;
        }
        if (check(position, positions, IncrementPattern.vertical)) {
          winningPositions = [1, 4, 7];
          return true;
        }
        if (check(position, positions, IncrementPattern.leadingDiagonal)) {
          winningPositions = [1, 5, 9];
          return true;
        }
      }
      if (position == 2) {
        if (check(position, positions, IncrementPattern.vertical)) {
          winningPositions = [2, 5, 8];
          return true;
        }
      }
      if (position == 3) {
        if (check(position, positions, IncrementPattern.vertical)) {
          winningPositions = [3, 6, 9];
          return true;
        }
        if (check(position, positions, IncrementPattern.secondDiagonal)) {
          winningPositions = [3, 5, 7];
          return true;
        }
      }
      if (position == 4) {
        if (check(position, positions, IncrementPattern.horizontal)) {
          winningPositions = [4, 5, 6];
          return true;
        }
      }
      if (position == 7) {
        if (check(position, positions, IncrementPattern.horizontal)) {
          winningPositions = [7, 8, 9];
          return true;
        }
      }
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    useCards = widget.useCards;
    joinWidget = InputCode(onPressed: checkCode);
    player = AudioPlayer();
    isDarkMode = ref.read(darkModeProvider);
    xPlayer = ref.read(xPlayerProvider);
    oPlayer = ref.read(oPlayerProvider);
    for (int i = 1; i < 10; i++) {
      containerList.add(
          ContainerBox(onClicked: userPlay, position: i, player: Player()));
    }

    value = widget.value;
    opponentValue = value == "X" ? "O" : "X";
    myValue = widget.value;
    blockCard = BlockCard(onApply: onBlockCard);
    nullifyCard = NullifyCard(onApply: onNullifyCard);
    swapCard = SwapCard(onApply: onSwapCard);
    randomSwapCard = RandomSwapCard(onApply: onRandomSwapCard);
    possibleCardList = {
      Cards.block: blockCard,
      Cards.nullify: nullifyCard,
      Cards.randomSwap: randomSwapCard,
      Cards.swap: swapCard,
    };

    for (final item in widget.cards) {
      cardListDisplay.addAll({item: possibleCardList[item]!});
    }
    if (widget.isHosting) {
      matchCode = username;
      hostSetup();
    }
  }

  @override
  void dispose() {
    if (widget.isHosting) {
      db.collection(matchCode).doc(matchCode).set({"endGame": true});
    }
    super.dispose();
  }

  void hostSetup() {
    db.collection(matchCode).doc(matchCode).set({
      "value": myValue,
      "cards": useCards,
      "endGame": false,
    });
  }

  void checkCode(String code) {
    if (code == '') {
      // print("code can not be null");
      return;
    }
    matchCode = code;
    db.collection(matchCode).doc(code).get().then((document) {
      final data = document.data();
      if (data != null) {
        if (data["endGame"]) {
          return;
          // Room is not available
        }
        value = data['value'];
        useCards = data["cards"];
        opponentValue = value;
        myValue = value == "X" ? "O" : "X";
        setState(() {
          joinWidget = InfoPage(
            onPressed: beginMatch,
            useCards: useCards,
            value: myValue,
          );
        });
      } else {
        // print("Invalid code");
      }
    }, onError: (e) {
      "Problem retrieving data";
    }
        // Todo show scaffold,
        );

    // get data, pop text input and load info page
    // else scaffold messenger
  }

  void beginMatch(List<Enum> cards) async {
    widget.cards = cards;
    await db
        .collection(matchCode)
        .doc(matchCode)
        .set({"isConnected": true, "endGame": false, "value": myValue});
    // send info to start
    setState(() {
      for (final item in widget.cards) {
        cardListDisplay.addAll({item: possibleCardList[item]!});
      }
      isConnected = true;
    });
    // doing cards and value
  }

  void endingSound(String sound, void Function() nextPage) async {
    if (ref.read(soundEffectProvider)) {
      player = AudioPlayer();
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
    if (value != myValue) {
      containerList[pos - 1].resetScreen();
      return;
    }
    if (selectedTileUsedUp(pos)) {
      return;
    }
    if (opponentActiveCard != null && !userApplyingCard && feedback == null) {
      if (opponentActiveCard == Cards.block) {
        if (opponentCardPosition.contains(pos)) {
          setState(() {
            containerList[pos - 1].resetScreen();
            opponentActiveCard = null;
            opponentCardPosition = [];
            Vibration.vibrate();
            feedback = "You have been Blocked!";
            messageDetails.addAll({
              "feedback": "Blocked!",
            });

            Timer(const Duration(milliseconds: 1000), () {
              setState(() {
                feedback = null;
              });
            });
          });
          value = opponentValue;
          tap++;
          sendMessage(0);

          return;
        }
      } else if (opponentActiveCard == Cards.swap) {
        if (opponentCardPosition[0] == pos) {
          containerList[pos - 1].resetScreen();
          pos = opponentCardPosition[1];
          setState(() {
            containerList[pos - 1].resetScreen();
            Vibration.vibrate();
            feedback = "Your tile has been swapped!";
            messageDetails.addAll({
              "feedback": "Swapped!",
            });
            Timer(const Duration(milliseconds: 1000), () {
              setState(() {
                feedback = null;
              });
            });
          });
        }
      } else if (opponentActiveCard == Cards.randomSwap) {
        if (opponentCardPosition[0] == pos) {
          containerList[pos - 1].resetScreen();
          pos = generateRandomPosition();
          setState(() {
            Vibration.vibrate();
            feedback = "Your tile has been swapped!";
            messageDetails.addAll({
              "feedback": "Swapped!",
            });
            Timer(const Duration(milliseconds: 1000), () {
              setState(() {
                feedback = null;
              });
            });
          });
        }
      }
      setState(() {
        opponentActiveCard = null;
        opponentCardPosition = [];
      });
    } else if (getPosition) {
      myCardPosition.add(pos);
      containerList[pos - 1].resetScreen();
      containerList[pos - 1].activePowerup();
      getPosition = false;
      setState(() {
        feedback = null;
      });
      if (myActiveCard == Cards.swap && myCardPosition.length == 1) {
        userApplyingCard = false;
        setState(() {
          getPosition = true;
          feedback = "Choose your location";
        });
      }
      return;
    }

    onClicked(pos);
    sendMessage(pos);
  }

  void intepreteMessage(Map<String, dynamic> message) {
    db.collection(matchCode).doc(matchCode).get().then((document) {
      final info = document.data()!;
      if (info["isConnected"] != null) {
        setState(() {
          isConnected = true;
        });
        return;
      }

      if (info["endGame"] == true) {
        Navigator.of(context).pop();
        return;
      }

      if (value == myValue || info["value"] == opponentValue) {
        return;
      }

      for (final pos in myCardPosition) {
        containerList[pos - 1].resetScreen();
      }
      // print("I reached here");
      myCardPosition = [];

      if (info["activeCard"] != null) {
        setState(() {
          tap = info["tap"] ?? 0;
          opponentActiveCard = kCardsList[info["activeCard"]];
        });
      }

      setState(() {
        opponentCardPosition = info["cardPosition"] ?? [];
        feedback = info["feedback"] as String?;
        Timer(const Duration(seconds: 1), () {
          setState(() {
            feedback = null;
          });
        });
        final position = info["position"];
        if (position != null && position != 0) {
          final hasWinner = onClicked(position);
          if (hasWinner == 'winner') {
            db.collection(matchCode).doc(matchCode).set({});
          }
        }
      });
      if (info["value"] != null) {
        value = info["value"];
      }
    }, onError: (e) {
      "Issue with network";
    });
  }

  void sendMessage(pos) {
    messageDetails.addAll({
      "tap": tap,
      "position": pos,
      "cardPosition": myCardPosition,
      "value": opponentValue,
      "endGame": false
    });
    // add feedback to message details
    db.collection(matchCode).doc(matchCode).set(messageDetails);
    messageDetails = {};
    value = opponentValue;
    myActiveCard = null;
    opponentActiveCard = null;
  }

  String onClicked(int position) {
    if (decision != null ||
        xPositions.contains(position) ||
        oPositions.contains(position)) {
      return '';
    }

    tap++;
    userApplyingCard = false;
    clickButton(() {});
    containerList[position - 1]
        .displayClicked(value == "X" ? xPlayer : oPlayer);

    if (value == 'X') {
      xPositions.add(position);
      if (winner(xPositions)) {
        containerList[winningPositions[0] - 1].animateWinner();
        Timer(const Duration(milliseconds: 300), () {
          containerList[winningPositions[1] - 1].animateWinner();
        });
        Timer(const Duration(milliseconds: 600), () {
          containerList[winningPositions[2] - 1].animateWinner();
        });

        Timer(const Duration(milliseconds: 700), () {
          popUp(false);
        });
        decision = myValue == "X" ? "You win" : "You lose";
        xScore++;
        endingSound(myValue == "X" ? winningSound : losingSound, () {});
        Timer(const Duration(seconds: 2), () {
          Navigator.of(context).pop();
          restartGame();
        });
        return 'winner';
      }
    } else {
      oPositions.add(position);
      if (winner(oPositions)) {
        containerList[winningPositions[0] - 1].animateWinner();
        Timer(const Duration(milliseconds: 300), () {
          containerList[winningPositions[1] - 1].animateWinner();
        });
        Timer(const Duration(milliseconds: 600), () {
          containerList[winningPositions[2] - 1].animateWinner();
        });

        Timer(const Duration(milliseconds: 700), () {
          popUp(false);
        });

        decision = myValue == "O" ? "You win" : "You lose";
        setState(() {});
        endingSound(myValue == "O" ? winningSound : losingSound, () {
          oScore++;
        });
        Timer(const Duration(seconds: 2), () {
          Navigator.of(context).pop();
          restartGame();
        });
        return 'winner';
      }
    }
    if (spaceUsedUp()) {
      setState(() {
        decision = "Draw";
        popUp(false);
        Timer(const Duration(seconds: 2), () {
          Navigator.of(context).pop();
          restartGame();
        });
      });
      return 'winner';
    }
    return '';
  }

  int generateRandomPosition() {
    int randomValue = randomizer.nextInt(9) + 1;
    if (oPositions.contains(randomValue) ||
        xPositions.contains(randomValue) ||
        opponentCardPosition.contains(randomValue)) {
      return generateRandomPosition();
    }
    return randomValue;
  }

  void clickButton(void Function() nextPage) async {
    if (ref.read(soundEffectProvider)) {
      player = AudioPlayer();
      await player.setSource(AssetSource("audio/click_button.mp3"));
      await player.resume();
    }

    Timer(const Duration(milliseconds: 200), () async {
      nextPage();
    });
  }

  void nullifyPowerupSound() async {
    player = AudioPlayer();
    if (ref.read(soundEffectProvider)) {
      await player.setSource(AssetSource("audio/nullify_sound.mp3"));
      // await player.seek(const Duration(seconds: 3));
      await player.resume();
    }

    // Timer(const Duration(seconds: 3), () async {
    //   await player.release();
    // });
  }

  void powerupWorked() async {
    if (ref.read(soundEffectProvider)) {
      player = AudioPlayer();
      await player.setSource(AssetSource("audio/powerup.mp3"));
      await player.resume();
    }
  }

  void restartGame() {
    buttonSound(() {
      player.stop();
      setState(() {
        for (final items in containerList) {
          items.resetScreen();
        }
        decision = null;
        oPositions = [];
        winningPositions = [];
        roundNumber += 1;
        tap = 0;
        xPositions = [];
      });
    });
  }

  void exitToLobby() {
    buttonSound(() {
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      player.stop();
    });
  }

  void popUp(bool isDismissible) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    bool isLandscape = width > 650;
    showDialog(
        barrierDismissible: isDismissible,
        context: context,
        builder: (ctx) {
          return WillPopScope(
            onWillPop: () => Future(() => isDismissible),
            child: StatefulBuilder(
              builder: (context, setState) => AlertDialog(
                title: Center(
                  child: Column(
                    children: [
                      Text(
                        "Round $roundNumber",
                        style: TextStyle(
                            fontSize: 18,
                            color: isDarkMode
                                ? null
                                : Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer),
                      ),
                      Text(
                        "matchType",
                        style: TextStyle(
                            fontSize: 10,
                            color: isDarkMode
                                ? null
                                : Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer),
                      ),
                    ],
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '$xScore',
                          style: TextStyle(
                              fontSize: !isLandscape ? width / 6 : height / 6,
                              color: xPlayer.color,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 20),
                        Text(
                          ':',
                          style: TextStyle(
                              fontSize: !isLandscape ? width / 8 : height / 6,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimary),
                        ),
                        const SizedBox(width: 20),
                        Text(
                          '$oScore',
                          style: TextStyle(
                              fontSize: !isLandscape ? width / 6 : height / 6,
                              color: oPlayer.color,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Text(decision ?? "Draw"),
                    Row(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (widget.isHosting && isDismissible)
                              TextButton.icon(
                                onPressed: exitToLobby,
                                label: const Text('Exit to lobby'),
                                icon: const Icon(
                                  Icons.exit_to_app,
                                  color: Colors.red,
                                ),
                              ),
                            const SizedBox(
                              height: 20,
                            ),
                            if (isDismissible)
                              TextButton.icon(
                                onPressed: () {
                                  exitToLobby();
                                  if (widget.isHosting) {
                                    Navigator.of(context).pop();
                                  }
                                },
                                label: const Text('Quit'),
                                icon: const Icon(
                                  Icons.cancel,
                                  color: Colors.red,
                                ),
                              ),
                          ],
                        ),
                        if (isDismissible)
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      ref.read(soundTrackProvider)
                                          ? Icons.music_note
                                          : Icons.music_off,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        ref
                                            .read(soundTrackProvider.notifier)
                                            .toggleSoundTrack();
                                      });
                                      clickButton(() {});
                                    },
                                  ),
                                  Text(
                                    "Sound Track",
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  )
                                ],
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      ref.read(soundEffectProvider)
                                          ? Icons.volume_up
                                          : Icons.volume_off,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        ref
                                            .read(soundEffectProvider.notifier)
                                            .toggleSoundEffect();
                                      });
                                      clickButton(() {});
                                    },
                                  ),
                                  Text(
                                    "Sound Effects",
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ],
                              )
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
      player = AudioPlayer();
      await player.setSource(AssetSource("audio/button_sound.mp3"));
      await player.resume();
    }

    Timer(const Duration(milliseconds: 200), () async {
      nextPage();
    });
  }

  void onBackCardTap() {
    if (tap > 3 || value != myValue) {
      // ScaffoldMessenger.of(context).clearSnackBars();
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text("Can no longer activate cards")),
      // );
      displayMySnackBar(context, "You can no longer activate cards");
      return;
    }
    if (myActiveCard != null) {
      // ScaffoldMessenger.of(context).clearSnackBars();
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text("A card has been used")),
      // );
      displayMySnackBar(context, "A card has already been used");
      return;
    }
    setState(() {
      userApplyingCard = true;
    });
  }

  void onBlockCard() {
    if (ref.read(cardProvider)[Cards.block]! > 0) {
      myActiveCard = Cards.block;
      messageDetails.addAll(
        {"activeCard": kCardsList.indexOf(myActiveCard!)},
      );
      setState(() {
        feedback = "Guess Opponent next position";
        getPosition = true;
        userApplyingCard = false;
        ref.read(cardProvider.notifier).reduceCard(Cards.block);
      });
    } else {
      displayMySnackBar(context, "You don't have any of this card!");
    }
  }

  void onSwapCard() {
    if (ref.read(cardProvider)[Cards.swap]! > 0) {
      myActiveCard = Cards.swap;
      messageDetails.addAll({"activeCard": kCardsList.indexOf(myActiveCard!)});
      setState(() {
        feedback = "Guess Opponent's next position";
        getPosition = true;
        ref.read(cardProvider.notifier).reduceCard(Cards.swap);
      });
    } else {
      displayMySnackBar(context, "You don't have any of this card!");
    }
  }

  void onRandomSwapCard() {
    if (ref.read(cardProvider)[Cards.randomSwap]! > 0) {
      myActiveCard = Cards.randomSwap;
      messageDetails.addAll({
        "activeCard": kCardsList.indexOf(myActiveCard!),
      });
      setState(() {
        feedback = "Guess Opponent next position";
        getPosition = true;
        userApplyingCard = false;
        ref.read(cardProvider.notifier).reduceCard(Cards.randomSwap);
      });
    } else {
      displayMySnackBar(context, "You don't have any of this card!");
    }
  }

  void onNullifyCard() {
    if (ref.read(cardProvider)[Cards.nullify]! > 0) {
      myActiveCard = Cards.nullify;
      nullifyPowerupSound();
      messageDetails.addAll({"feedback": "Your card was nullified!"});
      // actually add feddback,
      setState(() {
        feedback = "Nullified!";
        Timer(const Duration(milliseconds: 1000), () {
          setState(() {
            feedback = null;
          });
        });
        opponentCardPosition = [];
        opponentActiveCard = null;
        userApplyingCard = false;
        ref.read(cardProvider.notifier).reduceCard(Cards.nullify);
      });
    } else {
      displayMySnackBar(context, "You don't have any of this card!");
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(cardProvider);
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
      body: widget.isHosting || isConnected
          ? StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: db.collection(matchCode).snapshots(),
              builder: (context,
                  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                if (snapshot.hasData) {
                  final currentData = snapshot.data!.docs[0].data();
                  intepreteMessage(currentData);
                }

                if (!isConnected) {
                  return Center(
                    child: Text(
                      "The match code is your username: '$matchCode' \nWaiting for Opponent...",
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge!
                          .copyWith(fontWeight: FontWeight.w400),
                    ),
                  );
                }

                return SingleChildScrollView(
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      if (opponentActiveCard != null)
                                        const CardBack(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 15, horizontal: 30),
                                        decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .tertiary,
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: containerList.sublist(0, 3),
                                      ),
                                      const Divider(
                                        thickness: 7,
                                        color: Colors.black,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: containerList.sublist(3, 6),
                                      ),
                                      const Divider(
                                        thickness: 7,
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
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
                                  style: TextStyle(
                                      fontSize: 18,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.w600),
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
                                        if (userApplyingCard)
                                          ...widget.cards.map(
                                            (item) => Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                CircleAvatar(
                                                  radius: 15,
                                                  backgroundColor:
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .tertiary,
                                                  foregroundColor:
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .tertiaryContainer,
                                                  child: Text(
                                                    "${ref.read(cardProvider)[item]}",
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                ),
                                                cardListDisplay[item]!,
                                              ],
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                            color: Theme.of(context)
                                                .colorScheme
                                                .tertiary,
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
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
                                      if (opponentActiveCard != null)
                                        const CardBack(),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                if (feedback != null)
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Text(
                                      feedback!,
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: width / 2,
                                  // color: Colors.black54,
                                  child: Expanded(
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
                                                if (userApplyingCard)
                                                  ...widget.cards.map(
                                                    (item) => Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        CircleAvatar(
                                                          radius: 15,
                                                          backgroundColor:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .tertiary,
                                                          foregroundColor: Theme
                                                                  .of(context)
                                                              .colorScheme
                                                              .tertiaryContainer,
                                                          child: Text(
                                                            "${ref.read(cardProvider)[item]}",
                                                            style: const TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                          ),
                                                        ),
                                                        cardListDisplay[item]!,
                                                      ],
                                                    ),
                                                  ),
                                                if (userApplyingCard)
                                                  IconButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        userApplyingCard =
                                                            false;
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
                                        ),
                                      ],
                                    ),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: containerList.sublist(0, 3),
                                      ),
                                      const Divider(
                                        thickness: 7,
                                        color: Colors.black,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: containerList.sublist(3, 6),
                                      ),
                                      const Divider(
                                        thickness: 7,
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
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
                );
              })
          : Center(child: joinWidget),
    );
  }
}
