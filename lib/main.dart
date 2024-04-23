// Dart 코드를 플러터를 이용하여 작성한 것으로 보입니다. 이 코드는 차량 정비 앱을 구성하는데 사용됩니다.

// 필요한 라이브러리를 가져옵니다.
import 'dart:async'; // 비동기 작업을 위한 라이브러리
import 'dart:convert'; // JSON 데이터 처리를 위한 라이브러리

import 'package:flutter/material.dart'; // 플러터 UI 프레임워크
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart'; // Bluetooth 관련 기능을 위한 라이브러리
import 'package:my_flutter_app/allimPage.dart'; // 알람 페이지
import 'package:my_flutter_app/diagnosisPage.dart'; // 진단 페이지
import 'package:my_flutter_app/monitoringPage.dart'; // 모니터링 페이지
import 'package:my_flutter_app/bluetoothPage.dart'; // Bluetooth 설정 페이지
import 'package:my_flutter_app/settingPage.dart'; // 세팅 페이지
import 'package:my_flutter_app/obd2_plugin.dart'; // OBD2 플러그인

// Bluetooth 연결 상태를 나타내는 전역 변수
bool isConnected = false;
// OBD2 플러그인 인스턴스 생성
Obd2Plugin obd2 = Obd2Plugin();

// 엔진 RPM 상태 변수
double engineRpm= 0;
// 배터리 전압 상태 변수
double batteryVoltage = 0;
// 속력 상태 변수
double vehicleSpeed = 0;
// 엔진 온도 상태 변수
double engineTemp = 0;

// 앱의 진입점
void main() {
  // MyApp 위젯을 실행
  runApp(const MyApp());

  // 1분마다 데이터를 가져오기 위한 타이머 설정
  Timer.periodic(const Duration(minutes: 1), (timer) async {
    // 연결된 상태라면 OBD2 장치로부터 데이터 가져오기
    if (isConnected) await getDataFromObd(obd2);
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

  // Bluetooth 장치 설정 함수
  Future<void> setBluetoothDevice(Obd2Plugin obd2plugin) async {
    try {
      if (isConnected) {
        // 연결 종료
        await obd2plugin.disconnect();

        setState(() {
          isConnected = false;
          
        });
        // 연결 종료 다이얼로그 표시
        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AlertDialog(
              title: Text("연결 종료"),
              content: Text("연결이 종료되었습니다."),
            );
          },
        );
      } else {
        // Bluetooth 활성화 상태 확인
        if (!(await obd2.isBluetoothEnable)) {
          await obd2.enableBluetooth;
        }
        // 연결되어 있지 않다면 Bluetooth 장치 목록 표시
        if (!(await obd2.hasConnection)) {
          await showBluetoothList(context, obd2);

          setState(() {
            isConnected = true;
          });
        }
      }
    } catch (e) {
      print(e);
      isConnected = false;
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const AlertDialog(
            title: Text("에러!"),
            content: Text("문제가 발생했습니다."),
          );
        },
      );
    }
  }

  // Bluetooth 장치 목록을 표시하는 함수
  Future<void> showBluetoothList(BuildContext context, Obd2Plugin obd2plugin) async {
    List<BluetoothDevice> devices = await obd2plugin.getPairedDevices;

    // ignore: use_build_context_synchronously
    showModalBottomSheet(
      context: context,
      builder: (builder) {
        return Container(
          padding: const EdgeInsets.only(top: 0),
          width: double.infinity,
          height: devices.length * 50,
          child: ListView.builder(
            itemCount: devices.length,
            itemBuilder: (context, index) {
              return SizedBox(
                height: 50,
                child: TextButton(
                  onPressed: () {
                    // 선택된 Bluetooth 장치에 연결
                    obd2plugin.getConnection(devices[index], (connection) {
                      setState(() {
                        isConnected = true;
                      });
                      print("connected to bluetooth device.");
                      Navigator.pop(builder);
                    }, (message) {
                      setState(() {
                        isConnected = false;
                      });
                      print("error in connecting: $message");
                      Navigator.pop(builder);
                    });
                  },
                  child: Center(
                    child: Text(devices[index].name.toString()),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    setState(() {
      // 연결 상태에 따라 Bluetooth 텍스트 업데이트
      if (isConnected) {
        bluetoothText = "OBD2 연결 성공";
        bluetoothButtonText = "클릭하여 장치를 제거";
      } else {
        bluetoothText = "OBD2 연결 필요";
        bluetoothButtonText = "클릭하여 장치를 연결";
      }
    });

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
                  setBluetoothDevice(obd2);
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

/// OBD2 장치로부터 데이터를 가져오는 함수
Future<void> getDataFromObd(Obd2Plugin obd2) async {
  print("getDataFromObd");
  if (!(await obd2.isBluetoothEnable)) {
    await obd2.enableBluetooth;
  }
  if (await obd2.hasConnection) {
    if (!(await obd2.isListenToDataInitialed)) {
      obd2.setOnDataReceived((command, response, requestCode) {
        print("$command => $response");
        if (response.startsWith('[{')) {
          var jsonResponse = jsonDecode(response);
          for (var data in jsonResponse) {
            switch (data['PID']) {
              case 'AT RV':
                batteryVoltage = double.tryParse(data['response']) ?? 0;
                break;
              case '01 0C':
                engineRpm = double.tryParse(data['response']) ?? 0;
                break;
              case '01 0D':
                vehicleSpeed = double.tryParse(data['response']) ?? 0;
                break;
              case '01 05':
                engineTemp = double.tryParse(data['response']) ?? 0;
                break;
            }
          }
        }
      });
    }
    await Future.delayed(Duration(milliseconds: await obd2.configObdWithJSON(commandJson)), (){print("getDataInitSuccess");});
    await Future.delayed(Duration(milliseconds: await obd2.getParamsFromJSON(paramJson)), (){print("getDataSuccess");});
  }
}

/// OBD2 장치로부터 DTC를 가져오는 함수
Future<void> getDtcFromObd(Obd2Plugin obd2) async {
  print("getDtcFromObd");
  if (!(await obd2.isBluetoothEnable)) {
    await obd2.enableBluetooth;
  }
  if (await obd2.hasConnection) {
    if (!(await obd2.isListenToDataInitialed)) {
      obd2.setOnDataReceived((command, response, requestCode) {
        print("$command => $response");
        // DTC 형식에 대한 정보가 없으므로 처리하지 않음
      });
    }
    await Future.delayed(Duration(milliseconds: await obd2.configObdWithJSON(commandJson)), (){});
    await Future.delayed(Duration(milliseconds: await obd2.getDTCFromJSON(dtcJson)), (){print("getDtcSuccess");});
  }
}

/// 버튼 행 위젯 설정 함수
Widget setButtonRow(BuildContext context, {required String firstButton, required String secondButton}) {
  double buttonSize = MediaQuery.of(context).size.width / 2 - 20;

  Future<void> monitoringVehicle() async {
    if (!isConnected) {
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
      if (engineRpm == 0 && batteryVoltage == 0) await getDataFromObd(obd2);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MonitoringPage()),
      );
    }
  }

  // 차량 진단 
  Future<void> diagnoseVehicle() async {
    if (isConnected) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("진단 중"),
            content: FutureBuilder(
              future: getDtcFromObd(obd2),
              builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          );
        },
      );
      await getDtcFromObd(obd2);
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DiagnosisPage()),
      );
    } else {
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
