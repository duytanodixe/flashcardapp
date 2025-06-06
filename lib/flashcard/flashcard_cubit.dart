import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doantotnghiep/flashcard/flashcard_state.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class FlashcardCubit extends Cubit<FlashcardState> {
  FlashcardCubit() : super(FlashcardInitial());

  final _db = FirebaseFirestore.instance;
  // Thêm API key của Unsplash - bạn cần đăng ký tại https://unsplash.com/developers
  final String _unsplashAccessKey = 'Aa-0H7HA6-w1RxVu2haWIpA5k6LtlWtSQZvFhGRjWnY';

  // Map các từ khóa với đường dẫn ảnh trong assets
  final Map<String, String> _assetImageMap = {
    'dog': 'assets/dog.jpg',
    'cat': 'assets/cat.jpg',
    'boy': 'assets/boy.jpg',
    'girl': 'assets/girl.jpg',
    'chicken': 'assets/chicken.jpg',
    'cow': 'assets/cow.jpg',
    'duck': 'assets/duck.jpg',
    'goat': 'assets/goat.jpg',
    'horse': 'assets/horse.jpg',
    'pig': 'assets/pig.jpg',
    'rabbit': 'assets/rabbit.jpg',
    'sheep': 'assets/sheep.jpg',
    'ava': 'assets/ava.jpg',
  };

  // Kiểm tra xem ảnh có tồn tại trong assets không
  Future<bool> _isAssetImageExists(String path) async {
    try {
      await rootBundle.load(path);
      return true;
    } catch (e) {
      return false;
    }
  }

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

  Future<List<Course>> loadCourses({Map<String, int>? progress}) async {
    try {
      final snapshot = await _db.collection('courses').get();
      final courses = <Course>[];
      
      for (final doc in snapshot.docs) {
        final courseId = doc.id;
        final courseData = doc.data();
        
        // Lấy flashcards cho khóa học này
        final flashcardsSnapshot = await _db.collection('flashcards')
            .where('courseId', isEqualTo: courseId)
            .get();
            
        final cards = flashcardsSnapshot.docs.map((cardDoc) {
          final cardData = cardDoc.data();
          return FlashcardData(
            text: cardData['term'] ?? '',
            imagePath: cardData['imageUrl'],
            meaning: cardData['definition'],
            voiceUrl: null,
          );
        }).toList();
        
        courses.add(Course(
          id: courseId,
          name: courseData['title'] ?? 'Untitled Course',
          cards: cards,
        ));
      }
      
      return courses;
    } catch (e) {
      print('Error loading courses: $e');
      return [];
    }
  }

  Future<void> loadCourse(String courseId) async {
    emit(FlashcardLoading());
    try {
      final flashcardsSnapshot = await _db.collection('flashcards')
          .where('courseId', isEqualTo: courseId)
          .get();
          
      final cards = flashcardsSnapshot.docs.map((doc) {
        final data = doc.data();
        return FlashcardData(
          text: data['term'] ?? '',
          imagePath: data['imageUrl'],
          meaning: data['definition'],
          voiceUrl: null,
        );
      }).toList();
      
      emit(FlashcardLoaded(cards));
    } catch (e) {
      emit(FlashcardError('Lỗi tải dữ liệu: $e'));
    }
  }

  // Tìm ảnh phù hợp cho từ khóa
  Future<String?> searchImage(String query) async {
    // Chuẩn hóa query để tìm kiếm
    final normalizedQuery = query.toLowerCase().trim();
    
    // Tìm kiếm trong assetImageMap
    for (final entry in _assetImageMap.entries) {
      if (normalizedQuery.contains(entry.key)) {
        // Kiểm tra xem ảnh có tồn tại trong assets không
        if (await _isAssetImageExists(entry.value)) {
          return entry.value;
        }
      }
    }

    // Nếu không tìm thấy trong assets, tìm kiếm trên Unsplash
    try {
      final url = Uri.parse(
        'https://api.unsplash.com/search/photos?query=$query&per_page=1&client_id=$_unsplashAccessKey'
      );
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          // Lấy URL ảnh từ kết quả Unsplash
          final imageData = data['results'][0];
          if (imageData['urls'] != null && imageData['urls']['regular'] != null) {
            return imageData['urls']['regular'];
          }
        }
      }
      return null;
    } catch (e) {
      print('Error searching image: $e');
      return null;
    }
  }

  Future<void> addFlashcard(String courseId, String term, String definition) async {
    try {
      // Tìm ảnh tương ứng với từ khóa
      final imageUrl = await searchImage(term);
      
      // Thêm flashcard vào database
      await _db.collection('flashcards').add({
        'courseId': courseId,
        'term': term,
        'definition': definition,
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding flashcard: $e');
      rethrow; // Ném lỗi để UI có thể xử lý
    }
  }

  Future<String?> addCourse(String title, String description) async {
    try {
      final courseRef = await _db.collection('courses').add({
        'title': title,
        'description': description,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return courseRef.id;
    } catch (e) {
      print('Error adding course: $e');
      return null;
    }
  }
}
