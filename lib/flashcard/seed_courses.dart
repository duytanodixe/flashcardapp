import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await seedCourses();
  print('Seeding completed!');
}

Future<String?> searchUnsplashImage(String query) async {
  final unsplashAccessKey = 'Aa-0H7HA6-w1RxVu2haWIpA5k6LtlWtSQZvFhGRjWnY';
  try {
    final url = Uri.parse(
      'https://api.unsplash.com/search/photos?query=$query&per_page=1&client_id=$unsplashAccessKey'
    );
    final response = await http.get(url);
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'] != null && data['results'].isNotEmpty) {
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

Future<void> seedCourses() async {
  final firestore = FirebaseFirestore.instance;

  final defaultImage = 'assets/default.jpg';
  final imageMap = {
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

  final courses = [
    {
      'title': 'Giới thiệu bản thân',
      'description': 'Từ vựng cơ bản để giới thiệu về bản thân.',
      'words': [
        {'term': 'Name', 'definition': 'Tên'},
        {'term': 'Age', 'definition': 'Tuổi'},
        {'term': 'Student', 'definition': 'Học sinh'},
        {'term': 'Teacher', 'definition': 'Giáo viên'},
        {'term': 'Country', 'definition': 'Quốc gia'},
        {'term': 'City', 'definition': 'Thành phố'},
        {'term': 'Job', 'definition': 'Công việc'},
        {'term': 'Hobby', 'definition': 'Sở thích'},
        {'term': 'Family', 'definition': 'Gia đình'},
        {'term': 'Friend', 'definition': 'Bạn bè'},
      ],
    },
    {
      'title': 'Gia đình',
      'description': 'Từ vựng về các thành viên trong gia đình.',
      'words': [
        {'term': 'Father', 'definition': 'Bố'},
        {'term': 'Mother', 'definition': 'Mẹ'},
        {'term': 'Brother', 'definition': 'Anh trai/Em trai'},
        {'term': 'Sister', 'definition': 'Chị gái/Em gái'},
        {'term': 'Grandfather', 'definition': 'Ông'},
        {'term': 'Grandmother', 'definition': 'Bà'},
        {'term': 'Uncle', 'definition': 'Chú/Bác/Cậu'},
        {'term': 'Aunt', 'definition': 'Cô/Dì/Bác gái'},
        {'term': 'Cousin', 'definition': 'Anh chị em họ'},
        {'term': 'Child', 'definition': 'Con cái'},
      ],
    },
    {
      'title': 'Cuộc sống hàng ngày',
      'description': 'Từ vựng về các hoạt động thường ngày.',
      'words': [
        {'term': 'Wake up', 'definition': 'Thức dậy'},
        {'term': 'Eat', 'definition': 'Ăn'},
        {'term': 'Go to school', 'definition': 'Đi học'},
        {'term': 'Work', 'definition': 'Làm việc'},
        {'term': 'Play', 'definition': 'Chơi'},
        {'term': 'Read', 'definition': 'Đọc'},
        {'term': 'Write', 'definition': 'Viết'},
        {'term': 'Sleep', 'definition': 'Ngủ'},
        {'term': 'Cook', 'definition': 'Nấu ăn'},
        {'term': 'Clean', 'definition': 'Dọn dẹp'},
      ],
    },
    {
      'title': 'Mua sắm',
      'description': 'Từ vựng về mua sắm và cửa hàng.',
      'words': [
        {'term': 'Shop', 'definition': 'Cửa hàng'},
        {'term': 'Buy', 'definition': 'Mua'},
        {'term': 'Sell', 'definition': 'Bán'},
        {'term': 'Price', 'definition': 'Giá'},
        {'term': 'Money', 'definition': 'Tiền'},
        {'term': 'Discount', 'definition': 'Giảm giá'},
        {'term': 'Cashier', 'definition': 'Thu ngân'},
        {'term': 'Customer', 'definition': 'Khách hàng'},
        {'term': 'Bag', 'definition': 'Túi'},
        {'term': 'Market', 'definition': 'Chợ'},
      ],
    },
    {
      'title': 'Đồ ăn',
      'description': 'Từ vựng về thực phẩm và đồ ăn.',
      'words': [
        {'term': 'Rice', 'definition': 'Cơm'},
        {'term': 'Bread', 'definition': 'Bánh mì'},
        {'term': 'Meat', 'definition': 'Thịt'},
        {'term': 'Fish', 'definition': 'Cá'},
        {'term': 'Egg', 'definition': 'Trứng'},
        {'term': 'Vegetable', 'definition': 'Rau'},
        {'term': 'Fruit', 'definition': 'Trái cây'},
        {'term': 'Milk', 'definition': 'Sữa'},
        {'term': 'Soup', 'definition': 'Súp'},
        {'term': 'Chicken', 'definition': 'Gà'},
      ],
    },
    {
      'title': 'Sức khỏe',
      'description': 'Từ vựng về sức khỏe và y tế.',
      'words': [
        {'term': 'Doctor', 'definition': 'Bác sĩ'},
        {'term': 'Nurse', 'definition': 'Y tá'},
        {'term': 'Hospital', 'definition': 'Bệnh viện'},
        {'term': 'Medicine', 'definition': 'Thuốc'},
        {'term': 'Sick', 'definition': 'Ốm'},
        {'term': 'Healthy', 'definition': 'Khỏe mạnh'},
        {'term': 'Pain', 'definition': 'Đau'},
        {'term': 'Fever', 'definition': 'Sốt'},
        {'term': 'Injury', 'definition': 'Chấn thương'},
        {'term': 'Check-up', 'definition': 'Khám bệnh'},
      ],
    },
    {
      'title': 'Du lịch',
      'description': 'Từ vựng về du lịch và phương tiện.',
      'words': [
        {'term': 'Travel', 'definition': 'Du lịch'},
        {'term': 'Hotel', 'definition': 'Khách sạn'},
        {'term': 'Ticket', 'definition': 'Vé'},
        {'term': 'Passport', 'definition': 'Hộ chiếu'},
        {'term': 'Airport', 'definition': 'Sân bay'},
        {'term': 'Bus', 'definition': 'Xe buýt'},
        {'term': 'Train', 'definition': 'Tàu hỏa'},
        {'term': 'Map', 'definition': 'Bản đồ'},
        {'term': 'Guide', 'definition': 'Hướng dẫn viên'},
        {'term': 'Luggage', 'definition': 'Hành lý'},
      ],
    },
    {
      'title': 'Giao tiếp',
      'description': 'Từ vựng về giao tiếp cơ bản.',
      'words': [
        {'term': 'Hello', 'definition': 'Xin chào'},
        {'term': 'Goodbye', 'definition': 'Tạm biệt'},
        {'term': 'Please', 'definition': 'Làm ơn'},
        {'term': 'Thank you', 'definition': 'Cảm ơn'},
        {'term': 'Sorry', 'definition': 'Xin lỗi'},
        {'term': 'Yes', 'definition': 'Vâng'},
        {'term': 'No', 'definition': 'Không'},
        {'term': 'Excuse me', 'definition': 'Xin phép'},
        {'term': 'How are you?', 'definition': 'Bạn khỏe không?'},
        {'term': 'Fine', 'definition': 'Khỏe'},
      ],
    },
    {
      'title': 'Công việc',
      'description': 'Từ vựng về công việc và nghề nghiệp.',
      'words': [
        {'term': 'Office', 'definition': 'Văn phòng'},
        {'term': 'Manager', 'definition': 'Quản lý'},
        {'term': 'Employee', 'definition': 'Nhân viên'},
        {'term': 'Meeting', 'definition': 'Cuộc họp'},
        {'term': 'Project', 'definition': 'Dự án'},
        {'term': 'Deadline', 'definition': 'Hạn chót'},
        {'term': 'Salary', 'definition': 'Lương'},
        {'term': 'Boss', 'definition': 'Sếp'},
        {'term': 'Colleague', 'definition': 'Đồng nghiệp'},
        {'term': 'Task', 'definition': 'Nhiệm vụ'},
      ],
    },
    {
      'title': 'Trường học',
      'description': 'Từ vựng về trường học và lớp học.',
      'words': [
        {'term': 'School', 'definition': 'Trường học'},
        {'term': 'Class', 'definition': 'Lớp học'},
        {'term': 'Teacher', 'definition': 'Giáo viên'},
        {'term': 'Student', 'definition': 'Học sinh'},
        {'term': 'Lesson', 'definition': 'Bài học'},
        {'term': 'Homework', 'definition': 'Bài tập về nhà'},
        {'term': 'Exam', 'definition': 'Kỳ thi'},
        {'term': 'Book', 'definition': 'Sách'},
        {'term': 'Pen', 'definition': 'Bút'},
        {'term': 'Desk', 'definition': 'Bàn học'},
      ],
    },
  ];

  for (final course in courses) {
    final courseRef = await firestore.collection('courses').add({
      'title': course['title'],
      'description': course['description'],
      'createdAt': FieldValue.serverTimestamp(),
    });
    final words = course['words'] as List;
    for (final word in words) {
      final term = word['term'] as String;
      final key = term.toLowerCase().split(' ').first;
      
      // Tìm ảnh trong assets trước
      String? imageUrl = imageMap[key];
      
      // Nếu không có trong assets, tìm trên Unsplash
      if (imageUrl == null) {
        imageUrl = await searchUnsplashImage(term);
      }
      
      // Nếu vẫn không tìm thấy, dùng ảnh mặc định
      imageUrl ??= defaultImage;

      await firestore.collection('flashcards').add({
        'courseId': courseRef.id,
        'term': term,
        'definition': word['definition'],
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }
  print('Seeded ${courses.length} courses!');
}
