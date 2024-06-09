// allimPage.dart

import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/obdData.dart';



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AllimPage',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AllimPage(),
    );
  }
}

class AllimPage extends StatefulWidget {
  const AllimPage({Key? key}) : super(key: key);

  @override
  State<AllimPage> createState() => AllimPageState();
}

class AllimPageState extends State<AllimPage> {
  

  @override
  void initState() {
    super.initState();
    
  }

  Future<void> _saveSettings(String key, bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('알람'),
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: const Text('공통'),
            tiles: <SettingsTile>[
              SettingsTile.switchTile(
                title: const Text('진단 알림 받기'),
                initialValue: diagnosisNotification,
                onToggle: (value) {
                  setState(() {
                    diagnosisNotification = value;
                    _saveSettings('diagnosisNotification', value);
                  });
                },
                leading: const Icon(Icons.notifications),
              ),
            ],
          ),
          SettingsSection(
            title: const Text('진단 설정'),
            tiles: <SettingsTile>[
              if (diagnosisNotification)
                SettingsTile.switchTile(
                  title: const Text('TTS 목소리 제공'),
                  initialValue: ttsVoiceEnabled,
                  onToggle: (value) {
                    setState(() {
                      ttsVoiceEnabled = value;
                      _saveSettings('ttsVoiceEnabled', value);
                    });
                  },
                  leading: const Icon(Icons.volume_up),
                ),
              if (diagnosisNotification)
                SettingsTile.switchTile(
                  title: const Text('조용한 진단'),
                  initialValue: quietDiagnosis,
                  onToggle: (value) {
                    setState(() {
                      quietDiagnosis = value;
                      _saveSettings('quietDiagnosis', value);
                    });
                  },
                  leading: const Icon(Icons.volume_off),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
