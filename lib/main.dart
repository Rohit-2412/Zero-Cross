import 'package:flutter/material.dart';
import '../screens/multiplayer_game_screen.dart';
import '../screens/home_screen.dart';
import '../screens/single_player_game_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const HomeScreen(),
        '/multiplayer': (context) => const MultiplayerGameScreen(),
        '/singleplayer': (context) => const SinglePlayerGameScreen(),
      },
      initialRoute: '/',
    );
  }
}
