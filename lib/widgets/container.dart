import 'package:flutter/material.dart';
import 'package:my_x_and_o/model/card.dart';
import 'package:my_x_and_o/widgets/player.dart';

class ContainerBox extends StatefulWidget {
  ContainerBox(
      {super.key,
      required this.onClicked,
      required this.position,
      this.player,
      this.tapped = false});

  final void Function(int position) onClicked;
  final int position;
  Widget? player;
  bool tapped;

  late void Function() resetScreen;
  late void Function() activePowerup;
  late void Function(Player newPlayer) displayClicked;

  @override
  State<ContainerBox> createState() => _ContainerBoxState();
}

class _ContainerBoxState extends State<ContainerBox> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    bool isLandscape = width > 650;

    widget.resetScreen = () {
      setState(() {
        widget.player = null;
        widget.tapped = false;
      });
    };

    widget.displayClicked = (newPlayer) {
      setState(() {
        widget.player = newPlayer;
      });
    };

    widget.activePowerup = () {
      setState(() {
        widget.player = const CardBack();
      });
    };

    return GestureDetector(
      onTap: () {
        if (!widget.tapped) {
          setState(() {
            widget.tapped = !widget.tapped;
            widget.onClicked(widget.position);
          });
        }
      },
      child: Container(
        decoration:
            BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
        height: isLandscape ? height / 4.2 : width / 4,
        width: isLandscape ? height / 5 : width / 4,
        child: Center(child: widget.player),
      ),
    );
  }
}
