import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'setting_cubit.dart';
import 'setting_state.dart';

class SettingScreen extends StatefulWidget {
  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool fakeSwitch = false;
  String fakeDropdown = 'Light';
  double fakeSlider = 16.0;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _SectionTitle('Account & Security'),
        _SimpleTile('Change Password', onTap: () => _showSnack('Change Password')),
        _SimpleTile('Change Email', onTap: () => _showSnack('Change Email')),
        _SwitchTile('2FA', value: fakeSwitch, onChanged: (v) => setState(() => fakeSwitch = v)),
        _SimpleTile('Logout', onTap: () => _showSnack('Logout')),
        _SimpleTile('Delete Account', onTap: () => _showSnack('Delete Account')),
        Divider(),
        _SectionTitle('Appearance & Personalization'),
        _DropdownTile('Theme', value: fakeDropdown, items: ['Light','Dark','System'], onChanged: (v) => setState(() => fakeDropdown = v)),
        _SliderTile('Font Size', value: fakeSlider, min: 12, max: 24, onChanged: (v) => setState(() => fakeSlider = v)),
        Divider(),
        _SectionTitle('Notifications'),
        _SwitchTile('Daily Reminder', value: fakeSwitch, onChanged: (v) => setState(() => fakeSwitch = v)),
        _SimpleTile('Reminder Time: 20:00', onTap: () => _showSnack('Change Reminder Time')),
        Divider(),
        _SectionTitle('Sync & Backup'),
        _SwitchTile('Cloud Sync', value: fakeSwitch, onChanged: (v) => setState(() => fakeSwitch = v)),
        _SimpleTile('Delete Local Data', onTap: () => _showSnack('Delete Local Data')),
        Divider(),
        _SectionTitle('Learning & Algorithm'),
        _SwitchTile('Spaced Repetition', value: fakeSwitch, onChanged: (v) => setState(() => fakeSwitch = v)),
        _SimpleTile('Min Interval: 1 days', onTap: () => _showSnack('Change Min Interval')),
        _SimpleTile('Max Interval: 7 days', onTap: () => _showSnack('Change Max Interval')),
        Divider(),
        _SectionTitle('Help & Info'),
        _SimpleTile('User Guide', onTap: () => _showSnack('User Guide')),
        _SimpleTile('Feedback/Bug Report', onTap: () => _showSnack('Feedback/Bug Report')),
        _SimpleTile('About & Version: v1.0.0', onTap: () => _showSnack('About & Version')),
        _SimpleTile('Terms & Privacy', onTap: () => _showSnack('Terms & Privacy')),
      ],
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Text(text, style: TextStyle(fontWeight: FontWeight.bold)),
  );
}

class _SimpleTile extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  const _SimpleTile(this.text, {this.onTap});
  @override
  Widget build(BuildContext context) => ListTile(title: Text(text), onTap: onTap);
}

class _SwitchTile extends StatelessWidget {
  final String text;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchTile(this.text, {required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) => ListTile(
    title: Text(text),
    trailing: Switch(value: value, onChanged: onChanged),
  );
}

class _DropdownTile extends StatelessWidget {
  final String text;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;
  const _DropdownTile(this.text, {required this.value, required this.items, required this.onChanged});
  @override
  Widget build(BuildContext context) => ListTile(
    title: Text(text),
    trailing: DropdownButton<String>(
      value: value,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    ),
  );
}

class _SliderTile extends StatelessWidget {
  final String text;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  const _SliderTile(this.text, {required this.value, required this.min, required this.max, required this.onChanged});
  @override
  Widget build(BuildContext context) => ListTile(
    title: Text(text),
    subtitle: Slider(value: value, min: min, max: max, onChanged: onChanged),
  );
}
