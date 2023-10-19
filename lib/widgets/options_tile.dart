import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_x_and_o/providers/sound.dart';

class OptionsTile extends ConsumerStatefulWidget {
  const OptionsTile(
      {super.key,
      required this.optionText,
      required this.trueText,
      required this.falseText,
      required this.boolValue,
      required this.onSwitched});

  final String optionText;
  final String falseText;
  final String trueText;
  final bool boolValue;
  final void Function(bool switchValue) onSwitched;

  @override
  ConsumerState<OptionsTile> createState() => _OptionsTileState();
}

class _OptionsTileState extends ConsumerState<OptionsTile> {
  late bool value;
  final player = AudioPlayer();
  @override
  void initState() {
    value = widget.boolValue;
    super.initState();
  }

  void clickButton(void Function() nextPage) async {
    if (ref.read(soundEffectProvider)) {
      await player.stop();
      await player.setSource(AssetSource("audio/click_button.mp3"));
      await player.resume();
    }

    Timer(const Duration(milliseconds: 200), () {
      nextPage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 35),
      child: Column(
        children: [
          Text(
            widget.optionText,
            style: TextStyle(
                fontSize: 22,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  widget.falseText,
                  style: TextStyle(
                      fontSize: 25,
                      color: Theme.of(context).colorScheme.onBackground,
                      fontWeight: !value ? FontWeight.w800 : FontWeight.w300),
                ),
                Switch(
                    value: value,
                    onChanged: (newValue) {
                      setState(() {
                        value = newValue;
                        widget.onSwitched(value);
                      });
                      clickButton(() {});
                    }),
                Text(
                  widget.trueText,
                  style: TextStyle(
                      fontSize: 25,
                      color: Theme.of(context).colorScheme.onBackground,
                      fontWeight: value ? FontWeight.w800 : FontWeight.w300),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
