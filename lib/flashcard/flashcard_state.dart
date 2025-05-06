class FlashcardData {
  final String text;
  final String? imagePath;
  final String? voiceUrl;

  FlashcardData({
    required this.text,
    this.imagePath,
    this.voiceUrl,
  });
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
