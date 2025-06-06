import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'profile_cubit.dart';
import 'profile_state.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit(),
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 24),
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundImage: AssetImage(state.avatarUrl),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(Icons.edit, color: Colors.white, size: 20),
                          onPressed: () => _showEditAvatarDialog(context),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.displayName,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit, size: 20),
                      onPressed: () => _showEditProfileDialog(context),
                    ),
                  ],
                ),
                Text('@${state.username}'),
                Text(state.email),
                Divider(),
                _buildStatCard(
                  context,
                  'Learning Stats',
                  [
                    _StatItem('Total Cards', '${state.totalCards}'),
                    _StatItem('Accuracy', '${state.accuracy.toStringAsFixed(1)}%'),
                    _StatItem('Streak', '${state.streak} days'),
                  ],
                ),
                _buildStatCard(
                  context,
                  'Achievements',
                  state.badges.map((b) => _StatItem(b, '')).toList(),
                ),
                _buildStatCard(
                  context,
                  'My Decks',
                  [
                    _StatItem('Created', state.createdDecks.join(', ')),
                    _StatItem('Following', state.followedDecks.join(', ')),
                  ],
                ),
                _buildStatCard(
                  context,
                  'Weekly Progress',
                  [
                    _StatItem(
                      '',
                      '',
                      child: SizedBox(
                        height: 60,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: state.weeklyProgress.map((v) => Expanded(
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 2),
                              height: v * 6.0,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          )).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
                _buildStatCard(
                  context,
                  'Topic Distribution',
                  state.topicDistribution.entries.map((e) => _StatItem(
                    e.key,
                    '${e.value}%',
                    child: LinearProgressIndicator(
                      value: e.value / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  )).toList(),
                ),
                SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, List<_StatItem> items) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            ...items.map((item) => Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.title.isNotEmpty)
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  if (item.subtitle.isNotEmpty)
                    Text(
                      item.subtitle,
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  if (item.child != null) ...[
                    SizedBox(height: 8),
                    item.child!,
                  ],
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditProfileDialog(BuildContext context) async {
    final cubit = context.read<ProfileCubit>();
    final state = cubit.state;
    
    final displayNameController = TextEditingController(text: state.displayName);
    final usernameController = TextEditingController(text: state.username);
    final socialLinkController = TextEditingController(text: state.socialLink);

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: displayNameController,
                decoration: InputDecoration(labelText: 'Display Name'),
              ),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: socialLinkController,
                decoration: InputDecoration(labelText: 'Social Link'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, {
              'displayName': displayNameController.text,
              'username': usernameController.text,
              'socialLink': socialLinkController.text,
            }),
            child: Text('Save'),
          ),
        ],
      ),
    );

    if (result != null) {
      await cubit.updateProfile(
        displayName: result['displayName'],
        username: result['username'],
        socialLink: result['socialLink'],
      );
    }
  }

  Future<void> _showEditAvatarDialog(BuildContext context) async {
    // TODO: Implement avatar upload functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Avatar upload coming soon!')),
    );
  }
}

class _StatItem {
  final String title;
  final String subtitle;
  final Widget? child;

  _StatItem(this.title, this.subtitle, {this.child});
}
