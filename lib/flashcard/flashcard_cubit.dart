import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doantotnghiep/flashcard/flashcard_state.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class FlashcardCubit extends Cubit<FlashcardState> {
  FlashcardCubit() : super(FlashcardInitial());

  final _db = FirebaseFirestore.instance;

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

  Future<void> seedSampleData() async {
    // Kiểm tra nếu đã có dữ liệu thì không seed nữa
    final snapshot = await _db.collection('flashcards').get();
    if (snapshot.docs.isNotEmpty) return;
    // Dữ liệu mẫu
    final data = [
      {'text': 'Boy', 'imagePath': 'assets/boy.jpg'},
      {'text': 'Girl', 'imagePath': 'assets/girl.jpg'},
      {'text': 'Dog', 'imagePath': 'assets/dog.jpg'},
      {'text': 'Cat', 'imagePath': 'assets/cat.jpg'},
      {'text': 'Horse', 'imagePath': 'assets/horse.jpg'},
      {'text': 'Cow', 'imagePath': 'assets/cow.jpg'},
      {'text': 'Pig', 'imagePath': 'assets/pig.jpg'},
      {'text': 'Sheep', 'imagePath': 'assets/sheep.jpg'},
      {'text': 'Goat', 'imagePath': 'assets/goat.jpg'},
      {'text': 'Chicken', 'imagePath': 'assets/chicken.jpg'},
      {'text': 'Duck', 'imagePath': 'assets/duck.jpg'},
      {'text': 'Rabbit', 'imagePath': 'assets/rabbit.jpg'},
    ];
    for (final card in data) {
      final meaning = await translateToVietnamese(card['text']!);
      await _db.collection('flashcards').add({
        'text': card['text'],
        'imagePath': card['imagePath'],
        'meaning': meaning,
      });
    }
  }

  Future<void> loadAllFromFirestore() async {
    emit(FlashcardLoading());
    try {
      await seedSampleData();
      final snapshot = await _db.collection('flashcards').get();
      final cards = snapshot.docs.map((doc) => FlashcardData(
        text: doc['text'],
        imagePath: doc['imagePath'],
        meaning: doc['meaning'],
        voiceUrl: null,
      )).toList();
      emit(FlashcardLoaded(cards));
    } catch (e) {
      emit(FlashcardError('Lỗi tải dữ liệu: $e'));
    }
  }

  Future<List<Course>> loadCourses({Map<String, int>? progress}) async {
    await seedSampleData();
    final snapshot = await _db.collection('flashcards').get();
    // Group cards theo course
    final course1Names = ['Boy', 'Girl'];
    final course2Names = ['Dog', 'Cat', 'Horse', 'Cow', 'Pig', 'Sheep', 'Goat', 'Chicken', 'Duck', 'Rabbit'];
    final cards1 = <FlashcardData>[];
    final cards2 = <FlashcardData>[];
    for (final doc in snapshot.docs) {
      final card = FlashcardData(
        text: doc['text'],
        imagePath: doc['imagePath'],
        meaning: doc['meaning'],
        voiceUrl: null,
      );
      if (course1Names.contains(card.text)) {
        cards1.add(card);
      } else if (course2Names.contains(card.text)) {
        cards2.add(card);
      }
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
