import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ContextualTranslationScreen extends StatefulWidget {
  @override
  State<ContextualTranslationScreen> createState() => _ContextualTranslationScreenState();
}

class _ContextualTranslationScreenState extends State<ContextualTranslationScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _selectedWord;
  String? _literalTranslation;
  String? _contextualTranslation;
  String? _fullTranslation;
  List<String> _words = [];
  bool _loading = false;

  void _onTextChanged() {
    setState(() {
      _words = _controller.text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
      _selectedWord = null;
      _literalTranslation = null;
      _contextualTranslation = null;
      _fullTranslation = null;
    });
  }

  Future<String> _translateWithMyMemory(String text) async {
    try {
      final encodedText = Uri.encodeComponent(text);
      final url = Uri.parse(
        'https://api.mymemory.translated.net/get?q=$encodedText&langpair=en|vi'
      );
      
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String translation = data['responseData']['translatedText'];
        
        // Lấy thêm các gợi ý dịch khác nếu có
        List<String> matches = [];
        if (data['matches'] != null) {
          for (var match in data['matches']) {
            if (match['translation'] != null && 
                match['translation'] != translation &&
                !matches.contains(match['translation'])) {
              matches.add(match['translation']);
            }
            if (matches.length >= 3) break; // Chỉ lấy tối đa 3 gợi ý
          }
        }

        if (matches.isNotEmpty) {
          translation += '\n\nCác nghĩa khác:\n' + matches.join('\n');
        }
        
        return translation;
      } else {
        print('MyMemory API error: ${response.body}');
        return 'Lỗi dịch';
      }
    } catch (e) {
      print('Translation error: $e');
      return 'Lỗi dịch';
    }
  }

  Future<String> _getContextualTranslation(String word) async {
    try {
      final text = _controller.text;
      final words = text.split(RegExp(r'\s+'));
      final wordIndex = words.indexOf(word);
      
      if (wordIndex >= 0) {
        // Lấy cụm từ xung quanh (tối đa 3 từ trước và sau)
        final start = (wordIndex - 3).clamp(0, words.length);
        final end = (wordIndex + 4).clamp(0, words.length);
        final phrase = words.sublist(start, end).join(' ');
        
        // Dịch cụm từ
        return await _translateWithMyMemory(phrase);
      }
      
      return await _translateWithMyMemory(word);
    } catch (e) {
      print('Contextual translation error: $e');
      return 'Lỗi dịch';
    }
  }

  Future<void> _translateFullText() async {
    if (_controller.text.isEmpty) return;
    
    setState(() {
      _loading = true;
      _fullTranslation = null;
    });
    
    try {
      final translation = await _translateWithMyMemory(_controller.text);
      setState(() {
        _fullTranslation = translation;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _fullTranslation = 'Có lỗi xảy ra khi dịch';
        _loading = false;
      });
    }
  }

  Future<void> _translateWord(String word) async {
    setState(() {
      _loading = true;
      _literalTranslation = null;
      _contextualTranslation = null;
    });

    try {
      // Dịch nghĩa đen của từ
      final literal = await _translateWithMyMemory(word);
      
      // Dịch nghĩa trong ngữ cảnh
      final contextual = await _getContextualTranslation(word);

      setState(() {
        _literalTranslation = literal;
        _contextualTranslation = contextual;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _literalTranslation = 'Có lỗi xảy ra khi dịch';
        _contextualTranslation = 'Có lỗi xảy ra khi dịch';
        _loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nhập đoạn tiếng Anh:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              TextField(
                controller: _controller,
                minLines: 2,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Enter English text...',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _translateFullText,
                icon: Icon(Icons.translate),
                label: Text('Dịch cả đoạn'),
              ),
              if (_fullTranslation != null) ...[
                SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Bản dịch:', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text(_fullTranslation!),
                      ],
                    ),
                  ),
                ),
              ],
              SizedBox(height: 24),
              Text('Chọn từ để xem nghĩa:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              if (_words.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _words.map((word) => ChoiceChip(
                    label: Text(word),
                    selected: _selectedWord == word,
                    onSelected: (selected) {
                      setState(() => _selectedWord = selected ? word : null);
                      if (selected) {
                        _translateWord(word);
                      }
                    },
                  )).toList(),
                ),
              if (_loading) ...[
                SizedBox(height: 24),
                Center(child: CircularProgressIndicator()),
              ],
              if (_selectedWord != null && !_loading) ...[
                SizedBox(height: 24),
                Text('Từ đã chọn: $_selectedWord', 
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                ),
                SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Nghĩa đen:', 
                                style: TextStyle(fontWeight: FontWeight.bold)
                              ),
                              SizedBox(height: 8),
                              Text(_literalTranslation ?? ''),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Nghĩa trong ngữ cảnh:', 
                                style: TextStyle(fontWeight: FontWeight.bold)
                              ),
                              SizedBox(height: 8),
                              Text(_contextualTranslation ?? ''),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
