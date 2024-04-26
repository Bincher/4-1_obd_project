// main.dart
import 'dart:async'; // 비동기 작업
// JSON 데이터 처리
import 'dart:math'; 

import 'package:flutter/material.dart'; // 플러터 UI 프레임워크
import 'package:my_flutter_app/allimPage.dart'; // 알람 페이지
import 'package:my_flutter_app/diagnosisPage.dart'; // 진단 페이지
import 'package:my_flutter_app/monitoringPage.dart'; // 모니터링 페이지
import 'package:my_flutter_app/settingPage.dart'; // 세팅 페이지
import 'package:my_flutter_app/obdData.dart';

Random random = Random();

// 앱의 진입점
void main() {
  // MyApp 위젯을 실행
  runApp(const MyApp());

  // 1분마다 데이터를 가져오기 위한 타이머 설정
  Timer.periodic(const Duration(seconds: 5), (timer) async {
    // 연결된 상태라면 OBD2 장치로부터 데이터 가져오기
    // if (isConnected) await getDataFromObd(obd2);

    engineRpm = random.nextDouble() * 100;
    batteryVoltage = random.nextDouble() * 100;
    engineTemp = random.nextDouble() * 100;
    vehicleSpeed = random.nextDouble() * 100;
    print("change Data");
  });
}

// 앱의 루트 위젯
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

// 메인 페이지 위젯
class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  // State 객체를 가져오는 정적 메서드
  static MainPageState of(BuildContext context) => context.findAncestorStateOfType<MainPageState>()!;

  @override
  MainPageState createState() => MainPageState();
}

// 메인 페이지 상태 클래스
class MainPageState extends State<MainPage> {
  String bluetoothText = "OBD2 연결이 없습니다.";
  String bluetoothButtonText = "클릭하여 장치를 연결";

  @override
  void initState() {
    super.initState();
  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            // 홈 아이콘 버튼 기능
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
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onPressed: () {
                  print("Bluetooth 버튼 클릭이 실행되었습니다");
                },
                child: Text(bluetoothButtonText),
              ),
              Text(bluetoothText),
              const SizedBox(height: 20),
              // 버튼 행 설정
              setButtonRow(context, firstButton: '차량진단', secondButton: '모니터링'),
              const SizedBox(height: 20),
              setButtonRow(context, firstButton: '알람', secondButton: '세팅'),
            ],
          ),
        ),
      ),
    );
  }
}



/// 버튼 행 위젯 설정 함수
Widget setButtonRow(BuildContext context, {required String firstButton, required String secondButton}) {
  double buttonSize = MediaQuery.of(context).size.width / 2 - 20;

  Future<void> monitoringVehicle() async {

    if (engineRpm == 0 && batteryVoltage == 0){
      engineRpm = random.nextDouble() * 100;
      batteryVoltage = random.nextDouble() * 100;
      engineTemp = random.nextDouble() * 100;
      vehicleSpeed = random.nextDouble() * 100;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MonitoringPage()),
    );
  }

  // 차량 진단 
  Future<void> diagnoseVehicle() async {

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DiagnosisPage()),
    );

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
