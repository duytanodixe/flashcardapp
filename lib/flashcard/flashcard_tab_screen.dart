import 'package:flutter/material.dart';
import 'flashcard_screen.dart';

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

  void _updateProgress(String courseId, int percent) {
    setState(() {
      _progress[courseId] = percent;
    });
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
              children: englishTenses.map((tense) => ListTile(
                title: Text(tense['name']!),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FlashcardScreen(courseId: tense['id']!, courseName: tense['name']),
                  ),
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
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
}
