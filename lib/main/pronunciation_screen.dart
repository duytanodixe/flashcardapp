import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:string_similarity/string_similarity.dart';

class PronunciationScreen extends StatefulWidget {
  @override
  _PronunciationScreenState createState() => _PronunciationScreenState();
}

class _PronunciationScreenState extends State<PronunciationScreen> {
  final TextEditingController _textController = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  
  bool _isListening = false;
  String _recognizedText = '';
  double _accuracy = 0.0;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
    _initializeTts();
  }

  Future<void> _initializeSpeech() async {
    try {
      _isInitialized = await _speech.initialize(
        onStatus: (status) {
          print('Speech status: $status');
          if (status == 'done' || status == 'notListening') {
            setState(() {
              _isListening = false;
              if (_recognizedText.isNotEmpty) {
                _calculateAccuracy();
              }
            });
          }
        },
        onError: (error) {
          print('Speech error: $error');
          setState(() => _isListening = false);
        },
      );
      setState(() {}); // Update UI to reflect initialization status
      print('Speech initialization result: $_isInitialized');
    } catch (e) {
      print('Speech initialization error: $e');
      setState(() => _isInitialized = false);
    }
  }

  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5); // Slower speech rate for clarity
  }

  Future<void> _listen() async {
    if (!_isInitialized) {
      print('Speech not initialized');
      await _initializeSpeech();
      if (!_isInitialized) return;
    }

    if (!_isListening) {
      setState(() => _isListening = true);
      try {
        await _speech.listen(
          onResult: (result) {
            setState(() {
              _recognizedText = result.recognizedWords;
              print('Recognized text: $_recognizedText');
            });
          },
          localeId: 'en_US',
          listenMode: stt.ListenMode.confirmation,
        );
      } catch (e) {
        print('Listen error: $e');
        setState(() => _isListening = false);
      }
    } else {
      setState(() => _isListening = false);
      await _speech.stop();
    }
  }

  Future<void> _speak() async {
    if (_textController.text.isNotEmpty) {
      await _flutterTts.speak(_textController.text);
    }
  }

  void _calculateAccuracy() {
    if (_recognizedText.isEmpty || _textController.text.isEmpty) {
      setState(() => _accuracy = 0.0);
      return;
    }

    // Normalize texts for comparison
    final String normalizedInput = _textController.text.toLowerCase().trim();
    final String normalizedRecognized = _recognizedText.toLowerCase().trim();

    // Calculate similarity using string_similarity package
    double similarity = normalizedInput.similarityTo(normalizedRecognized);
    
    setState(() => _accuracy = similarity * 100);
  }

  @override
  void dispose() {
    _textController.dispose();
    _speech.cancel();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Nhập văn bản để luyện phát âm:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _textController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Enter text to practice...',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _speak,
                icon: Icon(Icons.volume_up),
                label: Text('Nghe phát âm chuẩn'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 45),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _isInitialized ? _listen : null,
                icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
                label: Text(_isListening ? 'Dừng ghi âm' : 'Bắt đầu ghi âm'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isListening ? Colors.red : Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 45),
                ),
              ),
              SizedBox(height: 24),
              if (_recognizedText.isNotEmpty) ...[
                Text(
                  'Văn bản được nhận diện:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(_recognizedText),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Độ chính xác: ${_accuracy.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _accuracy > 80 ? Colors.green : 
                           _accuracy > 60 ? Colors.orange : Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (_isListening)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 8),
                      Text('Đang lắng nghe...'),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
} 