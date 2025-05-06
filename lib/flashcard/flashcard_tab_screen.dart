import 'package:flutter/material.dart';
import 'flashcard_screen.dart';
import 'test.dart';  // Import file test.dart

class FlashcardTabScreen extends StatefulWidget {
  @override
  State<FlashcardTabScreen> createState() => _FlashcardTabScreenState();
}

class _FlashcardTabScreenState extends State<FlashcardTabScreen> {
  // Lưu tiến trình hoàn thành từng khóa học
  final Map<String, int> _progress = {
    'course1': 0,
    'course2': 0,
  };

  // Lưu điểm bài tập trắc nghiệm cho từng thì
  final Map<String, int> _grammarScores = {};

  final List<Map<String, String>> englishTenses = [
    {'id': 'present_simple', 'name': 'Present Simple'},
    {'id': 'present_continuous', 'name': 'Present Continuous'},
    {'id': 'present_perfect', 'name': 'Present Perfect'},
    {'id': 'past_simple', 'name': 'Past Simple'},
    {'id': 'past_continuous', 'name': 'Past Continuous'},
    {'id': 'past_perfect', 'name': 'Past Perfect'},
    {'id': 'future_simple', 'name': 'Future Simple'},
    {'id': 'future_continuous', 'name': 'Future Continuous'},
    {'id': 'future_perfect', 'name': 'Future Perfect'},
  ];

  final Map<String, String> tenseFormulas = {
    'present_simple': 'S + V(s/es)',
    'present_continuous': 'S + am/is/are + V-ing',
    'present_perfect': 'S + have/has + V3/ed',
    'past_simple': 'S + V2/ed',
    'past_continuous': 'S + was/were + V-ing',
    'past_perfect': 'S + had + V3/ed',
    'future_simple': 'S + will/shall + V',
    'future_continuous': 'S + will be + V-ing',
    'future_perfect': 'S + will have + V3/ed',
  };

  void _updateProgress(String courseId, int percent) {
    setState(() {
      _progress[courseId] = percent;
    });
  }

  Widget _buildProgressBar(String courseId) {
    final percent = _progress[courseId] ?? 0;
    return Row(
      children: [
        Expanded(
          child: LinearProgressIndicator(
            value: percent / 100.0,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(percent == 100 ? Colors.green : Colors.blue),
            minHeight: 8,
          ),
        ),
        SizedBox(width: 8),
        Text('$percent%', style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: TabBar(
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(text: 'Học từ vựng'),
            Tab(text: 'Các thì tiếng Anh'),
          ],
        ),
        body: TabBarView(
          children: [
            // Tab 1: 2 course sẵn có
            ListView(
              children: [
                ListTile(
                  title: Text('Boy & Girl'),
                  subtitle: _buildProgressBar('course1'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FlashcardScreen(
                        courseId: 'course1',
                        courseName: 'Boy & Girl',
                        onProgress: (percent) => _updateProgress('course1', percent),
                      ),
                    ),
                  ),
                ),
                ListTile(
                  title: Text('Animals'),
                  subtitle: _buildProgressBar('course2'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FlashcardScreen(
                        courseId: 'course2',
                        courseName: 'Animals',
                        onProgress: (percent) => _updateProgress('course2', percent),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Tab 2: Các thì tiếng Anh
            ListView(
              children: englishTenses.map((tense) => Card(
                child: ListTile(
                  title: Text(tense['name']!),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Công thức: ${tenseFormulas[tense['id']!] ?? ''}'),
                      if (_grammarScores[tense['id']] != null)
                        Text('Điểm: ${_grammarScores[tense['id']]} / 5', 
                          style: TextStyle(
                            fontWeight: FontWeight.bold, 
                            color: _grammarScores[tense['id']] == 5 ? Colors.green : Colors.blue
                          )
                        ),
                    ],
                  ),
                  onTap: () async {
                    final score = await Navigator.push<int>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Scaffold(
                          appBar: AppBar(
                            title: Text(tense['name']!),
                          ),
                          body: GrammarQuizScreen(
                            tenseId: tense['id']!,
                            tenseName: tense['name']!,
                            onFinish: (score) {
                              Navigator.pop(context, score);
                            },
                          ),
                        ),
                      ),
                    );
                    if (score != null) {
                      setState(() {
                        _grammarScores[tense['id']!] = score;
                      });
                    }
                  },
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
