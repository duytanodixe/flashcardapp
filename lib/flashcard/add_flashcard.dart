import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:doantotnghiep/flashcard/flashcard_cubit.dart';
import 'package:doantotnghiep/flashcard/flashcard_state.dart';
import 'package:doantotnghiep/flashcard/flashcard_screen.dart';

class AddFlashcardScreen extends StatefulWidget {
  @override
  _AddFlashcardScreenState createState() => _AddFlashcardScreenState();
}

class _AddFlashcardScreenState extends State<AddFlashcardScreen> {
  File? _image;
  TextEditingController _textController = TextEditingController();
  late FlutterTts _flutterTts;

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
    _flutterTts.setLanguage('vi-VN');
    _flutterTts.setSpeechRate(0.5);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _addFlashcard() {
    if (_textController.text.isNotEmpty && _image != null) {
      // Dịch tự động (ví dụ giả định dịch tiếng Việt)
      String translatedText = _textController.text + ' (nghĩa tiếng Việt)';

      // Thêm flashcard mới vào danh sách (sử dụng Cubit hoặc phương thức phù hợp)
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng nhập văn bản và chọn hình ảnh!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Thêm Flashcard')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_image != null)
              Image.file(
                _image!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              )
            else
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Chọn hình ảnh'),
              ),
            TextField(
              controller: _textController,
              decoration: InputDecoration(labelText: 'Nhập chữ tiếng Anh'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addFlashcard,
              child: Text('Thêm Flashcard'),
            ),
          ],
        ),
      ),
    );
  }
}

class CourseListScreen extends StatefulWidget {
  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  late Future<List<Course>> _coursesFuture;
  Map<String, int> _progress = {};

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  void _loadCourses() {
    setState(() {
      _coursesFuture = FlashcardCubit().loadCourses(progress: _progress);
    });
  }

  void _updateProgress(String courseId, int percent) {
    setState(() {
      _progress[courseId] = percent;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Course List')),
      body: FutureBuilder<List<Course>>(
        future: _coursesFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final courses = snapshot.data!;
          return ListView.builder(
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              final percent = _progress[course.id] ?? 0;
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text('${index + 1}'),
                  ),
                  title: Text(course.name),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final barWidth = constraints.maxWidth;
                        final percentWidth = (percent / 100) * barWidth;
                        return Stack(
                          children: [
                            Container(
                              height: 18,
                              width: barWidth,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            Container(
                              height: 18,
                              width: percentWidth,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            Positioned.fill(
                              child: Center(
                                child: Text(
                                  '$percent%',
                                  style: TextStyle(
                                    color: percent == 0 ? Colors.black : Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FlashcardScreenWithProgress(
                          courseId: course.id,
                          onProgress: (p) => _updateProgress(course.id, p),
                        ),
                      ),
                    );
                    if (result != null) _loadCourses();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class FlashcardScreenWithProgress extends StatefulWidget {
  final String courseId;
  final void Function(int percent) onProgress;
  const FlashcardScreenWithProgress({Key? key, required this.courseId, required this.onProgress}) : super(key: key);
  @override
  State<FlashcardScreenWithProgress> createState() => _FlashcardScreenWithProgressState();
}

class _FlashcardScreenWithProgressState extends State<FlashcardScreenWithProgress> {
  int _percent = 0;
  @override
  Widget build(BuildContext context) {
    return FlashcardScreen(
      courseId: widget.courseId,
      onProgress: (p) {
        setState(() => _percent = p);
        widget.onProgress(p);
      },
    );
  }
}
