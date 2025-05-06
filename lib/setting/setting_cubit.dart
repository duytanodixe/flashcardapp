import 'package:flutter_bloc/flutter_bloc.dart';
import 'setting_state.dart';

class SettingCubit extends Cubit<SettingState> {
  SettingCubit() : super(SettingState(
    darkMode: false,
    language: 'English',
    fontSize: 16.0,
    dailyReminder: true,
    reminderTime: '20:00',
    cloudSync: true,
    exportFormat: 'CSV',
    spacedRepetition: true,
    minInterval: 1,
    maxInterval: 7,
  ));
}
