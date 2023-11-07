import 'package:flutter/material.dart';

class InputCode extends StatefulWidget {
  const InputCode({super.key, required this.onPressed});

  final void Function(String code) onPressed;

  @override
  State<InputCode> createState() => _InputCodeState();
}

class _InputCodeState extends State<InputCode> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Theme.of(context).colorScheme.onBackground,
      ),
      padding: const EdgeInsets.all(10),
      width: MediaQuery.of(context).size.width / 1.2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(color: Theme.of(context).colorScheme.onPrimary),
            controller: controller,
            decoration:
                const InputDecoration(label: Text("Input the match code")),
          ),
          TextButton(
              onPressed: () {
                // TODO Drop keyboard
                widget.onPressed(controller.text);
              },
              child: const Text("Join"))
        ],
      ),
    );
  }
}
