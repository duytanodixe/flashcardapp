import 'package:flutter_bloc/flutter_bloc.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileState(
    avatarUrl: 'assets/ava.jpg',
    displayName: 'Hoàng Minh',
    username: 'map',
    email: 'minh@gmail.com',
    totalCards: 123,
    accuracy: 87.5,
    streak: 8,
    badges: ['100 cards', '7-day streak', 'Completed a deck'],
    createdDecks: ['Animals', 'Math'],
    followedDecks: ['English', 'Science'],
    socialLink: 'Google',
    plan: 'Free',
    planExpire: 'N/A',
    weeklyProgress: [2, 4, 6, 8, 10, 7, 5],
    topicDistribution: {'Math': 30, 'English': 50, 'Science': 20},
  ));
}
