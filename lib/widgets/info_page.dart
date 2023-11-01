import 'package:flutter/material.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({super.key, required this.onPressed});

  final void Function() onPressed;

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Theme.of(context).colorScheme.onBackground,
      ),
      padding: const EdgeInsets.all(10),
      width: MediaQuery.of(context).size.width / 1.5,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
// o player <        or x player
// select cards or text showing this match is without cards,
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
                onPressed: widget.onPressed, child: const Text("Ready")),
          ),
        ],
      ),
    );
  }
}
