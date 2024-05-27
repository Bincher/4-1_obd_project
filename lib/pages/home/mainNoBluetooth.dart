import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:my_flutter_app/pages/home/main.dart';
import '../allimPage.dart';
import '../diagnosisPage.dart';
import '../monitoringPage.dart';
import '../settingPage.dart';
import '../../models/obdData.dart';
import '../../utils/csv_helper.dart';

Random random = Random();


// 앱의 진입점
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  Timer.periodic(const Duration(seconds: 5), (timer) async {
    ObdData.updateBatteryVoltage(random.nextDouble() * 100);
    ObdData.updateEngineRpm(random.nextDouble() * 100);
    ObdData.updateVehicleSpeed(random.nextDouble() * 100);
    ObdData.updateEngineTemp(random.nextDouble() * 100);
  });

  runApp(const MyApp());
}

// 앱의 루트 위젯
class MyApp extends StatelessWidget {

  static final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: themeNotifier,
      builder:(context, value, child){
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'OBD 차량 스캐너',
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            // 왜 안될까...
            // elevatedButtonTheme: ElevatedButtonThemeData(
            //     style: ButtonStyle(
            //       backgroundColor: MaterialStateProperty.resolveWith((states) => Colors.indigo
            //       ),
            //     )
            // )
          ),
          themeMode: value,
          home: const MainPage(),
        );
      },
    );
  }
}

// 메인 페이지 위젯
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  // State 객체를 가져오는 정적 메서드
  static MainPageState of(BuildContext context) =>
      context.findAncestorStateOfType<MainPageState>()!;

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

  /// 특정 CSV 데이터 파일 삭제
  Future<void> deleteCsvData(List<String> fileNames) async {
    for (String fileName in fileNames) {
      await CsvHelper.deleteCsvFile(fileName);
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'OBD 차량 스캐너',
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
                  backgroundColor: const Color.fromRGBO(255, 255, 255, 1), 
                  padding: const EdgeInsets.all(20),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/bluetooth.png',
                      width: 48,
                      height: 48,
                    ),
                    Text(
                      bluetoothButtonText,
                      style: const TextStyle(fontSize: 18.0),
                    ),
                  ],
                ),
                onPressed: () {
                  print("Bluetooth 버튼 클릭이 실행되었습니다");
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                      isConnected ? 'assets/확인.png' : 'assets/경고.png',
                      width: 20,
                      height: 20,
                    ),
                  Text(" $bluetoothText"),
                ]
              ),
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

// / 버튼 행 위젯 설정 함수
Widget setButtonRow(BuildContext context,
    {required String firstButton, required String secondButton}) {
  double buttonSize = MediaQuery.of(context).size.width / 2 - 20;

  Future<void> monitoringVehicle() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MonitoringPage()),
    );
  }

  // 차량 진단
  Future<void> diagnoseVehicle() async {
    Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DiagnosisPage(
                        diagnosticCodes: dtcArray.map((code) => SampleDiagnosticCodeData(code: code)).toList(),
                      )),
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
          elevation: 2,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: Colors.white, 
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/$firstButton.png',
                  width: 48,
                  height: 48,
                ),
                Text(
                  firstButton,
                  style: const TextStyle(fontSize: 18.0),
                ),
              ],
            ),
          ),
        ),
      ),
      Container(
        width: buttonSize,
        height: buttonSize,
        margin: const EdgeInsets.all(10),
        child: Card(
          elevation: 2,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/$secondButton.png',
                  width: 48,
                  height: 48,
                ),
                Text(
                  secondButton,
                  style: const TextStyle(fontSize: 18.0),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}
