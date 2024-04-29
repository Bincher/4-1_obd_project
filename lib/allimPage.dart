// allimPage.dart
import 'package:flutter/material.dart';
import 'package:my_flutter_app/obd2_plugin.dart';

class AllimPage extends StatefulWidget {
  const AllimPage({Key? key}) : super(key: key);
  static AllimPageState of(BuildContext context) => context.findAncestorStateOfType()!;

  @override
  State<AllimPage> createState() => AllimPageState();
}


class AllimPageState extends State<AllimPage> {
  
  @override
  void initState() {
    super.initState();
  }

  var obd2 = Obd2Plugin();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "AllimPage",
      locale: const Locale.fromSubtags(languageCode: 'en'),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('알림페이지'),
        ),
        body: Center(
          child: Text('알림페이지'),
        ),
      ),
    );
  }
}

