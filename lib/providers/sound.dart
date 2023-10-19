import 'package:flutter_riverpod/flutter_riverpod.dart';

class SoundEffectNotifier extends StateNotifier<bool> {
  SoundEffectNotifier() : super(false);

  void toggleSoundEffect() {
    state = !state;
  }
}

class SoundTrackNotifier extends StateNotifier<bool> {
  SoundTrackNotifier() : super(false);

  void toggleSoundTrack() {
    state = !state;
  }
}

final soundEffectProvider = StateNotifierProvider<SoundEffectNotifier, bool>(
    (ref) => SoundEffectNotifier());

final soundTrackProvider = StateNotifierProvider<SoundTrackNotifier, bool>(
    (ref) => SoundTrackNotifier());
