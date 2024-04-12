import 'package:flutter/material.dart';
import 'package:my_flutter_app/allimPage.dart';
import 'package:my_flutter_app/diagnosisPage.dart';
import 'package:my_flutter_app/monitoringPage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '차량 정비 앱',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPage createState() => _MainPage();
}

class _MainPage extends State<MainPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            // Home icon button functionality
          },
        ),
        title: const Text(
          '차량 정비 Application',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20.0,
          ),
        ),
        
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
            setButtonRow(context, firstButton: '차량진단', secondButton: '모니터링'),
            setButtonRow(context, firstButton: '알람', secondButton: '세팅'),
          ],
          )
          
        ),
      ),
    );
  }
}

Widget setButtonRow(BuildContext context, {required String firstButton, required String secondButton}) {
  
  void diagnoseVehicle() {
    // "차량을 진단 중입니다" 메시지를 표시하기 위한 다이얼로그
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AlertDialog(
          title: Text("진단 중"),
          content: Text("차량을 진단 중입니다..."),
        );
      },
    );

    // 3초 후에 페이지 이동
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DiagnosisPage()),
      );
    });
  }


  double buttonSize = MediaQuery.of(context).size.width / 2 - 20; // 화면의 가로 크기를 반으로 나눈 후 여백을 제외한 크기
  
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      Container(
        width: buttonSize,
        height: buttonSize,
        margin: const EdgeInsets.all(10),
        child: Card(
          elevation: 3,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black, 
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            child: Text(
              firstButton,
              style: const TextStyle(fontSize: 18.0),
            ),
            onPressed: () {
              if (firstButton.compareTo('차량진단') == 0) {
                  diagnoseVehicle();
                }
              else if (firstButton.compareTo('알람') == 0) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AllimPage()));
              }
            },
          ),
        ),
      ),
      Container(
        width: buttonSize,
        height: buttonSize,
        margin: const EdgeInsets.all(10),
        child: Card(
          elevation: 3,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            child: Text(
              secondButton,
              style: const TextStyle(fontSize: 18.0),
            ),
            onPressed: () {
              if(secondButton.compareTo('모니터링') == 0){
                Navigator.push(context,
                      MaterialPageRoute(builder: (context) => MonitoringPage()));
              }
            },
          ),
        ),
      ),
    ],
  );
}