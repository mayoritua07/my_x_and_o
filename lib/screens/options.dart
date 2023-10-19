import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_x_and_o/main.dart';
import 'package:my_x_and_o/providers/o_player_provider.dart';
import 'package:my_x_and_o/providers/sound.dart';
import 'package:my_x_and_o/providers/x_player_provider.dart';
import 'package:my_x_and_o/widgets/hanging_drawer.dart';
import 'package:my_x_and_o/widgets/options_tile.dart';

class Options extends ConsumerStatefulWidget {
  const Options({super.key});

  @override
  ConsumerState<Options> createState() {
    return _OptionsState();
  }
}

class _OptionsState extends ConsumerState<Options> {
  final player = AudioPlayer();

  void refresh() {}

  void changeTheme() {
    ref.read(darkModeProvider.notifier).changeTheme();
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
    bool isDarkMode = ref.read(darkModeProvider);
    ref.watch(darkModeProvider);
    double width = MediaQuery.of(context).size.width - 40;

    List<Widget> optionsList = [
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          OptionsTile(
            optionText: 'Sound Effects',
            falseText: 'Off',
            trueText: 'On',
            boolValue: ref.read(soundEffectProvider),
            onSwitched: (switchValue) {
              ref.read(soundEffectProvider.notifier).toggleSoundEffect();
            },
          ),
          OptionsTile(
            optionText: 'Sound Track',
            falseText: 'Off',
            trueText: 'On',
            boolValue: ref.read(soundTrackProvider),
            onSwitched: (switchValue) {
              ref.read(soundTrackProvider.notifier).toggleSoundTrack();
            },
          ),
          OptionsTile(
            optionText: 'Theme',
            falseText: 'Light Mode',
            trueText: 'Dark Mode',
            boolValue: isDarkMode,
            onSwitched: (switchValue) {
              changeTheme();
            },
          ),
        ],
      ),
      const HangingDrawer(),
    ];

    ref.watch(xPlayerProvider);
    ref.watch(oPlayerProvider);

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
            'Options',
            style: TextStyle(fontSize: 24),
          ),
        ),
        body: Stack(
          children: width > 650
              ? [
                  SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OptionsTile(
                          optionText: 'Sound Effects',
                          falseText: 'Off',
                          trueText: 'On',
                          boolValue: ref.read(soundEffectProvider),
                          onSwitched: (switchValue) {
                            ref
                                .read(soundEffectProvider.notifier)
                                .toggleSoundEffect();
                          },
                        ),
                        OptionsTile(
                          optionText: 'Sound Track',
                          falseText: 'Off',
                          trueText: 'On',
                          boolValue: ref.read(soundTrackProvider),
                          onSwitched: (switchValue) {
                            ref
                                .read(soundTrackProvider.notifier)
                                .toggleSoundTrack();
                          },
                        ),
                        OptionsTile(
                          optionText: 'Theme',
                          falseText: 'Light Mode',
                          trueText: 'Dark Mode',
                          boolValue: isDarkMode,
                          onSwitched: (switchValue) {
                            changeTheme();
                          },
                        ),
                      ],
                    ),
                  ),
                  const HangingDrawer(),
                ]
              : optionsList,
        ));
  }
}
