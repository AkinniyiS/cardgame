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

  class GameState extends ChangeNotifier {
  List<CardModel> cards = [];
  CardModel? firstFlippedCard;

  GameState() {
    _initializeCards();
  }

  void _initializeCards() {
    List<String> cardContents = [
      'A', 'A', 'B', 'B', 'C', 'C', 'D', 'D',
      'E', 'E', 'F', 'F', 'G', 'G', 'H', 'H',
    ];

    cardContents.shuffle();
    cards = cardContents.map((content) => CardModel(frontContent: content)).toList();
    notifyListeners();
  }

  void flipCard(CardModel card) {
    if (card.isFaceUp) return;

    card.isFaceUp = true;
    notifyListeners();

    if (firstFlippedCard == null) {
      firstFlippedCard = card;
    } else {
      _checkMatch(firstFlippedCard!, card);
      firstFlippedCard = null;
    }
  }

  void _checkMatch(CardModel firstCard, CardModel secondCard) {
    if (firstCard.frontContent == secondCard.frontContent) {
      // Match: keep them face-up
    } else {
      // No match: flip them back after a delay
      Future.delayed(const Duration(seconds: 1), () {
        firstCard.isFaceUp = false;
        secondCard.isFaceUp = false;
        notifyListeners();
      });
    }

    _checkWinCondition();
  }

  void _checkWinCondition() {
    if (cards.every((card) => card.isFaceUp)) {
      _showWinDialog();
    }
  }

  void _showWinDialog() {
    Future.delayed(const Duration(milliseconds: 300), () {
      showDialog(
        context: navigatorKey.currentContext!,
        builder: (_) => AlertDialog(
          title: const Text("You Win!"),
          content: const Text("All pairs matched!"),
          actions: [
            TextButton(
              child: const Text("Play Again"),
              onPressed: () {
                _initializeCards();
                Navigator.of(navigatorKey.currentContext!).pop();
              },
            ),
          ],
        ),
      );
    });
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
