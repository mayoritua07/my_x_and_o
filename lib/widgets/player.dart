import 'package:flutter/material.dart';

class Player extends StatelessWidget {
  Player({super.key, this.value, this.color});

  String? value;
  Color? color;
  late Widget nextPlayerImage = value!.length == 1
      ? Text(
          value!,
          style: TextStyle(fontSize: 60, color: color),
        )
      : Image.asset(
          value!,
          color: color,
          height: 80,
          width: 80,
        );
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    if (width > 610) {
      width /= 1.6;
    }
    if (value == null) {
      return Text(
        "",
        style: TextStyle(fontSize: width / 5, color: color),
      );
    } else if (value!.length == 1) {
      return Text(
        value!,
        style: TextStyle(
            fontSize: width > 650 ? width / 9 : width / 6, color: color),
      );
    }
    return Image.asset(
      value!,
      color: color,
    );
  }
}
