import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameState(),
      child: MaterialApp(
        title: 'Card Matching Game',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const GameScreen(),
      ),
    );
  }
}

class GameScreen extends StatelessWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Matching Game'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, // 4x4 grid
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: gameState.cards.length,
          itemBuilder: (context, index) {
            return CardWidget(card: gameState.cards[index]);
          },
        ),
      ),
    );
  }
}

class CardWidget extends StatelessWidget {
  final CardModel card;
  const CardWidget({Key? key, required this.card}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gameState = context.read<GameState>();

    return GestureDetector(
      onTap: () {
        gameState.flipCard(card);
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) => RotationTransition(
          turns: Tween(begin: 0.5, end: 1.0).animate(animation),
          child: child,
        ),
        child: card.isFaceUp
            ? Container(
                color: Colors.blueAccent,
                child: Center(
                  child: Text(
                    card.frontContent,
                    style: const TextStyle(fontSize: 24, color: Colors.white),
                  ),
                ),
              )
            : Container(
                color: Colors.grey,
                child: const Center(
                  child: Icon(Icons.question_mark, size: 48, color: Colors.white),
                ),
              ),
      ),
    );
  }
}

class CardModel {
  final String frontContent;
  bool isFaceUp;

  CardModel({required this.frontContent, this.isFaceUp = false});
}
