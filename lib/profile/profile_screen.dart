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
                CircleAvatar(
                  radius: 48,
                  backgroundImage: AssetImage('assets/ava.jpg'),
                ),
                TextButton(onPressed: () {}, child: Text('Change Avatar')),
                SizedBox(height: 8),
                Text(state.displayName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text('@${state.username}'),
                Text(state.email),
                Divider(),
                ListTile(
                  title: Text('Total Cards Learned'),
                  trailing: Text('${state.totalCards}'),
                ),
                ListTile(
                  title: Text('Accuracy'),
                  trailing: Text('${state.accuracy.toStringAsFixed(1)}%'),
                ),
                ListTile(
                  title: Text('Streak'),
                  trailing: Text('${state.streak} days'),
                ),
                Divider(),
                ListTile(
                  title: Text('Badges'),
                  subtitle: Wrap(
                    spacing: 8,
                    children: state.badges.map((b) => Chip(label: Text(b))).toList(),
                  ),
                ),
                Divider(),
                ListTile(
                  title: Text('Created Decks'),
                  subtitle: Text(state.createdDecks.join(', ')),
                ),
                ListTile(
                  title: Text('Followed Decks'),
                  subtitle: Text(state.followedDecks.join(', ')),
                ),
                Divider(),
                ListTile(
                  title: Text('Social Link'),
                  trailing: Text(state.socialLink),
                ),
                Divider(),
                ListTile(
                  title: Text('Plan'),
                  subtitle: Text('${state.plan} (Expire: ${state.planExpire})'),
                  trailing: ElevatedButton(onPressed: () {}, child: Text('Upgrade')),
                ),
                Divider(),
                ListTile(
                  title: Text('Weekly Progress'),
                  subtitle: SizedBox(
                    height: 60,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: state.weeklyProgress.map((v) => Expanded(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 2),
                          height: v * 6.0,
                          color: Colors.blue,
                        ),
                      )).toList(),
                    ),
                  ),
                ),
                ListTile(
                  title: Text('Topic Distribution'),
                  subtitle: Row(
                    children: state.topicDistribution.entries.map((e) => Expanded(
                      child: Column(
                        children: [
                          Text(e.key),
                          SizedBox(height: 4),
                          LinearProgressIndicator(value: e.value / 100),
                        ],
                      ),
                    )).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
