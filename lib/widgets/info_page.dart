import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_x_and_o/model/card.dart';
import 'package:my_x_and_o/providers/cards_provider.dart';
import 'package:my_x_and_o/providers/o_player_provider.dart';
import 'package:my_x_and_o/providers/x_player_provider.dart';
import 'package:my_x_and_o/screens/shop.dart';
import 'package:my_x_and_o/widgets/snackbar.dart';

class InfoPage extends ConsumerStatefulWidget {
  const InfoPage(
      {super.key,
      required this.onPressed,
      required this.value,
      required this.useCards});

  final void Function(List<Enum> cards) onPressed;
  final String value;
  final bool useCards;

  @override
  ConsumerState<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends ConsumerState<InfoPage> {
  Map<Enum, Widget> cardsDisplayList = {};
  Map<Enum, Widget> originalCards = {};
  List<Enum> cards = [];

  @override
  void initState() {
    final blockCard = BlockCardBig(onApply: () {
      addingCards(Cards.block);
    });
    final nullifyCard = NullifyCardBig(onApply: () {
      addingCards(Cards.nullify);
    });
    final randomSwapCard = RandomSwapCardBig(onApply: () {
      addingCards(Cards.randomSwap);
    });
    final swapCard = SwapCardBig(onApply: () {
      addingCards(Cards.swap);
    });
    originalCards = {
      Cards.block: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          blockCard,
        ],
      ),
      Cards.nullify: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          nullifyCard,
        ],
      ),
      Cards.randomSwap: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          randomSwapCard,
        ],
      ),
      Cards.swap: Column(
        mainAxisSize: MainAxisSize.min,
        children: [const SizedBox(height: 20), swapCard],
      ),
    };

    for (final item in ref.read(cardProvider).entries) {
      if (item.value > 0) {
        cardsDisplayList.addAll({item.key: originalCards[item.key]!});
      }
    }

    super.initState();
  }

  void addingCards(Enum value) {
    setState(() {
      if (cards.contains(value)) {
        cards.remove(value);
        cardsDisplayList[value] = Column(
          mainAxisSize: MainAxisSize.min,
          children: [const SizedBox(height: 20), originalCards[value]!],
        );
      } else if (cards.length < 2) {
        cards.add(value);
        cardsDisplayList[value] = Column(
          mainAxisSize: MainAxisSize.min,
          children: [const Icon(Icons.check), originalCards[value]!],
        );
      } else {
        displayMySnackBar(context, "You can't selct more than 2 cards");
      }
    });
  }

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              widget.value == "X"
                  ? ref.read(xPlayerProvider).nextPlayerImage
                  : ref.read(oPlayerProvider).nextPlayerImage,
              const Text('Cards'),
            ],
          ),
          if (widget.useCards)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Select cards from here",
                      style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer,
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                    )),
                SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: cardsDisplayList.values.toList())),
              ],
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
                onPressed: () {
                  widget.onPressed(cards);
                },
                child: const Text("Ready")),
          ),
        ],
      ),
    );
  }
}
