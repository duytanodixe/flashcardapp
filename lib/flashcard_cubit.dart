import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:doantotnghiep/flashcard/flashcard_cubit.dart';
import 'package:doantotnghiep/flashcard/flashcard_state.dart';

class FlashcardScreen extends StatefulWidget {
  @override
  _FlashcardScreenState createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  late FlutterTts _flutterTts;

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
    _flutterTts.setLanguage('vi-VN');
    _flutterTts.setSpeechRate(0.5);
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FlashcardCubit()..loadDummy(),
      child: Scaffold(
        appBar: AppBar(title: Text('Flashcards Demo')),
        body: BlocBuilder<FlashcardCubit, FlashcardState>(
          builder: (context, state) {
            if (state is FlashcardLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is FlashcardError) {
              return Center(child: Text(state.message));
            } else if (state is FlashcardLoaded) {
              return PageView.builder(
                itemCount: state.cards.length,
                itemBuilder: (context, index) {
                  return Center(
                    child: FractionallySizedBox(
                      widthFactor: 0.9,
                      heightFactor: 0.7,
                      child: FlipFlashcard(
                        card: state.cards[index],
                        tts: _flutterTts,
                      ),
                    ),
                  );
                },
              );
            }
            return SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class FlipFlashcard extends StatefulWidget {
  final FlashcardData card;
  final FlutterTts tts;

  const FlipFlashcard({Key? key, required this.card, required this.tts}) : super(key: key);

  @override
  _FlipFlashcardState createState() => _FlipFlashcardState();
}

class _FlipFlashcardState extends State<FlipFlashcard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
  }

  void _toggleCard() {
    if (_controller.isCompleted) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Constrain flip area to parent size
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTap: _toggleCard,
          child: SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                double angle = _controller.value * pi;
                final transform = Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(angle);
                Widget face;
                if (angle <= pi / 2) {
                  face = _buildFront();
                } else {
                  face = Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(pi),
                    alignment: Alignment.center,
                    child: _buildBack(),
                  );
                }
                return Transform(
                  transform: transform,
                  alignment: Alignment.center,
                  child: face,
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildFront() {
    return Card(
      elevation: 4,
      child: Column(
        children: [
          Expanded(
            child: widget.card.imagePath != null
                ? Image.asset(
                    widget.card.imagePath!,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : SizedBox.shrink(),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.card.text,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.volume_up),
                  onPressed: () => widget.tts.speak(widget.card.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBack() {
    final meaning = widget.card.text + ' (nghĩa tiếng Việt)';
    return Card(
      elevation: 4,
      color: Colors.blue[50],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              meaning,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: Icon(Icons.volume_up),
            onPressed: () => widget.tts.speak(meaning),
          ),
        ],
      ),
    );
  }
}