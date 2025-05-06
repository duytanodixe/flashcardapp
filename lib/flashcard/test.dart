// Định nghĩa model cho câu hỏi điền vào chỗ trống
class GrammarTestQuestion {
  final String question;
  final String answer;
  GrammarTestQuestion(this.question, this.answer);
}

// Map id thì -> danh sách câu hỏi
final Map<String, List<GrammarTestQuestion>> grammarTestBank = {
  'present_simple': [
    GrammarTestQuestion('She ___ to school every day. (go)', 'goes'),
    GrammarTestQuestion('I ___ coffee in the morning. (drink)', 'drink'),
    GrammarTestQuestion('They ___ football on Sundays. (play)', 'play'),
    GrammarTestQuestion('He ___ not like fish. (do)', 'does'),
    GrammarTestQuestion('We ___ English. (study)', 'study'),
  ],
  'present_continuous': [
    GrammarTestQuestion('She ___ TV now. (watch)', 'is watching'),
    GrammarTestQuestion('I ___ to music at the moment. (listen)', 'am listening'),
    GrammarTestQuestion('They ___ football. (play)', 'are playing'),
    GrammarTestQuestion('He ___ not sleeping. (be)', 'is'),
    GrammarTestQuestion('We ___ dinner. (have)', 'are having'),
  ],
  'present_perfect': [
    GrammarTestQuestion('She ___ finished her homework. (have)', 'has'),
    GrammarTestQuestion('I ___ never been to Japan. (have)', 'have'),
    GrammarTestQuestion('They ___ already left. (have)', 'have'),
    GrammarTestQuestion('He ___ just eaten. (have)', 'has'),
    GrammarTestQuestion('We ___ lived here for 5 years. (have)', 'have'),
  ],
  'past_simple': [
    GrammarTestQuestion('She ___ to school yesterday. (go)', 'went'),
    GrammarTestQuestion('I ___ coffee this morning. (drink)', 'drank'),
    GrammarTestQuestion('They ___ football last Sunday. (play)', 'played'),
    GrammarTestQuestion('He ___ not like fish. (do)', 'did'),
    GrammarTestQuestion('We ___ English. (study)', 'studied'),
  ],
  'past_continuous': [
    GrammarTestQuestion('She ___ TV when I came. (watch)', 'was watching'),
    GrammarTestQuestion('I ___ to music at 8pm. (listen)', 'was listening'),
    GrammarTestQuestion('They ___ football. (play)', 'were playing'),
    GrammarTestQuestion('He ___ not sleeping. (be)', 'was'),
    GrammarTestQuestion('We ___ dinner. (have)', 'were having'),
  ],
  'past_perfect': [
    GrammarTestQuestion('She ___ finished her homework before dinner. (have)', 'had'),
    GrammarTestQuestion('I ___ never been to Japan before 2010. (have)', 'had'),
    GrammarTestQuestion('They ___ already left when I arrived. (have)', 'had'),
    GrammarTestQuestion('He ___ just eaten before you called. (have)', 'had'),
    GrammarTestQuestion('We ___ lived there for 5 years before moving. (have)', 'had'),
  ],
  'future_simple': [
    GrammarTestQuestion('She ___ go to school tomorrow. (will)', 'will'),
    GrammarTestQuestion('I ___ help you. (will)', 'will'),
    GrammarTestQuestion('They ___ play football next week. (will)', 'will'),
    GrammarTestQuestion('He ___ not like fish. (will)', 'will'),
    GrammarTestQuestion('We ___ study English. (will)', 'will'),
  ],
  'future_continuous': [
    GrammarTestQuestion('She ___ be watching TV at 8pm. (will)', 'will'),
    GrammarTestQuestion('I ___ be listening to music. (will)', 'will'),
    GrammarTestQuestion('They ___ be playing football. (will)', 'will'),
    GrammarTestQuestion('He ___ not be sleeping. (will)', 'will'),
    GrammarTestQuestion('We ___ be having dinner. (will)', 'will'),
  ],
  'future_perfect': [
    GrammarTestQuestion('She ___ have finished her homework by 8pm. (will)', 'will'),
    GrammarTestQuestion('I ___ have never been to Japan by then. (will)', 'will'),
    GrammarTestQuestion('They ___ have already left. (will)', 'will'),
    GrammarTestQuestion('He ___ not have eaten. (will)', 'will'),
    GrammarTestQuestion('We ___ have lived here for 5 years. (will)', 'will'),
  ],
};

// Hàm lấy danh sách câu hỏi cho 1 thì
List<GrammarTestQuestion> getGrammarTest(String tenseId) {
  return grammarTestBank[tenseId] ?? [];
}
