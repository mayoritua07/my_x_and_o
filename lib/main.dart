import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_x_and_o/providers/dark_mode_provider.dart';
import 'package:my_x_and_o/providers/sound.dart';
import 'package:my_x_and_o/screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

final kColorScheme = ColorScheme.fromSeed(
    seedColor: const Color.fromARGB(255, 7, 90, 79),
    brightness: Brightness.light);

final kDarkColorScheme = ColorScheme.fromSeed(
    seedColor: const Color.fromARGB(255, 3, 70, 61),
    brightness: Brightness.dark);

ThemeData _lightTheme =
    ThemeData().copyWith(useMaterial3: true, colorScheme: kColorScheme);

ThemeData _darkTheme = ThemeData.dark()
    .copyWith(useMaterial3: true, colorScheme: kDarkColorScheme);

final darkModeProvider = StateNotifierProvider<DarkModeNotifier, bool>(
  (ref) {
    return DarkModeNotifier(
        SchedulerBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark);
  },
);

final songList = [
  "audio/avengers.wav",
  "audio/Pink_Deville.mp3",
  "audio/cool1.mp3"
];
final globalAudioPlayer = AudioPlayer();

final randomizer = Random();
int generateRandomPosition(number) {
  int randomValue = randomizer.nextInt(songList.length);
  if (randomValue == number) {
    return generateRandomPosition(number);
  }
  return randomValue;
}

int num = 0;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await globalAudioPlayer.setSource(AssetSource(songList[0]));
  runApp(
    const ProviderScope(child: MyApp()),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    num = generateRandomPosition(-1);
    globalAudioPlayer.setSource(AssetSource(songList[num]));
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      if (state == AppLifecycleState.paused || !mounted) {
        globalAudioPlayer.pause();
      }
    });
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    globalAudioPlayer.release();
    super.dispose();
  }

  void backgroundMusic(int number) async {
    if (!ref.read(soundTrackProvider)) {
      await globalAudioPlayer.stop();
      num = generateRandomPosition(number);
      await globalAudioPlayer.setSource(AssetSource(songList[num]));
      return;
    }

    await globalAudioPlayer.resume();

    globalAudioPlayer.onPlayerComplete.listen((event) async {
      await globalAudioPlayer
          .setSource(AssetSource(songList[generateRandomPosition(number)]));
      backgroundMusic(number);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(darkModeProvider);
    ref.watch(soundTrackProvider);
    backgroundMusic(num);
    return MaterialApp(
      title: 'My X and O',
      theme: ref.read(darkModeProvider) ? _darkTheme : _lightTheme,
      home: const HomeScreen(),
    );
  }
}

/*
cards : include shop for cards, money, you will start with 3 of each card, nullify and swap will be special cards, amssing wealth, displaying card bought, displaying only cards they have, improve packs description
store locally, path, path provider, sql
design logo
change app name
add extra screen to show quote before match
sound effect everywhere, change powerup effect sound
animation of winning and once game ends no more taps, popup immediately????, confirm this
music should stop once screen is off
closing app with back button
configure snack bar everywhere and still set time



wifi play : username
online play, learn future/stream builder


Update...
timed mode
more cards.
*/
