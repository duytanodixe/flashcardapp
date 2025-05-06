import 'package:flutter/material.dart';
import 'package:doantotnghiep/login/login_screen.dart';
import 'package:doantotnghiep/main/main_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flashcard Demo',
      initialRoute: '/login',
      routes: {
        '/login': (_) => LoginScreen(),
        '/main': (_) => MainScreen(),
      },
    );
  }
}
