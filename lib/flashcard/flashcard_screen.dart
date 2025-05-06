import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:doantotnghiep/flashcard/flashcard_cubit.dart';
import 'package:doantotnghiep/flashcard/flashcard_state.dart';

class FlashcardScreen extends StatefulWidget {
  final String courseId;
  final void Function(int percent)? onProgress;
  const FlashcardScreen({Key? key, required this.courseId, this.onProgress}) : super(key: key);

  @override
  _FlashcardScreenState createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  late FlutterTts _flutterTts;
  int _currentIndex = 0;
  int _correctCount = 0;
  bool _showQuiz = false;
  List<FlashcardData> _cards = [];
  List<bool> _quizResults = [];

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
    _flutterTts.setLanguage('en-EN');
    _flutterTts.setSpeechRate(0.5);
  }

  void _nextCard() {
    setState(() {
      if (_currentIndex < _cards.length - 1) {
        _currentIndex++;
      } else {
        _showQuiz = true;
      }
    });
  }

  void _onQuizFinish(int correct) {
    setState(() {
      _correctCount = correct;
      _showQuiz = false;
      _currentIndex = 0;
    });
    if (widget.onProgress != null && _cards.isNotEmpty) {
      widget.onProgress!(((_correctCount / _cards.length) * 100).round());
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FlashcardCubit()..loadCourse(widget.courseId),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Course ${widget.courseId.replaceAll('course', '')}'),
        ),
        body: BlocBuilder<FlashcardCubit, FlashcardState>(
          builder: (context, state) {
            if (state is FlashcardLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is FlashcardError) {
              return Center(child: Text(state.message));
            } else if (state is FlashcardLoaded) {
              if (_cards.isEmpty) {
                _cards = state.cards;
                _quizResults = List.filled(_cards.length, false);
              }
              if (_showQuiz) {
                return QuizScreen(
                  cards: _cards,
                  onFinish: _onQuizFinish,
                );
              }
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Text(
                      '${_currentIndex + 1}/${_cards.length}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: FlipFlashcard(
                      card: _cards[_currentIndex],
                      tts: _flutterTts,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ElevatedButton(
                      onPressed: _nextCard,
                      child: Text(_currentIndex < _cards.length - 1 ? 'Next' : 'Kiểm tra'),
                    ),
                  ),
                ],
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

  Future<void> _speakEnglish(String text) async {
    await widget.tts.setLanguage('en-US');
    await widget.tts.speak(text);
  }

  Future<void> _speakVietnamese(String text) async {
    await widget.tts.setLanguage('vi-VN');
    await widget.tts.speak(text);
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
                  onPressed: () => _speakEnglish(widget.card.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBack() {
    final meaning = widget.card.meaning ?? '';
    return Card(
      elevation: 4,
      color: Colors.blue[50],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              meaning.isNotEmpty ? meaning : 'Đang dịch...',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: Icon(Icons.volume_up),
            onPressed: () => _speakVietnamese(meaning),
          ),
        ],
      ),
    );
  }
}

class QuizScreen extends StatefulWidget {
  final List<FlashcardData> cards;
  final void Function(int correct) onFinish;
  const QuizScreen({Key? key, required this.cards, required this.onFinish}) : super(key: key);
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _current = 0;
  int _correct = 0;
  final _controller = TextEditingController();
  bool _showResult = false;
  bool _isCorrect = false;

  void _check() {
    setState(() {
      _isCorrect = _controller.text.trim().toLowerCase() == widget.cards[_current].text.trim().toLowerCase();
      if (_isCorrect) _correct++;
      _showResult = true;
    });
  }

  void _next() {
    setState(() {
      _controller.clear();
      _showResult = false;
      _isCorrect = false;
      if (_current < widget.cards.length - 1) {
        _current++;
      } else {
        widget.onFinish(_correct);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.cards[_current];
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (card.imagePath != null)
            Image.asset(card.imagePath!, height: 180),
          SizedBox(height: 16),
          Text(card.meaning ?? '', style: TextStyle(fontSize: 20)),
          SizedBox(height: 16),
          TextField(
            controller: _controller,
            decoration: InputDecoration(labelText: 'Nhập từ tiếng Anh'),
            enabled: !_showResult,
          ),
          SizedBox(height: 16),
          if (!_showResult)
            ElevatedButton(
              onPressed: _check,
              child: Text('Kiểm tra'),
            ),
          if (_showResult)
            Column(
              children: [
                Text(_isCorrect ? 'Đúng!' : 'Sai! Đáp án: ${card.text}',
                    style: TextStyle(
                        color: _isCorrect ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _next,
                  child: Text(_current < widget.cards.length - 1 ? 'Tiếp' : 'Hoàn thành'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
