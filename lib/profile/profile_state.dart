class ProfileState {
  final String avatarUrl;
  final String displayName;
  final String username;
  final String email;
  final int totalCards;
  final double accuracy;
  final int streak;
  final List<String> badges;
  final List<String> createdDecks;
  final List<String> followedDecks;
  final String socialLink;
  final String plan;
  final String planExpire;
  final List<int> weeklyProgress;
  final Map<String, int> topicDistribution;
  ProfileState({
    required this.avatarUrl,
    required this.displayName,
    required this.username,
    required this.email,
    required this.totalCards,
    required this.accuracy,
    required this.streak,
    required this.badges,
    required this.createdDecks,
    required this.followedDecks,
    required this.socialLink,
    required this.plan,
    required this.planExpire,
    required this.weeklyProgress,
    required this.topicDistribution,
  });
}
