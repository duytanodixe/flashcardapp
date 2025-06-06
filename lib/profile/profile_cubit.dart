import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final _db = FirebaseFirestore.instance;
  String? _userId;

  ProfileCubit() : super(ProfileState(
    avatarUrl: 'assets/ava.jpg',
    displayName: 'Loading...',
    username: 'Loading...',
    email: 'Loading...',
    totalCards: 0,
    accuracy: 0,
    streak: 0,
    badges: [],
    createdDecks: [],
    followedDecks: [],
    socialLink: '',
    plan: 'Free',
    planExpire: 'N/A',
    weeklyProgress: [0, 0, 0, 0, 0, 0, 0],
    topicDistribution: {},
  )) {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      // Get current user ID from auth or local storage
      _userId = 'default_user'; // Replace with actual user ID
      
      // Load user profile
      final userDoc = await _db.collection('users').doc(_userId).get();
      if (userDoc.exists) {
        final data = userDoc.data()!;
        emit(ProfileState(
          avatarUrl: data['avatarUrl'] ?? 'assets/ava.jpg',
          displayName: data['displayName'] ?? 'User',
          username: data['username'] ?? 'user',
          email: data['email'] ?? '',
          totalCards: data['totalCards'] ?? 0,
          accuracy: (data['accuracy'] ?? 0).toDouble(),
          streak: data['streak'] ?? 0,
          badges: List<String>.from(data['badges'] ?? []),
          createdDecks: List<String>.from(data['createdDecks'] ?? []),
          followedDecks: List<String>.from(data['followedDecks'] ?? []),
          socialLink: data['socialLink'] ?? '',
          plan: data['plan'] ?? 'Free',
          planExpire: data['planExpire'] ?? 'N/A',
          weeklyProgress: List<int>.from(data['weeklyProgress'] ?? [0, 0, 0, 0, 0, 0, 0]),
          topicDistribution: Map<String, int>.from(data['topicDistribution'] ?? {}),
        ));
      }

      // Set up real-time listeners for user data
      _db.collection('users').doc(_userId).snapshots().listen((snapshot) {
        if (snapshot.exists) {
          final data = snapshot.data()!;
          emit(ProfileState(
            avatarUrl: data['avatarUrl'] ?? 'assets/ava.jpg',
            displayName: data['displayName'] ?? 'User',
            username: data['username'] ?? 'user',
            email: data['email'] ?? '',
            totalCards: data['totalCards'] ?? 0,
            accuracy: (data['accuracy'] ?? 0).toDouble(),
            streak: data['streak'] ?? 0,
            badges: List<String>.from(data['badges'] ?? []),
            createdDecks: List<String>.from(data['createdDecks'] ?? []),
            followedDecks: List<String>.from(data['followedDecks'] ?? []),
            socialLink: data['socialLink'] ?? '',
            plan: data['plan'] ?? 'Free',
            planExpire: data['planExpire'] ?? 'N/A',
            weeklyProgress: List<int>.from(data['weeklyProgress'] ?? [0, 0, 0, 0, 0, 0, 0]),
            topicDistribution: Map<String, int>.from(data['topicDistribution'] ?? {}),
          ));
        }
      });
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> updateProfile({
    String? displayName,
    String? username,
    String? avatarUrl,
    String? socialLink,
  }) async {
    if (_userId == null) return;

    try {
      final updates = <String, dynamic>{};
      if (displayName != null) updates['displayName'] = displayName;
      if (username != null) updates['username'] = username;
      if (avatarUrl != null) updates['avatarUrl'] = avatarUrl;
      if (socialLink != null) updates['socialLink'] = socialLink;

      await _db.collection('users').doc(_userId).update(updates);
    } catch (e) {
      print('Error updating profile: $e');
    }
  }

  Future<void> updateProgress(int cardsLearned, double accuracy) async {
    if (_userId == null) return;

    try {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final dayIndex = now.weekday - 1;

      await _db.collection('users').doc(_userId).update({
        'totalCards': FieldValue.increment(cardsLearned),
        'accuracy': accuracy,
        'weeklyProgress.$dayIndex': FieldValue.increment(cardsLearned),
      });
    } catch (e) {
      print('Error updating progress: $e');
    }
  }

  Future<void> updateStreak() async {
    if (_userId == null) return;

    try {
      final userDoc = await _db.collection('users').doc(_userId).get();
      if (!userDoc.exists) return;

      final data = userDoc.data()!;
      final lastStudyDate = (data['lastStudyDate'] as Timestamp?)?.toDate();
      final now = DateTime.now();
      
      if (lastStudyDate == null || 
          now.difference(lastStudyDate).inDays > 1) {
        // Reset streak if more than 1 day has passed
        await _db.collection('users').doc(_userId).update({
          'streak': 1,
          'lastStudyDate': now,
        });
      } else if (now.difference(lastStudyDate).inDays == 1) {
        // Increment streak if studied yesterday
        await _db.collection('users').doc(_userId).update({
          'streak': FieldValue.increment(1),
          'lastStudyDate': now,
        });
      }
    } catch (e) {
      print('Error updating streak: $e');
    }
  }
}
