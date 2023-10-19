import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_x_and_o/widgets/player.dart';
import 'package:flutter/material.dart';

class OPlayerNotifier extends StateNotifier<Player> {
  OPlayerNotifier()
      : super(Player(
          value: "O",
          color: Colors.blue,
        ));

  void changeColour(Color color) {
    Player newPlayer = Player();
    newPlayer.color = color;
    newPlayer.value = state.value;
    state = newPlayer;
  }

  void changeValue(String value) {
    Player newPlayer = Player();
    newPlayer.value = value;
    newPlayer.color = state.color;
    state = newPlayer;
  }
}

final oPlayerProvider =
    StateNotifierProvider<OPlayerNotifier, Player>((ref) => OPlayerNotifier());
