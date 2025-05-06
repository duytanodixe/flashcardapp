import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_tts/flutter_tts.dart';

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
