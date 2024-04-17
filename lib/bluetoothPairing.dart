import 'package:flutter/material.dart';
import 'dart:async';
import 'package:my_flutter_app/obd2_plugin.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothPairing extends StatefulWidget {
  const BluetoothPairing({Key? key}) : super(key: key);

  // 부모 위젯의 BluetoothPairingState 인스턴스를 찾아서 반환
  static BluetoothPairingState of(BuildContext context) => context.findAncestorStateOfType()!;

  @override
  State<BluetoothPairing> createState() => BluetoothPairingState();
}

class BluetoothPairingState extends State<BluetoothPairing> {
  final String _platformVersion = 'Unknown';
  String bluetoothState = "블루투스 연결이 필요합니다."; // 초기 상태

  @override
  void initState() {
    super.initState();
  }

  var obd2 = Obd2Plugin();

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
          child: Text('Running on: $_platformVersion\n$bluetoothState'),
        ),
        floatingActionButton: const Float(),
        floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
        floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterFloat,
      ),
    );
  }
}

// Bluetooth 연결을 위한 FloatingActionButton을 제공하는 위젯
class Float extends StatelessWidget {
  const Float({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      child: const Icon(Icons.bluetooth),
      onPressed: () async {
        // Bluetooth가 활성화되어 있는지 확인
        if(!(await BluetoothPairing.of(context).obd2.isBluetoothEnable)){
          await BluetoothPairing.of(context).obd2.enableBluetooth ;
        }
        // Bluetooth가 연결되어 있는지 확인
        if (!(await BluetoothPairing.of(context).obd2.hasConnection)){
          // 연결되어 있지 않다면 Bluetooth 장치 목록을 표시
          await showBluetoothList(context, BluetoothPairing.of(context).obd2);
        } else {
          // 데이터 수신 초기화가 완료되었는지 확인
          if (!(await BluetoothPairing.of(context).obd2.isListenToDataInitialed)){
            // 대기 -> 데이터 받기
            BluetoothPairing.of(context).obd2.setOnDataReceived((command, response, requestCode){
              print("$command => $response");
            });
          }
          // OBD에 JSON 데이터 보내기
          await Future.delayed(Duration(milliseconds: await BluetoothPairing.of(context).obd2.configObdWithJSON(commandJson)), (){});
          // OBD에서 매개변수에 대한 JSON 데이터 보내기
          await Future.delayed(Duration(milliseconds: await BluetoothPairing.of(context).obd2.getParamsFromJSON(paramJson)), (){});
          // OBD에서 DTC에 대한 JSON 데이터 보내기
          await Future.delayed(Duration(milliseconds: await BluetoothPairing.of(context).obd2.getDTCFromJSON(dtcJson)), (){
            print("dtc is finished");
          });
        }
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
                      print("connected to bluetooth device.");
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
