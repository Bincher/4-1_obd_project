import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import '../allimPage.dart';
import '../diagnosisPage.dart';
import '../monitoringPage.dart';
import '../settingPage.dart';
import '../../utils/obd2_plugin.dart';
import '../../models/obdData.dart';
import '../../utils/csv_helper.dart'; // csv 데이터 관리
import 'package:flutter_tts/flutter_tts.dart';

bool isConnected = false;
bool isInited = false;
bool isRequestingDtc = false;
bool isRequestingData = false;
Obd2Plugin obd2 = Obd2Plugin();
FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();
FlutterTts tts = FlutterTts();

void main() {

  // 앱의 바인딩이 초기화되었는지를 확인
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
  
  // 5초마다 get Monitoring Data 
  Timer.periodic(const Duration(seconds: 5), (timer) async {
    // DTC와 data 충돌 방지
    if (isConnected && !isRequestingDtc) {
      await getDataFromObd(obd2);
    }
  });

  // 10분마다 local notification push, 시간 바꿀 것
  Timer.periodic(const Duration(minutes: 1), (timer) async {
    if(isConnected && diagnosisNotification){

      NotificationDetails details = const NotificationDetails(
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
        android: AndroidNotificationDetails(
          "show_test",
          "show_test",
          importance: Importance.max,
          priority: Priority.high,
        ),
      );
      
      String content = await getMessage();
      if(!quietDiagnosis || content != "현재 발견된 문제가 없습니다."){
        await _local.show(
          0,
          "OBD 차량스캐너",
          content,
          details,
          payload: "tyger://",
        );
      }
      if(ttsVoiceEnabled){
        tts.speak(content);
      }
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

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

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  static MainPageState of(BuildContext context) => context.findAncestorStateOfType<MainPageState>()!;
  
  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {

  String bluetoothText = "OBD2 연결이 없습니다.";
  String bluetoothButtonText = "클릭하여 장치를 연결";
  
  @override
  void initState() {
    super.initState();
    _permissionWithNotification(); // 앱 시작시 권한 설정 -> 안드로이드 12 이상만
    _initLocalNotification();
    tts.setLanguage('kr');
    tts.setSpeechRate(0.8);
  }

  Future<void> setBluetoothDevice(Obd2Plugin obd2plugin) async {
    try {
      if (isConnected) {
        await obd2.disconnect();
        print("unconnected success");
        setState(() {
          isConnected = false;
          ObdData.batteryVoltage = 0;
          ObdData.engineRpm = 0;
        });
        await deleteCsvData(['engine_temp', 'battery_voltage', 'engine_rpm', 'vehicle_speed'
          ,'engine_load', 'manifold_pressure'
          , 'maf', 'catalyst_temp'
          ]);


      } else {
        if (!(await obd2.isBluetoothEnable)) {
          await obd2.enableBluetooth;
        }
        if (!(await obd2.hasConnection)) {
          await showBluetoothList(context, obd2);
        }
      }
    } catch (e) {
      print(e);
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

  /// 특정 CSV 데이터 파일 삭제
  Future<void> deleteCsvData(List<String> fileNames) async {
    for (String fileName in fileNames) {
      await CsvHelper.deleteCsvFile(fileName);
    }
  }

  /// 블루투스 기기 목록 출력
  Future<void> showBluetoothList(BuildContext context, Obd2Plugin obd2plugin) async {
    List<BluetoothDevice> devices = await obd2plugin.getPairedDevices;
    
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
                    obd2plugin.getConnection(devices[index], (connection) {
                      // 연결 성공
                      setState(() {
                        isConnected = true;
                      });
                      print("connected to bluetooth device.");
                      Navigator.pop(builder);
                    }, (message) {
                      // 연결 실패
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
          icon: const Icon(Icons.perm_device_information),
          onPressed: () async {
            if (await canLaunch('https://bincher.notion.site/App-622593d1186540c3a710d222e3180221?pvs=4')) {
              await launch('https://bincher.notion.site/App-622593d1186540c3a710d222e3180221?pvs=4');
            } else {
              throw 'Could not launch url';
            }
          },
        ),
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
                  backgroundColor: Colors.white,
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
                  setBluetoothDevice(obd2);
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
  // 블루투스 활성화가 필요한 경우 활성화
  if (!(await obd2.isBluetoothEnable)) {
    await obd2.enableBluetooth;
  }
  // 연결된 경우 데이터 수신 시작
  if (await obd2.hasConnection) {
    isRequestingData = true;
    // 데이터 수신이 초기화되지 않은 경우 수신 리스너 설정
    if (!(await obd2.isListenToDataInitialed)) {
      obd2.setOnDataReceived((command, response, requestCode) {
        // 응답이 JSON 배열 형태로 시작하는 경우 파싱
        if (response.startsWith('[{')) {
          print("$command => $response");
          var jsonResponse = jsonDecode(response);
          for (var data in jsonResponse) {
            switch (data['PID']) {
              case 'AT RV':
                // 배터리 전압 업데이트
                ObdData.updateBatteryVoltage(double.tryParse(data['response']) ?? 0);
                break;
              case '01 0C':
                // 엔진 RPM 업데이트
                ObdData.updateEngineRpm(double.tryParse(data['response']) ?? 0);
                break;
              case '01 0D':
                // 차량 속도 업데이트
                ObdData.updateVehicleSpeed(double.tryParse(data['response']) ?? 0);
                break;
              case '01 05':
                // 엔진 온도 업데이트
                ObdData.updateEngineTemp(double.tryParse(data['response']) ?? 0);
                break;
              case '01 04':
                // 엔진 과부화 업데이트
                ObdData.updateEngineLoad(double.tryParse(data['response']) ?? 0);
                break;
              case '01 0B':
                // 흡입매니폴드 압력 업데이트
                ObdData.updateManifoldPressureTemp(double.tryParse(data['response']) ?? 0);
                break;
              case '01 10':
                // 흡입 공기량 업데이트
                ObdData.updateMaf(double.tryParse(data['response']) ?? 0);
                break;
              case '01 3C':
                // 촉매 온도 업데이트
                ObdData.updateCatalystTempPosition(double.tryParse(data['response']) ?? 0);
                break;
            }
          }
        }
      });
    }

    // OBD 설정을 위한 JSON 데이터 전송
    if(!isInited) await Future.delayed(Duration(milliseconds: await obd2.configObdWithJSON(commandJson)), (){print("initSuccess");isInited = true;});
    // 파라미터 데이터 요청
    await Future.delayed(Duration(milliseconds: await obd2.getParamsFromJSON(paramJson)), (){});
    await Future.delayed(Duration(milliseconds: await obd2.getParamsFromJSON(paramJson2)), (){print("getDataSuccess"); isRequestingData = false;});
  }
}

/// OBD2 장치로부터 DTC를 가져오는 함수
Future<void> getDtcFromObd(Obd2Plugin obd2) async {
  
  if (!(await obd2.isBluetoothEnable)) {
    await obd2.enableBluetooth;
  }
  if (await obd2.hasConnection) {
    isRequestingDtc = true;
    if (isRequestingData){
      await Future.delayed(Duration(seconds: 5));
    } 
    if (!(await obd2.isListenToDataInitialed)) {
      obd2.setOnDataReceived((command, response, requestCode) {
        print("$command => $response");
        // DTC 형식에 대한 정보가 없으므로 처리하지 않음
        //dtcArray = [];
        if (command == "DTC" && response.startsWith('[') && response.endsWith(']')) {
          // 주석 제거할 것
          // List<dynamic> dtcList = json.decode(response);
          // dtcArray = List<String>.from(dtcList);
          dtcArray = ["P0001", "P0200"];
          print("DTC Array: $dtcArray");
        }
      });
    }
    if(!isInited) await Future.delayed(Duration(milliseconds: await obd2.configObdWithJSON(commandJson)), (){print("initSuccess");isInited = true;});
    await Future.delayed(Duration(milliseconds: await obd2.getDTCFromJSON(dtcJson)), (){print("getDtcSuccess");isRequestingDtc = false;});
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
                  MaterialPageRoute(
                      builder: (context) => DiagnosisPage(
                        diagnosticCodes: dtcArray.map((code) => SampleDiagnosticCodeData(code: code)).toList(),
                      )),
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

/// Notification 권한 요청(안드로이드 12 이상)
void _permissionWithNotification() async {
    if (await Permission.notification.isDenied &&
        !await Permission.notification.isPermanentlyDenied) {
      await [Permission.notification].request();
    }
  }

Future<void> _initLocalNotification() async {
  AndroidInitializationSettings android =
        const AndroidInitializationSettings("@mipmap/ic_launcher");
    DarwinInitializationSettings ios = const DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );
    InitializationSettings settings =
        InitializationSettings(android: android, iOS: ios);
    await _local.initialize(settings);
}

/// local notification Message 설정
Future<String> getMessage() async {
  await getDtcFromObd(obd2);

  String msg = "";
  if(dtcArray.isEmpty) {
    msg += "진단코드 : 없음\n";
  } else {
    msg += "진단코드 : 있음(진단버튼 클릭 필요)\n";
  }
  if(ObdData.engineTemp > 95){
    msg += "엔진온도 : 95도 보다 높음, 확인 필요\n";
  }
  return msg;
}
