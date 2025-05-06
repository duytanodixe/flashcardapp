import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doantotnghiep/flashcard/flashcard_state.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FlashcardCubit extends Cubit<FlashcardState> {
  FlashcardCubit() : super(FlashcardInitial());

  Future<String> translateToVietnamese(String text) async {
    final url = Uri.parse('https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=vi&dt=t&q=' + Uri.encodeComponent(text));
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data[0][0][0];
    } else {
      return '';
    }
  }

  Future<void> loadDummy() async {
    emit(FlashcardLoading());
    final dummy = [
      FlashcardData(
        text: 'Boy',
        imagePath: 'assets/boy.jpg',
        voiceUrl: null,
      ),
      FlashcardData(
        text: 'Girl',
        imagePath: 'assets/girl.jpg',
        voiceUrl: null,
      ),
    ];
    // Dịch nghĩa tiếng Việt cho từng flashcard
    final translated = <FlashcardData>[];
    for (final card in dummy) {
      final meaning = await translateToVietnamese(card.text);
      translated.add(FlashcardData(
        text: card.text,
        imagePath: card.imagePath,
        voiceUrl: card.voiceUrl,
        meaning: meaning,
      ));
    }
    emit(FlashcardLoaded(translated));
  }

  Future<List<Course>> loadCourses({Map<String, int>? progress}) async {
    // Course 1: Boy & Girl
    final cards1 = [
      FlashcardData(
        text: 'Boy',
        imagePath: 'assets/boy.jpg',
        voiceUrl: null,
        meaning: await translateToVietnamese('Boy'),
      ),
      FlashcardData(
        text: 'Girl',
        imagePath: 'assets/girl.jpg',
        voiceUrl: null,
        meaning: await translateToVietnamese('Girl'),
      ),
    ];
    // Course 2: Animals
    final animalNames = [
      {'en': 'Dog', 'file': 'dog.jpg'},
      {'en': 'Cat', 'file': 'cat.jpg'},
      {'en': 'Horse', 'file': 'horse.jpg'},
      {'en': 'Cow', 'file': 'cow.jpg'},
      {'en': 'Pig', 'file': 'pig.jpg'},
      {'en': 'Sheep', 'file': 'sheep.jpg'},
      {'en': 'Goat', 'file': 'goat.jpg'},
      {'en': 'Chicken', 'file': 'chicken.jpg'},
      {'en': 'Duck', 'file': 'duck.jpg'},
      {'en': 'Rabbit', 'file': 'rabbit.jpg'},
    ];
    final cards2 = <FlashcardData>[];
    for (final animal in animalNames) {
      cards2.add(FlashcardData(
        text: animal['en']!,
        imagePath: 'assets/${animal['file']}',
        voiceUrl: null,
        meaning: await translateToVietnamese(animal['en']!),
      ));
    }
    return [
      Course(id: 'course1', name: 'Boy & Girl', cards: cards1),
      Course(id: 'course2', name: 'Animals', cards: cards2),
    ];
  }

  Future<void> loadCourse(String courseId) async {
    emit(FlashcardLoading());
    final courses = await loadCourses();
    final course = courses.firstWhere((c) => c.id == courseId);
    emit(FlashcardLoaded(course.cards));
  }
}
