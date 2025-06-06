import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'flashcard_cubit.dart';

class AddFlashcardScreen extends StatefulWidget {
  final String courseId;
  final String courseName;

  const AddFlashcardScreen({
    Key? key,
    required this.courseId,
    required this.courseName,
  }) : super(key: key);

  @override
  _AddFlashcardScreenState createState() => _AddFlashcardScreenState();
}

class _AddFlashcardScreenState extends State<AddFlashcardScreen> {
  final _termController = TextEditingController();
  final _definitionController = TextEditingController();
  String? _imageUrl;
  bool _isLoading = false;

  @override
  void dispose() {
    _termController.dispose();
    _definitionController.dispose();
    super.dispose();
  }

  Future<void> _searchImage() async {
    if (_termController.text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final imageUrl = await context.read<FlashcardCubit>().searchImage(_termController.text);
      setState(() {
        _imageUrl = imageUrl;
        _isLoading = false;
      });
      if (imageUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không tìm thấy ảnh phù hợp')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tìm kiếm ảnh: $e')),
      );
    }
  }

  Future<void> _addFlashcard() async {
    if (_termController.text.isEmpty || _definitionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await context.read<FlashcardCubit>().addFlashcard(
        widget.courseId,
        _termController.text,
        _definitionController.text,
      );
      Navigator.pop(context, true); // Trả về true để thông báo đã thêm thành công
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi thêm flashcard: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thêm Flashcard - ${widget.courseName}'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _termController,
              decoration: InputDecoration(
                labelText: 'Từ khóa (tiếng Anh)',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() => _imageUrl = null),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _definitionController,
              decoration: InputDecoration(
                labelText: 'Nghĩa (tiếng Việt)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _searchImage,
              icon: Icon(Icons.search),
              label: Text('Tìm ảnh'),
            ),
            SizedBox(height: 16),
            if (_isLoading)
              Center(child: CircularProgressIndicator())
            else if (_imageUrl != null)
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _imageUrl!.startsWith('assets/')
                        ? Image.asset(
                            _imageUrl!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 200,
                                color: Colors.grey[300],
                                child: Center(
                                  child: Text('Không thể tải ảnh từ assets'),
                                ),
                              );
                            },
                          )
                        : Image.network(
                            _imageUrl!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 200,
                                color: Colors.grey[300],
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 200,
                                color: Colors.grey[300],
                                child: Center(
                                  child: Text('Không thể tải ảnh từ URL'),
                                ),
                              );
                            },
                          ),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _addFlashcard,
              icon: Icon(Icons.add),
              label: Text('Thêm Flashcard'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 