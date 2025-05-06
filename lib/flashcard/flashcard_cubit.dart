import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doantotnghiep/flashcard/flashcard_state.dart';

class FlashcardCubit extends Cubit<FlashcardState> {
  FlashcardCubit() : super(FlashcardInitial());

  void loadDummy() {
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
    emit(FlashcardLoaded(dummy));
  }
}
