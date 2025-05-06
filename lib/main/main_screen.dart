import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doantotnghiep/main/main_cubit.dart';
import 'package:doantotnghiep/main/main_state.dart';
import 'package:doantotnghiep/flashcard/flashcard_screen.dart';
import 'package:doantotnghiep/flashcard/add_flashcard.dart';
import 'package:doantotnghiep/flashcard/flashcard_tab_screen.dart';
import 'package:doantotnghiep/profile/profile_screen.dart';
import 'package:doantotnghiep/setting/setting_screen.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<MainCubit>(
      create: (_) => MainCubit(),
      child: BlocBuilder<MainCubit, MainState>(
        builder: (context, state) {
          Section current = Section.flashcard;
          if (state is MainNavigate) current = state.section;
          return Scaffold(
            appBar: AppBar(title: Text('Flashcard Demo')),
            body: _buildBody(current),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: current.index,
              items: [
                BottomNavigationBarItem(icon: Icon(Icons.style), label: 'Flashcard'),
                BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
                BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
              ],
              onTap: (i) => context.read<MainCubit>().navigateTo(Section.values[i]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(Section section) {
    switch (section) {
      case Section.flashcard:
        return FlashcardTabScreen(); // Sử dụng màn hình 2 tab mới
      case Section.profile:
        return ProfileScreen();
      case Section.settings:
        return SettingScreen();
      default:
        return Center(child: Text('Mục khác'));
    }
  }
}