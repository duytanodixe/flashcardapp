import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SettingScreen extends StatefulWidget {
  final void Function(ThemeMode)? setThemeMode;
  final ThemeMode? themeMode;
  SettingScreen({this.setThemeMode, this.themeMode});
  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  String _theme = 'Light';
  bool _dailyReminder = false;
  String _reminderTime = '20:00';
  bool _cloudSync = false;
  bool _spacedRepetition = false;
  int _minInterval = 1;
  int _maxInterval = 7;

  final _db = FirebaseFirestore.instance;
  String? _userEmail;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _userEmail = 'a4@gmail.com';
    _userId = 'default_user';
    _loadSettings();
    if (widget.themeMode == ThemeMode.dark) _theme = 'Dark';
    else _theme = 'Light';
  }

  Future<void> _loadSettings() async {
    final doc = await _db.collection('settings').doc(_userId).get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        _theme = data['theme'] ?? _theme;
        _dailyReminder = data['dailyReminder'] ?? false;
        _reminderTime = data['reminderTime'] ?? '20:00';
        _cloudSync = data['cloudSync'] ?? false;
        _spacedRepetition = data['spacedRepetition'] ?? false;
        _minInterval = data['minInterval'] ?? 1;
        _maxInterval = data['maxInterval'] ?? 7;
      });
    }
  }

  Future<void> _saveSettings() async {
    await _db.collection('settings').doc(_userId).set({
      'theme': _theme,
      'dailyReminder': _dailyReminder,
      'reminderTime': _reminderTime,
      'cloudSync': _cloudSync,
      'spacedRepetition': _spacedRepetition,
      'minInterval': _minInterval,
      'maxInterval': _maxInterval,
    });
  }

  Future<void> _changePassword() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change Password'),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: InputDecoration(labelText: 'New Password'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, controller.text), child: Text('OK')),
        ],
      ),
    );
    if (result != null && result.isNotEmpty && _userEmail != null) {
      // Update password in Firestore
      final snap = await _db.collection('users').where('email', isEqualTo: _userEmail).get();
      if (snap.docs.isNotEmpty) {
        await _db.collection('users').doc(snap.docs.first.id).update({'password': result});
        _showSnack('Đổi mật khẩu thành công!');
      }
    }
  }

  Future<void> _changeEmail() async {
    final controller = TextEditingController(text: _userEmail ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change Email'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: 'New Email'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, controller.text), child: Text('OK')),
        ],
      ),
    );
    if (result != null && result.isNotEmpty && _userEmail != null) {
      // Update email in Firestore
      final snap = await _db.collection('users').where('email', isEqualTo: _userEmail).get();
      if (snap.docs.isNotEmpty) {
        await _db.collection('users').doc(snap.docs.first.id).update({'email': result});
        setState(() => _userEmail = result);
        _showSnack('Đổi email thành công!');
      }
    }
  }

  void _logout() async {
    // Xóa userId/email local (ở đây chỉ set null, thực tế nên dùng shared_preferences)
    setState(() {
      _userEmail = null;
      _userId = null;
    });
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _SectionTitle('Account & Security'),
        _SimpleTile('Change Password', onTap: _changePassword),
        _SimpleTile('Change Email', onTap: _changeEmail),
        _SimpleTile('Logout', onTap: _logout),
        Divider(),
        _SectionTitle('Appearance & Personalization'),
        _DropdownTile('Theme', value: _theme, items: ['Light','Dark'], onChanged: (v) async {
          setState(() {
            _theme = v;
            if (widget.setThemeMode != null) {
              if (v == 'Light') widget.setThemeMode!(ThemeMode.light);
              else widget.setThemeMode!(ThemeMode.dark);
            }
          });
          await _saveSettings();
        }),
        Divider(),
        _SectionTitle('Notifications'),
        _SwitchTile('Daily Reminder', value: _dailyReminder, onChanged: (v) async {
          setState(() => _dailyReminder = v);
          await _saveSettings();
        }),
        _SimpleTile('Reminder Time: $_reminderTime', onTap: () async {
          final t = await showTimePicker(context: context, initialTime: TimeOfDay(hour: int.parse(_reminderTime.split(':')[0]), minute: int.parse(_reminderTime.split(':')[1])));
          if (t != null) {
            setState(() => _reminderTime = '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}');
            await _saveSettings();
          }
        }),
        Divider(),
        _SectionTitle('Sync & Backup'),
        _SwitchTile('Cloud Sync', value: _cloudSync, onChanged: (v) async {
          setState(() => _cloudSync = v);
          await _saveSettings();
        }),
        _SimpleTile('Delete Local Data', onTap: () => _showSnack('Delete Local Data')),
        Divider(),
        _SectionTitle('Learning & Algorithm'),
        _SwitchTile('Spaced Repetition', value: _spacedRepetition, onChanged: (v) async {
          setState(() => _spacedRepetition = v);
          await _saveSettings();
        }),
        _SimpleTile('Min Interval: $_minInterval days', onTap: () async {
          final v = await _showNumberInput('Min Interval', _minInterval);
          if (v != null) {
            setState(() => _minInterval = v);
            await _saveSettings();
          }
        }),
        _SimpleTile('Max Interval: $_maxInterval days', onTap: () async {
          final v = await _showNumberInput('Max Interval', _maxInterval);
          if (v != null) {
            setState(() => _maxInterval = v);
            await _saveSettings();
          }
        }),
        Divider(),
        _SectionTitle('Help & Info'),
        _SimpleTile('User Guide', onTap: () => _showDialog('User Guide', 'Hướng dẫn sử dụng:\n\n- Đăng nhập hoặc đăng ký tài khoản.\n- Thêm flashcard mới ở tab Flashcard.\n- Ôn tập và kiểm tra tiến độ học tập ở tab Profile.\n- Tuỳ chỉnh cài đặt tại tab Settings.')),
        _SimpleTile('Feedback/Bug Report', onTap: () => _showDialog('Feedback & Bug Report', 'Nếu bạn gặp lỗi hoặc có góp ý, vui lòng gửi email tới: support@flashcardapp.com hoặc điền vào form phản hồi trên website.')),
        _SimpleTile('About & Version: v1.0.0', onTap: () => _showDialog('About', 'FlashcardApp v1.0.0\n\nỨng dụng hỗ trợ học tập qua flashcard, phát triển bởi nhóm doantotnghiep.')),
        _SimpleTile('Terms & Privacy', onTap: () => _showDialog('Terms & Privacy', 'Chúng tôi cam kết bảo vệ thông tin cá nhân của bạn. Dữ liệu chỉ dùng cho mục đích học tập và không chia sẻ cho bên thứ ba.')),
      ],
    );
  }

  Future<int?> _showNumberInput(String title, int current) async {
    final controller = TextEditingController(text: current.toString());
    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, int.tryParse(controller.text)), child: Text('OK')),
        ],
      ),
    );
    return result;
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('OK'))],
      ),
    );
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
