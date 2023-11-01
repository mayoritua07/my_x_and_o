import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_x_and_o/main.dart';
import 'package:my_x_and_o/providers/o_player_provider.dart';
import 'package:my_x_and_o/providers/x_player_provider.dart';
import 'package:my_x_and_o/widgets/display_list.dart';
import 'package:my_x_and_o/widgets/player.dart';

class HangingDrawer extends ConsumerStatefulWidget {
  const HangingDrawer({super.key});

  @override
  ConsumerState<HangingDrawer> createState() => _HangingDrawerState();
}

class _HangingDrawerState extends ConsumerState<HangingDrawer> {
  late Player previewObject;
  bool isX = false;
  double xDistance = 0;

  void refresh() {
    setState(() {
      previewObject = ref.read(isX ? xPlayerProvider : oPlayerProvider);
    });
  }

  @override
  void initState() {
    previewObject = ref.read(oPlayerProvider);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final isDarkMode = ref.read(darkModeProvider);
    final isLandscape = width > 650;
    List<Widget> configurations = [
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: DisplayList.avatar(
          value: isX ? "X" : "O",
          title: "Avatar",
          refresh: refresh,
        ),
      ),
      SizedBox(height: height / 20),
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: DisplayList.color(
          value: isX ? "X" : "O",
          title: "Color",
          refresh: refresh,
        ),
      ),
      SizedBox(height: height / 18),
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Preview",
            style: TextStyle(
                color: isDarkMode
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(context).colorScheme.secondaryContainer,
                fontSize: 22,
                fontWeight: FontWeight.bold),
          ),
          Container(
            height: 120,
            width: 120,
            decoration: const BoxDecoration(color: Colors.transparent),
            child: Center(
              child: previewObject,
            ),
          )
        ],
      ),
    ];

    return DraggableScrollableSheet(
      controller: DraggableScrollableController(),
      snap: true,
      minChildSize: isLandscape ? 0.2 : 0.12,
      initialChildSize: isLandscape ? 0.2 : 0.12,
      maxChildSize: isLandscape ? 0.9 : 0.92,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                isX ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity! < 0) {
                    // swipe to left
                    if (!isX) {
                      return;
                    }
                    setState(() {
                      isX = false;
                      refresh();
                    });
                  } else {
                    if (isX) {
                      return;
                    }
                    setState(() {
                      isX = true;
                      refresh();
                    });
                  }
                },
                child: Container(
                  margin: EdgeInsets.only(top: isLandscape ? 15 : 30),
                  height: 50,
                  width: 150,
                  decoration: BoxDecoration(
                    border: Border.all(width: 0),
                    borderRadius: isX
                        ? const BorderRadius.only(
                            topLeft: Radius.circular(20),
                          )
                        : const BorderRadius.only(
                            topRight: Radius.circular(20),
                          ),
                    color: isDarkMode
                        ? Theme.of(context).colorScheme.background
                        : Theme.of(context).colorScheme.onBackground,
                  ),
                  child: Row(
                    mainAxisAlignment:
                        isX ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      if (isX)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            "${jsonDecode(jsonEncode('←'))}",
                            style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode
                                    ? Theme.of(context).colorScheme.secondary
                                    : Theme.of(context)
                                        .colorScheme
                                        .secondaryContainer),
                          ),
                        ),
                      Text(
                        isX ? " X configure" : "O configure ",
                        style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w400,
                            color: isDarkMode
                                ? Theme.of(context).colorScheme.secondary
                                : Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer),
                      ),
                      if (!isX)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            "${jsonDecode(jsonEncode('→'))}",
                            style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode
                                    ? Theme.of(context).colorScheme.secondary
                                    : Theme.of(context)
                                        .colorScheme
                                        .secondaryContainer),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Container(
                height: isLandscape ? height * 0.58 : height * 0.75,
                width: width,
                decoration: BoxDecoration(
                  border: Border.all(width: 0),
                  color: isDarkMode
                      ? kColorScheme.onBackground
                      : Theme.of(context).colorScheme.onBackground,
                  borderRadius: isX
                      ? const BorderRadius.only(topLeft: Radius.circular(20))
                      : const BorderRadius.only(topRight: Radius.circular(20)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: isLandscape
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: configurations)
                      : SingleChildScrollView(
                          child: Column(children: configurations),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
