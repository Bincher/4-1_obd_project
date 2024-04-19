import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:my_flutter_app/obd2_plugin.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

bool isConnected = false;
String connectedDevice = "no Device";



class BluetoothPage extends StatefulWidget {
  const BluetoothPage({Key? key}) : super(key: key);

  // 부모 위젯의 BluetoothPairingState 인스턴스를 찾아서 반환
  static BluetoothPageState of(BuildContext context) => context.findAncestorStateOfType()!;

  @override
  State<BluetoothPage> createState() => BluetoothPageState();
}

class BluetoothPageState extends State<BluetoothPage> {
  final String _platformVersion = 'Unknown';
  String bluetoothState = "블루투스 연결이 필요합니다."; // 초기 상태
  late Obd2Plugin obd2;

  @override
  void initState() {
    super.initState();
    obd2 = Obd2Plugin();
  }



  Future<void> setBluetoothDevice() async {
    try{
      print("반복하다보면 !(await obd2.isBluetoothEnable)가 안먹히는 문제가 발생?");
      if(!(await obd2.isBluetoothEnable)){
        print("여기는 출력이 안됨");
        await obd2.enableBluetooth ;
      }
      if (!(await obd2.hasConnection)){
        // 연결되어 있지 않다면 Bluetooth 장치 목록을 표시
        await showBluetoothList(context, obd2);
        setState(() {
            bluetoothState = "연결이 완료되었습니다.";
            isConnected = true;
          });
        
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

  void unconnectDevice(){
    if(isConnected){
      obd2.disconnect();
      obd2.disableBluetooth;
      setState(() {
          bluetoothState = "블루투스 연결이 필요합니다.";
          isConnected = false;
          connectedDevice = "no Device";
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
      print("연결되어있는 디바이스가 없습니다");
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("알림"),
              content: Text("연결된 디바이스가 없습니다."),
            );
          },
        );
    }
    
  }

  Future<void> getDataFromObd() async {
    // 데이터 수신 초기화가 완료되었는지 확인
    if (isConnected){
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
      // OBD에 JSON 데이터 보내기
      await Future.delayed(Duration(milliseconds: await obd2.configObdWithJSON(commandJson)), (){});
      // OBD에서 매개변수에 대한 JSON 데이터 보내기
      await Future.delayed(Duration(milliseconds: await obd2.getParamsFromJSON(paramJson)), (){});
      // OBD에서 DTC에 대한 JSON 데이터 보내기
      await Future.delayed(Duration(milliseconds: await obd2.getDTCFromJSON(dtcJson)), (){
        print("dtc is finished");
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("결과"),
              content: Text("정상적으로 데이터를 전송받았습니다."),
            );
          },
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "OBDII Plugin Test",
      locale: const Locale.fromSubtags(languageCode: 'en'),
      home: Scaffold( 
        appBar: AppBar(
          title: const Text('OBDII Plugin Test'),
        ),
        body: Center(
          child: Column(children: [
            Text('Running on: $_platformVersion\n$bluetoothState'),
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
                
                setState(() {
                  connectedDevice = connectedDevice;
                });
              },
              child: Text(
                "블루투스 연결",
                style: const TextStyle(fontSize: 18.0),
              ),
            ),
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
                unconnectDevice();
                setState(() {
                  connectedDevice = connectedDevice;
                });
              },
              child: Text(
                "디바이스 연결 끊기",
                style: const TextStyle(fontSize: 18.0),
              ),
            ),
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
                getDataFromObd();
                setState(() {
                  if(isConnected) {
                    connectedDevice = connectedDevice;
                  } else {
                    connectedDevice = "no Device";
                  }
                });
              },
              child: Text(
                "데이터 받기",
                style: const TextStyle(fontSize: 18.0),
              ),
            ),
          ],),
        
        ),

      ),
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
                      print("connected to bluetooth device.");
                      connectedDevice = devices[index].name.toString();
                      Navigator.pop(builder);
                    }, (message) {
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

// 엔진 RPM 상태 변수
double engineRpm = 0;
// 배터리 전압 상태 변수
double batteryVoltage = 0;
// 속력 상태 변수
double vehicleSpeed = 0;
// 엔진 온도 상태 변수
double engineTemp = 0;

double getEngineRpm(){
    return engineRpm;
  } 
double getBatteryVoltage(){
    return batteryVoltage;
  } 
double getVehicleSpeed(){
    return vehicleSpeed;
  } 
double getEngineTemp(){
    return engineTemp;
  } 
bool getIsConnected(){
  return isConnected;
}
String getConnectedDevice(){
  return connectedDevice;
}

// OBD에 대한 커맨드를 위한 JSON 데이터
String commandJson = '''[
            {
                "command": "AT D",
                "description": "",
                "status": true
            },
            {
                "command": "AT Z",
                "description": "",
                "status": true
            },
            {
                "command": "AT E0",
                "description": "",
                "status": true
            },
            {
                "command": "AT L0",
                "description": "",
                "status": true
            },
            {
                "command": "AT S0",
                "description": "",
                "status": true
            },
            {
                "command": "AT H0",
                "description": "",
                "status": true
            },
            {
                "command": "AT SP 0",
                "description": "",
                "status": true
            }
        ]''';

// OBD에서 매개변수에 대한 JSON 데이터
String paramJson = '''
    [
        {
            "PID": "AT RV",
            "length": 4,
            "title": "Battery Voltage",
            "unit": "V",
            "description": "<str>",
            "status": true
        },
        {
            "PID": "01 0C",
            "length": 2,
            "title": "Engine RPM",
            "unit": "RPM",
            "description": "<double>, (( [0] * 256) + [1] ) / 4",
            "status": true
        },
        {
            "PID": "01 0D",
            "length": 1,
            "title": "Speed",
            "unit": "Kh",
            "description": "<int>, [0]",
            "status": true
        },
        {
            "PID": "01 05",
            "length": 1,
            "title": "Engine Temp",
            "unit": "°C",
            "description": "<int>, [0] - 40",
            "status": true
        }
      ]
    ''';

// OBD에서 DTC에 대한 JSON 데이터
String dtcJson = '''
            [
    {
        "id": 1,
        "created_at": "2021-12-05T16:33:18.965620Z",
        "command": "03",
        "response": "6",
        "status": true
    },
    {
        "id": 3,
        "created_at": "2021-12-05T16:33:38.323200Z",
        "command": "0A",
        "response": "6",
        "status": true
    },
    {
        "id": 2,
        "created_at": "2021-12-05T16:33:28.439547Z",
        "command": "07",
        "response": "6",
        "status": true
    }
]
          ''';