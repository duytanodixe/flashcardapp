import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:doantotnghiep/flashcard/flashcard_cubit.dart';
import 'package:doantotnghiep/flashcard/flashcard_state.dart';
import 'package:doantotnghiep/flashcard/test.dart';

class FlashcardScreen extends StatefulWidget {
  final String courseId;
  final void Function(int percent)? onProgress;
  final String? courseName;
  const FlashcardScreen({Key? key, required this.courseId, this.onProgress, this.courseName}) : super(key: key);

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
  int _progressPercent = 0;

  // Thêm GlobalKey để điều khiển FlipFlashcard
  final GlobalKey<_FlipFlashcardState> _showFrontKey = GlobalKey<_FlipFlashcardState>();

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
        // Luôn hiện mặt trước khi chuyển sang thẻ mới
        _showFrontKey.currentState?.showFront();
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
      _progressPercent = ((_correctCount / (_cards.isNotEmpty ? _cards.length : 1)) * 100).round();
    });
    if (widget.onProgress != null && _cards.isNotEmpty) {
      widget.onProgress!(_progressPercent);
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
          title: Text(widget.courseName ?? _getCourseName(widget.courseId)),
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
                if (widget.courseId == 'course2') {
                  return MatchingQuizScreen(
                    cards: _cards,
                    onFinish: (correct) {
                      _onQuizFinish(correct);
                      // Quay lại màn hình chính sau khi làm xong bài thi
                      Navigator.pop(context);
                    },
                  );
                }
                return QuizScreen(
                  cards: _cards,
                  onFinish: (correct) {
                    _onQuizFinish(correct);
                    // Quay lại màn hình chính sau khi làm xong bài thi
                    Navigator.pop(context);
                  },
                );
              }
              double percent = _progressPercent / 100.0;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0, left: 16, right: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_currentIndex + 1}/${_cards.length}',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Stack(
                          children: [
                            Container(
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            Container(
                              height: 16,
                              width: MediaQuery.of(context).size.width * percent,
                              decoration: BoxDecoration(
                                color: percent == 1.0 ? Colors.green : Colors.blue,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text('${_progressPercent}%', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: FlipFlashcard(
                      key: _showFrontKey,
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

  String _getCourseName(String id) {
    switch (id) {
      case 'course1':
        return 'Boy & Girl';
      case 'course2':
        return 'Animals';
      case 'present_simple':
        return 'Present Simple';
      case 'present_continuous':
        return 'Present Continuous';
      case 'present_perfect':
        return 'Present Perfect';
      case 'past_simple':
        return 'Past Simple';
      case 'past_continuous':
        return 'Past Continuous';
      case 'past_perfect':
        return 'Past Perfect';
      case 'future_simple':
        return 'Future Simple';
      case 'future_continuous':
        return 'Future Continuous';
      case 'future_perfect':
        return 'Future Perfect';
      default:
        return 'Course';
    }
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

  void showFront() {
    if (_controller.isCompleted) {
      _controller.reverse();
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

class MatchingQuizScreen extends StatefulWidget {
  final List<FlashcardData> cards;
  final void Function(int correct) onFinish;
  const MatchingQuizScreen({Key? key, required this.cards, required this.onFinish}) : super(key: key);
  @override
  State<MatchingQuizScreen> createState() => _MatchingQuizScreenState();
}

class _MatchingQuizScreenState extends State<MatchingQuizScreen> {
  late List<String> englishWords;
  late List<String> vietnameseWords;
  Map<int, int?> matches = {}; // key: index tiếng Anh, value: index tiếng Việt
  Map<int, int?> reverseMatches = {}; // key: index tiếng Việt, value: index tiếng Anh
  int? selectedLeft;
  bool submitted = false;
  int correctCount = 0;

  @override
  void initState() {
    super.initState();
    englishWords = widget.cards.map((c) => c.text).toList();
    vietnameseWords = widget.cards.map((c) => c.meaning ?? '').toList();
    vietnameseWords.shuffle();
    for (int i = 0; i < englishWords.length; i++) {
      matches[i] = null;
    }
    for (int j = 0; j < vietnameseWords.length; j++) {
      reverseMatches[j] = null;
    }
  }

  void _selectLeft(int i) {
    if (submitted) return;
    setState(() {
      if (selectedLeft == i) {
        // Hủy chọn nếu bấm lại
        selectedLeft = null;
      } else {
        selectedLeft = i;
      }
    });
  }

  void _selectRight(int j) {
    if (submitted || selectedLeft == null) return;
    // Nếu đã nối, bấm lại để hủy nối
    if (reverseMatches[j] != null) {
      setState(() {
        int leftIdx = reverseMatches[j]!;
        matches[leftIdx] = null;
        reverseMatches[j] = null;
      });
      return;
    }
    // Nếu vế trái đã nối với vế phải khác, hủy nối cũ
    if (matches[selectedLeft!] != null) {
      setState(() {
        int oldRight = matches[selectedLeft!]!;
        reverseMatches[oldRight] = null;
      });
    }
    setState(() {
      matches[selectedLeft!] = j;
      reverseMatches[j] = selectedLeft!;
      selectedLeft = null;
    });
  }

  void _unmatchLeft(int i) {
    if (submitted) return;
    if (matches[i] != null) {
      setState(() {
        int rightIdx = matches[i]!;
        matches[i] = null;
        reverseMatches[rightIdx] = null;
      });
    }
  }

  void _submit() {
    int correct = 0;
    for (int i = 0; i < englishWords.length; i++) {
      final viIndex = matches[i];
      if (viIndex != null && vietnameseWords[viIndex] == (widget.cards[i].meaning ?? '')) {
        correct++;
      }
    }
    setState(() {
      submitted = true;
      correctCount = correct;
    });
    Future.delayed(Duration(seconds: 2), () {
      widget.onFinish(correct);
    });
  }

  Color? _getLeftColor(int i) {
    if (submitted) {
      final viIndex = matches[i];
      if (viIndex != null && vietnameseWords[viIndex] == (widget.cards[i].meaning ?? '')) {
        return Colors.green[200];
      } else if (viIndex != null) {
        return Colors.red[200];
      }
    }
    if (selectedLeft == i) return Colors.blue[100];
    return null;
  }

  Color? _getRightColor(int j) {
    if (submitted) {
      final leftIndex = reverseMatches[j];
      if (leftIndex != null && vietnameseWords[j] == (widget.cards[leftIndex].meaning ?? '')) {
        return Colors.green[200];
      } else if (leftIndex != null) {
        return Colors.red[200];
      }
    }
    return null;
  }

  Widget _buildLeftItem(int i) {
    final matchIdx = matches[i];
    return Card(
      color: _getLeftColor(i),
      child: ListTile(
        leading: Text('${i + 1}', style: TextStyle(fontWeight: FontWeight.bold)),
        title: Text(englishWords[i]),
        trailing: matchIdx != null ? CircleAvatar(radius: 12, child: Text('${matchIdx + 1}', style: TextStyle(fontSize: 12))) : null,
        onTap: () {
          if (matchIdx != null) {
            _unmatchLeft(i);
          } else {
            _selectLeft(i);
          }
        },
        selected: selectedLeft == i,
      ),
    );
  }

  Widget _buildRightItem(int j) {
    final matchIdx = reverseMatches[j];
    return Card(
      color: _getRightColor(j),
      child: ListTile(
        leading: Text('${j + 1}', style: TextStyle(fontWeight: FontWeight.bold)),
        title: Text(vietnameseWords[j]),
        trailing: matchIdx != null ? CircleAvatar(radius: 12, child: Text('${matchIdx + 1}', style: TextStyle(fontSize: 12))) : null,
        onTap: () {
          _selectRight(j);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text('Nối từ tiếng Anh với nghĩa tiếng Việt', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                // Cột tiếng Anh
                Expanded(
                  child: ListView.builder(
                    itemCount: englishWords.length,
                    itemBuilder: (context, i) => _buildLeftItem(i),
                  ),
                ),
                SizedBox(width: 16),
                // Cột tiếng Việt
                Expanded(
                  child: ListView.builder(
                    itemCount: vietnameseWords.length,
                    itemBuilder: (context, j) => _buildRightItem(j),
                  ),
                ),
              ],
            ),
          ),
          if (!submitted)
            ElevatedButton(
              onPressed: matches.values.any((v) => v == null) ? null : _submit,
              child: Text('Nộp bài'),
            ),
          if (submitted)
            Text('Đúng $correctCount/${englishWords.length}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
        ],
      ),
    );
  }
}

class GrammarQuizScreen extends StatefulWidget {
  final String tenseId;
  final String tenseName;
  final void Function(int score) onFinish;
  const GrammarQuizScreen({Key? key, required this.tenseId, required this.tenseName, required this.onFinish}) : super(key: key);
  @override
  State<GrammarQuizScreen> createState() => _GrammarQuizScreenState();
}

class _GrammarQuizScreenState extends State<GrammarQuizScreen> {
  late List<_GrammarQuestion> questions;
  int current = 0;
  int correct = 0;
  final _controller = TextEditingController();
  bool showResult = false;
  bool? isCorrect;

  @override
  void initState() {
    super.initState();
    questions = getGrammarTest(widget.tenseId);
  }

  void _submit() {
    final userAnswer = _controller.text.trim().toLowerCase();
    final correctAnswer = questions[current].answer.trim().toLowerCase();
    if (userAnswer == correctAnswer) correct++;
    setState(() {
      isCorrect = userAnswer == correctAnswer;
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (current < questions.length - 1) {
        setState(() {
          current++;
          _controller.clear();
          isCorrect = null;
        });
      } else {
        setState(() {
          showResult = true;
        });
        Future.delayed(const Duration(seconds: 2), () {
          widget.onFinish(correct);
          Navigator.pop(context);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showResult) {
      return Center(child: Text('Bạn đúng $correct/${questions.length}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.green)));
    }
    final q = questions[current];
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${widget.tenseName} - Câu ${current + 1}/${questions.length}', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          Text(q.question, style: TextStyle(fontSize: 18)),
          SizedBox(height: 16),
          TextField(
            controller: _controller,
            enabled: isCorrect == null,
            decoration: InputDecoration(
              labelText: 'Điền đáp án',
              border: OutlineInputBorder(),
              suffixIcon: isCorrect == null
                  ? null
                  : (isCorrect!
                      ? Icon(Icons.check, color: Colors.green)
                      : Icon(Icons.close, color: Colors.red)),
            ),
            onSubmitted: (_) {
              if (isCorrect == null && _controller.text.trim().isNotEmpty) _submit();
            },
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: isCorrect == null && _controller.text.trim().isNotEmpty ? _submit : null,
            child: Text(current < questions.length - 1 ? 'Tiếp' : 'Nộp bài'),
          ),
          if (isCorrect != null && !isCorrect!)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text('Đáp án đúng: ${q.answer}', style: TextStyle(color: Colors.red)),
            ),
        ],
      ),
    );
  }
}
