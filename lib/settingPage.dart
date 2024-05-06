import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

bool darkModeEnabled = false;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Settings Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: darkModeEnabled ? Brightness.dark : Brightness.light,
      ),
      home: SettingPage(),
    );
  }
}

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  State<SettingPage> createState() => SettingPageState();
}

class SettingPageState extends State<SettingPage> {
  Widget build(BuildContext context) {
    return Scaffold(
      body: SettingsList(
        sections: [
          SettingsSection(
            title: Text(
              '공통',
            ),
            tiles: <SettingsTile>[
              SettingsTile.switchTile(
                title: Text('다크 모드'),
                initialValue: darkModeEnabled,
                onToggle: (value) {
                  setState(() {
                    darkModeEnabled = value;
                  });
                },
                leading: Icon(Icons.nightlight_round),
              ),
            ],
          ),
          SettingsSection(
            title: Text('기타'),
            tiles: <SettingsTile>[
              SettingsTile(
                title: Text('버전 : 1.0.0'),
              ),
              SettingsTile.navigation(
                leading: Icon(Icons.help),
                title: Text('도움말'),
                onPressed: ((context) {}),
              ),
              SettingsTile.navigation(
                leading: Icon(Icons.library_books),
                title: Text('이용자 약관'),
                onPressed: ((context) {}),
              ),
              SettingsTile.navigation(
                leading: Icon(Icons.code),
                title: Text('오픈소스 라이센스'),
                onPressed: ((context) {}),
              ),
              SettingsTile.navigation(
                leading: Icon(Icons.email),
                title: Text('개발자에게 연락'),
                onPressed: ((context) {
                  _launchURL('https://github.com/Bincher/4-1_obd_project');
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

void _launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
