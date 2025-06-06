enum Section { flashcard, contextualTranslation, pronunciationChecker, profile, settings }

abstract class MainState {}
class MainInitial extends MainState {} // not used
class MainNavigate extends MainState {
  final Section section;
  MainNavigate(this.section);
}
