import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:my_flutter_app/allimPage.dart';
import 'package:my_flutter_app/diagnosisPage.dart';
import 'package:my_flutter_app/monitoringPage.dart';
import 'package:my_flutter_app/bluetoothPage.dart';
import 'package:my_flutter_app/settingPage.dart';
import 'package:my_flutter_app/obd2_plugin.dart';

bool isConnected = false;
Obd2Plugin obd2 = Obd2Plugin();

void main() {
  runApp(const MyApp());
  // 작동 안됨
    Timer.periodic(const Duration(minutes: 5), (timer) {
      if(isConnected) getDataFromObd(obd2);
    });
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
  
  Future<void> setBluetoothDevice() async {
    try{
      if(isConnected){
        await obd2.disconnect();
        setState(() {
          isConnected = false;
        });
        

        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("연결 종료"),
                content: Text("연결이 종료되었습니다."),
              );
            },
          );
      }else{
        if(!(await obd2.isBluetoothEnable)){
          await obd2.enableBluetooth ;
        }
        if (!(await obd2.hasConnection)){
          // 연결되어 있지 않다면 Bluetooth 장치 목록을 표시
          await showBluetoothList(context, obd2);
          
          setState(() {
              bluetoothText = "연결이 완료되었습니다.";
            });
          getDataFromObd(obd2);
        }
      }
      
    }catch(e){
      print(e);
      isConnected = false;
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("에러!"),
              content: Text("문제가 발생했습니다."),
            );
          },
        );
    }

  }

  

    // Bluetooth 장치 목록을 표시하는 함수
  Future<void> showBluetoothList(BuildContext context, Obd2Plugin obd2plugin) async {
    List<BluetoothDevice> devices = await obd2plugin.getPairedDevices ;
    
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          return Container(
            padding: const EdgeInsets.only(top: 0),
            width: double.infinity,
            height: devices.length * 50,
            child: ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index){
                return SizedBox(
                  height: 50,
                  child: TextButton(
                    onPressed: (){
                      // 선택된 Bluetooth 장치에 연결
                      obd2plugin.getConnection(devices[index], (connection)
                      {
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
        }
    );
  }


  @override
  Widget build(BuildContext context) {

    setState(() {
      if(isConnected){
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
                      setBluetoothDevice();
                    },
                    child: Text("bluetooth 설정"),
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

Future<void> getDataFromObd(Obd2Plugin obd2) async {
    print("getDataFromObd");
    // 데이터 수신 초기화가 완료되었는지 확인
    if(!(await obd2.isBluetoothEnable)){
          await obd2.enableBluetooth ;
        }
    print("obd2.isBluetoothEnable");
    if ((await obd2.hasConnection)){
      print("obd2.hasConnection");
      if (!(await obd2.isListenToDataInitialed)){
        print("!(await obd2.isListenToDataInitialed) : ${!(await obd2.isListenToDataInitialed)}");
        // 대기 -> 데이터 받기
        obd2.setOnDataReceived((command, response, requestCode){
          print("$command => $response");
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
        });
      }
      // OBD에 JSON 데이터 보내기
      await Future.delayed(Duration(milliseconds: await obd2.configObdWithJSON(commandJson)), (){});
      // OBD에서 매개변수에 대한 JSON 데이터 보내기
      await Future.delayed(Duration(milliseconds: await obd2.getParamsFromJSON(paramJson)), (){print("getDataSuccess");});
    }
    
  }

Widget setButtonRow(BuildContext context, {required String firstButton, required String secondButton}) {
  double buttonSize = MediaQuery.of(context).size.width / 2 - 20; // 화면의 가로 크기를 반으로 나눈 후 여백을 제외한 크기

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
      getDataFromObd(obd2);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MonitoringPage()),
      );
    }
  }

  Future<void> diagnoseVehicle() async {
    if (isConnected) {
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
