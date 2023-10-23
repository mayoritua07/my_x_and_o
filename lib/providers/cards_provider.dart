import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_x_and_o/screens/shop.dart';

class CardNotifier extends StateNotifier<Map<Enum, int>> {
  CardNotifier()
      : super({
          Cards.block: 5,
          Cards.nullify: 1,
          Cards.randomSwap: 2,
          Cards.swap: 2,
        });

  void reduceCard(Enum card) {
    final newState = state;
    newState[card] = newState[card]! - 1;
    state = newState;
  }

  void addCard(Enum card) {
    final newState = state;
    newState[card] = newState[card]! + 1;
    state = newState;
  }
}

final cardProvider = StateNotifierProvider<CardNotifier, Map<Enum, int>>(
    (ref) => CardNotifier());
