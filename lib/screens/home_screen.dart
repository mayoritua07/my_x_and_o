import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:my_x_and_o/providers/sound.dart';
import 'package:my_x_and_o/screens/online_play.dart';
import 'package:my_x_and_o/screens/options.dart';
import 'package:my_x_and_o/screens/setup_screen.dart';
import 'package:my_x_and_o/screens/shop.dart';
import 'package:my_x_and_o/screens/single_player.dart';
import 'package:my_x_and_o/screens/wifi_play.dart';
import 'package:my_x_and_o/screens/x_and_o.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_x_and_o/main.dart';
import 'package:move_to_background/move_to_background.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late bool isDarkMode;
  late double width;
  late double height;
  late bool isLandscape;

  Widget modePopup(
      List<String> modesText, List<void Function()> modesFunction) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 45),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Theme.of(context).colorScheme.background
            : Theme.of(context).colorScheme.onBackground.withAlpha(250),
        borderRadius: const BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < modesText.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: ElevatedButton(
                onPressed: modesFunction[i],
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                )),
                child: Text(modesText[i]),
              ),
            ),
        ],
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    isLandscape = width > 650;
    ref.watch(darkModeProvider);
    isDarkMode = ref.read(darkModeProvider);

    final List<String> wifiModesText = ["Host", "Join"];
    final List<void Function()> wifiModesFunction = [
      () {
        Navigator.of(context).pop();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SetupScreen(
              changePage: ((context, value, cards, useCards) =>
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => WifiPlay(
                      value: value,
                      cards: cards,
                    ),
                  ))),
            ),
          ),
        );
      },
      () {},
    ];

    final List<void Function()> onlineModesFunction = [
      () {
        Navigator.of(context).pop();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SetupScreen(
              changePage: ((context, value, cards, useCards) =>
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => OnlinePlay.host(
                      value: value,
                      cards: cards,
                      useCards: useCards!,
                    ),
                  ))),
            ),
          ),
        );
      },
      () {
        Navigator.of(context).pop();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => OnlinePlay.join(
              value: '',
              cards: const [],
            ),
          ),
        );
      },
    ];

    final List<Widget> options = [
      TextButton(
        onPressed: () {
          buttonSound(() {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SetupScreen(
                  changePage: ((context, value, List<Enum> cards, useCards) =>
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => SinglePlayer(
                          value: value,
                          cards: cards,
                        ),
                      ))),
                ),
              ),
            );
          });
        },
        child: Text(
          'Single Player',
          style: TextStyle(
            fontSize: 24,
            color: isDarkMode
                ? Theme.of(context).colorScheme.secondary
                : Theme.of(context).colorScheme.onSecondary,
          ),
        ),
      ),
      TextButton(
        onPressed: () {
          buttonSound(() {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text(
                    "Play Online",
                    textAlign: TextAlign.center,
                  ),
                  content: modePopup(wifiModesText, onlineModesFunction),
                );
              },
            );
          });
        },
        child: Text(
          'Play Online',
          style: TextStyle(
            fontSize: 24,
            color: isDarkMode
                ? Theme.of(context).colorScheme.secondary
                : Theme.of(context).colorScheme.onSecondary,
          ),
        ),
      ),
      TextButton(
        onPressed: () {
          buttonSound(() {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const GameScreen()),
            );
          });
        },
        child: Text(
          'Local Multi-Player',
          style: TextStyle(
            fontSize: 24,
            color: isDarkMode
                ? Theme.of(context).colorScheme.secondary
                : Theme.of(context).colorScheme.onSecondary,
          ),
        ),
      ),
      TextButton(
        onPressed: () {
          buttonSound(() {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text(
                    "Wi-fi Play",
                    textAlign: TextAlign.center,
                  ),
                  content: modePopup(wifiModesText, wifiModesFunction),
                );
              },
            );
          });
        },
        child: Text(
          'Wi-fi Play',
          style: TextStyle(
            fontSize: 24,
            color: isDarkMode
                ? Theme.of(context).colorScheme.secondary
                : Theme.of(context).colorScheme.onSecondary,
          ),
        ),
      ),
      TextButton(
        onPressed: () {
          buttonSound(() {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => const Options()));
          });
        },
        child: Text(
          'Options',
          style: TextStyle(
              fontSize: 24,
              color: isDarkMode
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.primaryContainer),
        ),
      )
    ];

    return WillPopScope(
      onWillPop: () async {
        MoveToBackground.moveTaskToBack();
        return false;
        // bool exitGame = false;
        // await showDialog(
        //   context: context,
        //   builder: (context) {
        //     return AlertDialog(
        //       title: const Text("Exit App"),
        //       content: const Center(
        //         child: Text("Are you sure you wish to exit?"),

        //       ),
        //       actions: [
        //         TextButton(Logs
        //             onPressed: () {
        //               exitGame = true;
        //               Navigator.of(context).pop();
        //             },
        //             child: const Text("Yes")),
        //         TextButton(
        //             onPressed: () {
        //               exitGame = false;
        //               Navigator.of(context).pop();
        //             },
        //             child: const Text("No"))
        //       ],
        //     );
        //   },
        // );
        // return exitGame;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: isDarkMode
              ? Theme.of(context).colorScheme.background
              : Theme.of(context).colorScheme.onBackground,
          foregroundColor: isDarkMode
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSecondary,
          title: const Center(
              child: Text(
            'My X and O',
            style: TextStyle(
              fontSize: 24,
            ),
          )),
        ),
        backgroundColor: isDarkMode ? Colors.black : null,
        body: Stack(
          children: [
            Opacity(
              opacity: 1.0,
              child: Image.asset(
                !isDarkMode
                    ? 'assets/images/home_lightTheme/x_home_page.png'
                    : 'assets/images/home_darkTheme/dark_home_theme_no_bg.png',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            //  Text(
            //           'Welcome MayorItua!',
            //           textAlign: TextAlign.center,
            //           style: TextStyle(
            //             fontSize: 20,
            //             fontWeight: FontWeight.w900,
            //             color: Theme.of(context).colorScheme.primaryContainer,
            //           ),
            //         ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Theme.of(context).colorScheme.background
                      : Theme.of(context)
                          .colorScheme
                          .onBackground
                          .withAlpha(250),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const Shop(),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.shopping_cart_outlined,
                          size: 34,
                          color: isDarkMode
                              ? Theme.of(context).colorScheme.secondary
                              : Theme.of(context).colorScheme.primaryContainer,
                        )),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: isLandscape ? 1 : 60,
              left: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                clipBehavior: Clip.hardEdge,
                width: width - 20,
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Theme.of(context).colorScheme.background
                      : Theme.of(context)
                          .colorScheme
                          .onBackground
                          .withAlpha(250),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(15),
                  ),
                ),
                child: isLandscape
                    ? SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: options
                              .map((item) => Padding(
                                    padding:
                                        EdgeInsets.only(right: width / 110),
                                    child: item,
                                  ))
                              .toList(),
                        ),
                      )
                    : Column(
                        children: options,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
