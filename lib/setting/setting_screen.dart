import 'package:flutter/material.dart';

class SettingScreen extends StatefulWidget {
  final void Function(ThemeMode)? setThemeMode;
  final ThemeMode? themeMode;
  SettingScreen({this.setThemeMode, this.themeMode});
  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  double _fontSize = 16.0;
  bool fakeSwitch = false;
  String fakeDropdown = 'Light';

  @override
  void initState() {
    super.initState();
    if (widget.themeMode == ThemeMode.dark) fakeDropdown = 'Dark';
    else fakeDropdown = 'Light';
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(fontSizeFactor: _fontSize / 16.0),
      ),
      child: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _SectionTitle('Account & Security'),
          _SimpleTile('Change Password', onTap: () => _showSnack('Change Password')),
          _SimpleTile('Change Email', onTap: () => _showSnack('Change Email')),
          _SimpleTile('Logout', onTap: () => _showSnack('Logout')),
          Divider(),
          _SectionTitle('Appearance & Personalization'),
          _DropdownTile('Theme', value: fakeDropdown, items: ['Light','Dark'], onChanged: (v) {
            setState(() {
              fakeDropdown = v;
              if (widget.setThemeMode != null) {
                if (v == 'Light') widget.setThemeMode!(ThemeMode.light);
                else widget.setThemeMode!(ThemeMode.dark);
              }
            });
          }),
          _SliderTile('Font Size', value: _fontSize, min: 12, max: 24, onChanged: (v) => setState(() => _fontSize = v)),
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
          _SimpleTile('User Guide', onTap: () => _showDialog('User Guide', 'Hướng dẫn sử dụng:\n\n- Đăng nhập hoặc đăng ký tài khoản.\n- Thêm flashcard mới ở tab Flashcard.\n- Ôn tập và kiểm tra tiến độ học tập ở tab Profile.\n- Tuỳ chỉnh cài đặt tại tab Settings.')),
          _SimpleTile('Feedback/Bug Report', onTap: () => _showDialog('Feedback & Bug Report', 'Nếu bạn gặp lỗi hoặc có góp ý, vui lòng gửi email tới: support@flashcardapp.com hoặc điền vào form phản hồi trên website.')),
          _SimpleTile('About & Version: v1.0.0', onTap: () => _showDialog('About', 'FlashcardApp v1.0.0\n\nỨng dụng hỗ trợ học tập qua flashcard, phát triển bởi nhóm doantotnghiep.')),
          _SimpleTile('Terms & Privacy', onTap: () => _showDialog('Terms & Privacy', 'Chúng tôi cam kết bảo vệ thông tin cá nhân của bạn. Dữ liệu chỉ dùng cho mục đích học tập và không chia sẻ cho bên thứ ba.')),
        ],
      ),
    );
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
