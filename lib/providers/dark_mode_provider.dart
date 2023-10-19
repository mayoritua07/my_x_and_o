import 'package:flutter_riverpod/flutter_riverpod.dart';

class DarkModeNotifier extends StateNotifier<bool> {
  DarkModeNotifier(bool darkMode) : super(darkMode);

  void changeTheme() {
    state = !state;
  }
}
