import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    });
  }

  Future<void> saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          SwitchListTile(
            title: Text('Notifications'),
            subtitle: Text(_notificationsEnabled ? 'Enabled' : 'Disabled'),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
              saveSettings();
            },
          ),
        ],
      ),
    );
  }
}
