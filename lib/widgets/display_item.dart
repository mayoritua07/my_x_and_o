import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_x_and_o/main.dart';
import 'package:my_x_and_o/providers/o_player_provider.dart';
import 'package:my_x_and_o/providers/sound.dart';
import 'package:my_x_and_o/providers/x_player_provider.dart';
import 'package:my_x_and_o/widgets/player.dart';

class ODisplayItem extends ConsumerStatefulWidget {
  const ODisplayItem(
      {super.key, this.color, this.string, required this.refresh});

  final Color? color;
  final String? string;

  final void Function() refresh;
  @override
  ConsumerState<ODisplayItem> createState() => _DisplayItemState();
}

class _DisplayItemState extends ConsumerState<ODisplayItem> {
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
    ref.watch(oPlayerProvider);
    ref.watch(darkModeProvider);
    final isDarkMode = ref.read(darkModeProvider);
    Player oPlayer = ref.read(oPlayerProvider);
    double size =
        widget.color == oPlayer.color || widget.string == oPlayer.value
            ? 110
            : 100;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        child: Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
              color: widget.color ?? Colors.transparent,
              border: Border.all(
                width: widget.color == oPlayer.color ||
                        widget.string == oPlayer.value
                    ? 5.0
                    : 0.0,
                color: Theme.of(context).colorScheme.tertiary,
              )),
          child: Center(
            child: widget.string != null
                ? Player(
                    value: widget.string!,
                    color: isDarkMode
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context).colorScheme.secondaryContainer,
                  )
                : null,
          ),
        ),
        onTap: () {
          setState(() {
            if (widget.color != null) {
              if (widget.color == ref.read(xPlayerProvider).color) {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    content: Text(
                      "This colour can not be assigned!",
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary),
                    )));
                return;
              }

              ref.read(oPlayerProvider.notifier).changeColour(widget.color!);
            } else {
              ref.read(oPlayerProvider.notifier).changeValue(widget.string!);
            }
            buttonSound(() {});
            widget.refresh();
          });
        },
      ),
    );
  }
}

class XDisplayItem extends ConsumerStatefulWidget {
  const XDisplayItem(
      {super.key, this.color, this.string, required this.refresh});

  final Color? color;
  final String? string;

  final void Function() refresh;
  @override
  ConsumerState<XDisplayItem> createState() => _XDisplayItemState();
}

class _XDisplayItemState extends ConsumerState<XDisplayItem> {
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
    ref.watch(xPlayerProvider);
    ref.watch(darkModeProvider);
    final isDarkMode = ref.read(darkModeProvider);
    Player xPlayer = ref.read(xPlayerProvider);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        child: Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
              color: widget.color ?? Colors.transparent,
              border: Border.all(
                width: widget.color == xPlayer.color ||
                        widget.string == xPlayer.value
                    ? 5.0
                    : 0.0,
                color: Theme.of(context).colorScheme.tertiary,
              )),
          child: Center(
            child: widget.string != null
                ? Player(
                    value: widget.string!,
                    color: isDarkMode
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context).colorScheme.secondaryContainer,
                  )
                : null,
          ),
        ),
        onTap: () {
          setState(() {
            if (widget.color != null) {
              if (widget.color == ref.read(oPlayerProvider).color) {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                  "This colour can not be assigned!",
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge!
                      .copyWith(color: Theme.of(context).colorScheme.onPrimary),
                )));
                return;
              }
              ref.read(xPlayerProvider.notifier).changeColour(widget.color!);
            } else {
              ref.read(xPlayerProvider.notifier).changeValue(widget.string!);
            }
            buttonSound(() {});
            widget.refresh();
          });
        },
      ),
    );
  }
}
