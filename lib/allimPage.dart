import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

void main() {
  runApp(MyApp());
}

bool diagnosisNotification = false;
bool ttsVoiceEnabled = true;
bool quietDiagnosis = false;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Settings Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AllimPage(),
    );
  }
}

class AllimPage extends StatefulWidget {
  const AllimPage({Key? key}) : super(key: key);

  @override
  State<AllimPage> createState() => AllimPageState();
}

class AllimPageState extends State<AllimPage> {
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
                title: Text('진단 알림 받기'),
                initialValue: diagnosisNotification,
                onToggle: (value) {
                  setState(() {
                    diagnosisNotification = value;
                  });
                },
                leading: Icon(Icons.notifications),
              ),
              
            ],
          ),
          SettingsSection(
            title: Text('진단 설정'),
            tiles: <SettingsTile>[
              if (diagnosisNotification)
                SettingsTile.switchTile(
                  title: Text('TTS 목소리 제공'),
                  initialValue: ttsVoiceEnabled,
                  onToggle: (value) {
                    setState(() {
                      ttsVoiceEnabled = value;
                    });
                  },
                  leading: Icon(Icons.volume_up),

                ),
              if (diagnosisNotification)
                SettingsTile.switchTile(
                  title: Text('조용한 진단'),
                  initialValue: quietDiagnosis,
                  onToggle: (value) {
                    setState(() {
                      quietDiagnosis = value;
                    });
                  },
                  leading: Icon(Icons.volume_off),
                ),
            ],
          ),
          
        ],
      ),
    );
  }
}
