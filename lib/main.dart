import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_flutter_app/allimPage.dart';
import 'package:my_flutter_app/diagnosisPage.dart';
import 'package:my_flutter_app/monitoringPage.dart';
import 'package:my_flutter_app/bluetoothPairing.dart';
import 'package:my_flutter_app/settingPage.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

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

  static MainPageState of(BuildContext context) => context.findAncestorStateOfType()!;

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  
  String bluetoothText = "OBD2 연결이 없습니다.";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    setState(() {
      if(isBluetoothConnect){
        bluetoothText = "OBD2 연결 성공";
      }else{
        bluetoothText = "OBD2 연결 필요";
      }
    });

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
              const SizedBox(height: 20), // 버튼 위 여백
              Row(
                children: <Widget>[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const BluetoothPairing()),
                      );
                    },
                    child: Text("bluetooth 설정 페이지"),
                  ),
                  Text(bluetoothText),
                  
                  ],
              ),
              const SizedBox(height: 20),
              setButtonRow(context, firstButton: '차량진단', secondButton: '모니터링'),
              setButtonRow(context, firstButton: '알람', secondButton: '세팅'),
            ],
          ),
        ),
      ),
    );
  }

}

Widget setButtonRow(BuildContext context, {required String firstButton, required String secondButton}) {
  double buttonSize = MediaQuery.of(context).size.width / 2 - 20; // 화면의 가로 크기를 반으로 나눈 후 여백을 제외한 크기

  Future<void> monitoringVehicle() async {
    if (!isBluetoothConnect) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const AlertDialog(
            title: Text("블루투스 에러!"),
            content: Text("obd2가 연결되어있지 않습니다. 블루투스 버튼을 눌려 연결하여주십시오."),
          );
        },
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MonitoringPage()),
      );
    }
  }

  Future<void> diagnoseVehicle() async {
    if (isBluetoothConnect) {
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
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DiagnosisPage()),
        );
      });
    }else{
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const AlertDialog(
            title: Text("블루투스 에러!"),
            content: Text("obd2가 연결되어있지 않습니다. 블루투스 버튼을 눌려 연결하여주십시오."),
          );
        },
      );
    }
    
  }

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
              } else if (firstButton.compareTo('알람') == 0) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AllimPage()),
                );
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
              if (secondButton.compareTo('모니터링') == 0) {
                monitoringVehicle();
              } else if (secondButton.compareTo('세팅') == 0) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingPage()),
                );
              }
            },
          ),
        ),
      ),
    ],
  );
}
