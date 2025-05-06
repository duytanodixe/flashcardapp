class FlashcardData {
  final String text;
  final String? imagePath;
  final String? voiceUrl;
  final String? meaning; // nghĩa tiếng Việt

  FlashcardData({
    required this.text,
    this.imagePath,
    this.voiceUrl,
    this.meaning,
  });
}

class Course {
  final String id;
  final String name;
  final List<FlashcardData> cards;

  Course({required this.id, required this.name, required this.cards});
}

abstract class FlashcardState {}
class FlashcardInitial extends FlashcardState {}
class FlashcardLoading extends FlashcardState {}
class FlashcardLoaded extends FlashcardState {
  final List<FlashcardData> cards;
  FlashcardLoaded(this.cards);
}
class FlashcardError extends FlashcardState {
  final String message;
  FlashcardError(this.message);
}
