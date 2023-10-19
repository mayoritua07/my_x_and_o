import 'package:flutter/material.dart';

class CardBack extends StatelessWidget {
  const CardBack(
      {super.key,
      this.isSmall = true,
      this.color = const Color.fromARGB(255, 115, 186, 245)});

  final bool isSmall;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(4),
        width: isSmall ? 70 : 200,
        height: isSmall ? 90 : 280,
        decoration: BoxDecoration(color: color),
        child: Image.asset("assets/images/card_image/card_back3.jpeg",
            fit: BoxFit.cover));
  }
}

class CardFront extends StatelessWidget {
  const CardFront({
    super.key,
    required this.title,
    required this.imageName,
    required this.apply,
  });

  final String title;
  final void Function() apply;
  final String imageName;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: apply,
      child: Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
        width: 110,
        height: 150,
        decoration: const BoxDecoration(
            color: Color.fromARGB(255, 115, 186, 245),
            border: Border.symmetric(
                vertical: BorderSide(width: 4, color: Colors.red),
                horizontal: BorderSide(width: 4, color: Colors.red))),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(title),
              ),
              Image.asset(
                "assets/images/powerup/$imageName.png",
                color: const Color.fromARGB(255, 192, 22, 10),
                width: 95,
                height: 95,
                fit: BoxFit.cover,
              ),
            ]),
      ),
    );
  }
}

class BlockCard extends StatelessWidget {
  const BlockCard({super.key, required this.onApply});

  final void Function() onApply;

  @override
  Widget build(BuildContext context) {
    return CardFront(
      imageName: "block",
      title: "Block",
      apply: onApply,
    );
  }
}

class BlockCardBig extends StatelessWidget {
  const BlockCardBig({super.key, required this.onApply});

  final void Function() onApply;
  @override
  Widget build(BuildContext context) {
    final card = CardFrontBig(
        imageName: "block",
        title: "Block",
        apply: onApply,
        details: "If Opponent plays on the selected tile he loses his turn.");
    return card;
  }
}

class NullifyCard extends StatelessWidget {
  const NullifyCard({super.key, required this.onApply});

  final void Function() onApply;

  @override
  Widget build(BuildContext context) {
    return CardFront(
      imageName: "nullify",
      title: "Nullify",
      apply: onApply,
    );
  }
}

class NullifyCardBig extends StatelessWidget {
  const NullifyCardBig({super.key, required this.onApply});

  final void Function() onApply;

  @override
  Widget build(BuildContext context) {
    final card = CardFrontBig(
        imageName: "nullify",
        title: "Nullify",
        apply: onApply,
        details: "This cancels out the effect of any card played by opponent");

    return card;
  }
}

class SwapCard extends StatelessWidget {
  const SwapCard({super.key, required this.onApply});

  final void Function() onApply;

  @override
  Widget build(BuildContext context) {
    return CardFront(
      imageName: "swap",
      title: "Swap",
      apply: onApply,
    );
  }
}

class SwapCardBig extends StatelessWidget {
  const SwapCardBig({super.key, required this.onApply});

  final void Function() onApply;

  @override
  Widget build(BuildContext context) {
    final card = CardFrontBig(
        imageName: "swap",
        title: "Swap",
        apply: onApply,
        details:
            "Moves your opponent from initial position tile to desired position");

    return card;
  }
}

class RandomSwapCard extends StatelessWidget {
  const RandomSwapCard({super.key, required this.onApply});

  final void Function() onApply;

  @override
  Widget build(BuildContext context) {
    return CardFront(
      imageName: "random_swap",
      title: "Random",
      apply: onApply,
    );
  }
}

class RandomSwapCardBig extends StatelessWidget {
  RandomSwapCardBig({super.key, required this.onApply});

  final void Function() onApply;

  @override
  Widget build(BuildContext context) {
    final card = CardFrontBig(
        imageName: "random_swap",
        title: "Random",
        apply: onApply,
        details: "Moves opponent avatar to a random free tile");

    return card;
  }
}

class CardPack extends StatelessWidget {
  const CardPack(
      {super.key,
      required this.color,
      required this.quantity,
      required this.title,
      required this.cards,
      required this.rarity,
      required this.onBuy,
      required this.price});

  final int quantity;
  final Color color;
  final List<Widget> cards;
  final String rarity;
  final int price;
  final String title;
  final void Function() onBuy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 20,
      ),
      decoration: BoxDecoration(
          color: Colors.black45, borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      height: 300,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Stack(
            children: [
              CardBack(isSmall: false, color: color),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    color: color,
                    width: 200,
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                  Container(
                    width: 200,
                    height: 30,
                    color: color,
                  )
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  "Rarity: $rarity",
                  style: const TextStyle(fontSize: 18),
                  softWrap: true,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  "Quantity: $quantity",
                  style: const TextStyle(fontSize: 18),
                  softWrap: true,
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  backgroundColor: Colors.green,
                ),
                onPressed: onBuy,
                label: Text(
                  "$price",
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                icon: const Icon(
                  Icons.monetization_on,
                  color: Colors.yellow,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CardFrontBig extends StatefulWidget {
  const CardFrontBig(
      {super.key,
      required this.title,
      required this.imageName,
      required this.apply,
      required this.details});

  final String title;
  final String details;
  final void Function() apply;
  final String imageName;

  @override
  State<CardFrontBig> createState() => _CardFrontBigState();
}

class _CardFrontBigState extends State<CardFrontBig> {
  bool isTapped = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.apply,
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
        width: 180,
        height: 240,
        decoration: BoxDecoration(
            color: const Color.fromARGB(255, 115, 186, 245),
            border: Border.symmetric(
                vertical:
                    BorderSide(width: isTapped ? 8 : 4, color: Colors.red),
                horizontal:
                    BorderSide(width: isTapped ? 8 : 4, color: Colors.red))),
        child: Stack(
          children: [
            Center(
              child: Opacity(
                opacity: 0.9,
                child: Image.asset(
                  "assets/images/powerup/${widget.imageName}.png",
                  color: const Color.fromARGB(255, 192, 22, 10),
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    widget.details,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
