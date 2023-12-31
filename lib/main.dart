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
import 'package:screen_state/screen_state.dart';

final kColorScheme = ColorScheme.fromSeed(
    seedColor: const Color.fromARGB(255, 7, 90, 79),
    brightness: Brightness.light);

final kDarkColorScheme = ColorScheme.fromSeed(
    seedColor: const Color.fromARGB(255, 3, 70, 61),
    brightness: Brightness.dark);

ThemeData _lightTheme =
    ThemeData().copyWith(useMaterial3: true, colorScheme: kColorScheme);

ThemeData _darkTheme = ThemeData.dark().copyWith(
  useMaterial3: true,
  colorScheme: kDarkColorScheme,
);

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

int num = generateRandomPosition(-1);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await globalAudioPlayer.release();
  await globalAudioPlayer.setSource(AssetSource(songList[num]));
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
  final _screen = Screen();
  bool isScreenOff = false;
  bool audioAlowed = true;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    startListening();
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      if (state == AppLifecycleState.paused) {
        globalAudioPlayer.pause();
        audioAlowed = false;
      }
      if (state == AppLifecycleState.resumed) {
        audioAlowed = true;
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

  void startListening() {
    _screen.screenStateStream!.listen(onData);
  }

  void onData(event) async {
    if (event == ScreenStateEvent.SCREEN_OFF) {
      await globalAudioPlayer.pause();
    }
  }

  void backgroundMusic(int number) async {
    if (!ref.read(soundTrackProvider)) {
      await globalAudioPlayer.stop();
      num = generateRandomPosition(number);
      await globalAudioPlayer.setSource(AssetSource(songList[num]));
      return;
    }

    if (audioAlowed) {
      await globalAudioPlayer.resume();
    }

    globalAudioPlayer.onPlayerStateChanged.listen((event) async {
      if (event == PlayerState.completed) {
        await globalAudioPlayer.release();
        num = generateRandomPosition(number);
        await globalAudioPlayer.setSource(AssetSource(songList[num]));
        backgroundMusic(num);
      }
    });

    // globalAudioPlayer.onPlayerComplete.listen((event) async {
    //   await globalAudioPlayer.release();
    //   await globalAudioPlayer.setSource(AssetSource(songList[num]));
    //   backgroundMusic(number);
    // });
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

// "Mayoritua07"  

// URGENT ADD KEYBOARD FOCUS WHEN DONE TYPING AND STRIP CODE OF SPACES, // actually add feddback,

/*
cards : include shop for cards, money, you will start with 3 of each card, nullify and swap will be special cards, amssing wealth, displaying card bought, displaying only cards they have, improve packs description
25 coins for winning, 50 coins for successfuly using a card
store locally, path, path provider, sql
work on quotes to show


animation of winning and shop buying
change powerup effect sound, add draw sound.
design logo
how to know if app has been closed
first time on app to give tour


wifi play : username
online play, learn future/stream builder


Update...
timed mode
more cards.
*/
