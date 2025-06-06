import 'package:flutter/material.dart';
import 'package:doantotnghiep/login/login_screen.dart';
import 'package:doantotnghiep/main/main_screen.dart';
import 'package:doantotnghiep/signup/signup_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void setThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flashcard Demo',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      initialRoute: '/login',
      routes: {
        '/login': (_) => LoginScreen(),
        '/main': (_) => MainScreen(
          setThemeMode: setThemeMode,
          themeMode: _themeMode,
        ),
        '/signup': (_) => SignupScreen(),
      },
    );
  }
}
