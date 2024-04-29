// settingPage.dart
import 'package:flutter/material.dart';
import 'package:my_flutter_app/obd2_plugin.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  State<SettingPage> createState() => AllimPageState();
}


class AllimPageState extends State<SettingPage> {
  
  @override
  void initState() {
    super.initState();
  }

  var obd2 = Obd2Plugin();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "SettingPage",
      locale: const Locale.fromSubtags(languageCode: 'en'),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('세팅페이지'),
        ),
        body: Center(
          child: Text('세팅페이지'),
        ),
      ),
    );
  }
}

