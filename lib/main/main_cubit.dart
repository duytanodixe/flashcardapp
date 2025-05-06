import 'package:bloc/bloc.dart';
import 'package:doantotnghiep/main/main_state.dart';

class MainCubit extends Cubit<MainState> {
  MainCubit() : super(MainNavigate(Section.flashcard));

  void navigateTo(Section section) {
    emit(MainNavigate(section));
  }
}
