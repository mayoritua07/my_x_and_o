import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_x_and_o/providers/dark_mode_provider.dart';
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

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(darkModeProvider);

    return MaterialApp(
      title: 'My X and O',
      theme: ref.read(darkModeProvider) ? _darkTheme : _lightTheme,
      home: WillPopScope(
        onWillPop: () async {
          bool exitGame = false;
          await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Exit App"),
                content: const Center(
                  child: Text("Are you sure you wish to exit?"),
                ),
                actions: [
                  TextButton(
                      onPressed: () {
                        exitGame = true;
                      },
                      child: const Text("No")),
                  TextButton(
                      onPressed: () {
                        exitGame = false;
                      },
                      child: const Text("No"))
                ],
              );
            },
          );
          return exitGame;
        },
        child: const HomeScreen(),
      ),
    );
  }
}

/*
cards : include shop for cards, money, you will start with 3 of each card, nullify and swap will be special cards.
store locally, path, path provider, sql
design logo
change app name
sound effect everywhere, change powerup effect sound
optimize cards
closing app with back button
configure snack bar and feedback when cards are active and use checkbox in setup screen
add vibration on card effect

wifi play : username
online play, learn future/stream builder


Update...
timed mode
more cards.
*/
