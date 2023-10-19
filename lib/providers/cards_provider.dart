import 'package:flutter_riverpod/flutter_riverpod.dart';

class CardNotifier extends StateNotifier<Map<String, int>> {
  CardNotifier()
      : super({
          "blockCard": 5,
          "nullifyCard": 5,
          "randomSwapCard": 2,
          "swapCard": 1,
        });

  void reduceCard(String card) {
    final newState = state;
    newState[card] = newState[card]! - 1;
    state = newState;
  }

  void addCard(String card) {
    final newState = state;
    newState[card] = newState[card]! + 1;
    state = newState;
  }
}

final cardProvider = StateNotifierProvider<CardNotifier, Map<String, int>>(
    (ref) => CardNotifier());
