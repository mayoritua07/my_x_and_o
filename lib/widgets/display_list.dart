import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_x_and_o/main.dart';
import 'package:my_x_and_o/widgets/display_item.dart';

List<Color> colorList = [
  Colors.red,
  Colors.amber,
  Colors.orange,
  Colors.brown,
  Colors.grey,
  Colors.lime,
  Colors.teal,
  Colors.pink,
  Colors.green,
  Colors.blue,
  Colors.purple,
];
List<String> oString = [
  "O",
  "assets/images/O_image/image1.png",
  "assets/images/O_image/image2.png",
  "assets/images/O_image/image3.png",
  "assets/images/O_image/image4.png",
  "assets/images/O_image/image5.png",
  "assets/images/O_image/image6.png",
  "assets/images/O_image/image7.png",
  "assets/images/O_image/image8.png",
];

List<String> xString = [
  "X",
  "assets/images/X_image/x_image1.png",
  "assets/images/X_image/x_image2.png",
  "assets/images/X_image/x_image3.png",
  "assets/images/X_image/x_image4.png",
  "assets/images/X_image/x_image5.png",
  "assets/images/X_image/x_image6.png",
  "assets/images/X_image/x_image7.png",
  "assets/images/X_image/x_image8.png",
  "assets/images/X_image/x_image9.png",
];

class DisplayList extends ConsumerWidget {
  const DisplayList.avatar(
      {super.key,
      required this.title,
      this.value,
      this.isColor = false,
      required this.refresh});
  const DisplayList.color(
      {super.key,
      required this.title,
      this.value,
      this.isColor = true,
      required this.refresh});

  final String title;
  final bool isColor;
  final String? value;
  final void Function() refresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(darkModeProvider);
    final isDarkMode = ref.read(darkModeProvider);
    double width = MediaQuery.of(context).size.width;
    List<Widget> list = isColor
        ? value == "O"
            ? [
                ...colorList
                    .map((item) => ODisplayItem(color: item, refresh: refresh))
                    .toList(),
              ]
            : [
                ...colorList
                    .map((item) => XDisplayItem(color: item, refresh: refresh))
                    .toList(),
              ]
        : value == "O"
            ? [
                ...oString
                    .map((item) => ODisplayItem(
                          refresh: refresh,
                          string: item,
                        ))
                    .toList()
              ]
            : [
                ...xString
                    .map((item) => XDisplayItem(string: item, refresh: refresh))
                    .toList(),
              ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            title,
            style: TextStyle(
                color: isDarkMode
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(context).colorScheme.secondaryContainer,
                fontSize: 23),
          ),
        ),
        width > 650
            ? Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Expanded(
                    child: Column(
                      children: list,
                    ),
                  ),
                ),
              )
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: list),
              ),
      ],
    );
  }
}
