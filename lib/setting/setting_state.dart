class SettingState {
  final bool darkMode;
  final String language;
  final double fontSize;
  final bool dailyReminder;
  final String reminderTime;
  final bool cloudSync;
  final String exportFormat;
  final bool spacedRepetition;
  final int minInterval;
  final int maxInterval;
  SettingState({
    required this.darkMode,
    required this.language,
    required this.fontSize,
    required this.dailyReminder,
    required this.reminderTime,
    required this.cloudSync,
    required this.exportFormat,
    required this.spacedRepetition,
    required this.minInterval,
    required this.maxInterval,
  });
}
