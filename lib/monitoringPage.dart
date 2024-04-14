import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:my_flutter_app/obd2_plugin.dart';
import 'package:permission_handler/permission_handler.dart';

class MonitoringPage extends StatefulWidget {
  @override
  _MonitoringPageState createState() => _MonitoringPageState();
}

class _MonitoringPageState extends State<MonitoringPage> {
  Obd2Plugin obd2 = Obd2Plugin();
  String connectionStatus = '';
  List<BluetoothDevice> nearbyPairedDevices = [];
  bool onDataReceivedSet = false;

  @override
  void initState() {
    super.initState();
    obd2.initBluetooth;
  }

  Future<void> callPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
    ].request();
    
    if (statuses[Permission.bluetooth] == PermissionStatus.granted &&
        statuses[Permission.bluetoothAdvertise] == PermissionStatus.granted &&
        statuses[Permission.bluetoothConnect] == PermissionStatus.granted &&
        statuses[Permission.bluetoothScan] == PermissionStatus.granted) {
      setState(() {
        connectionStatus = '권한 얻기 성공';
      });
    } else {
      setState(() {
        connectionStatus = '권한 얻기 실패';
      });
    }

  }

  Future<void> canBluetooth() async {
    bool enabled = await obd2.enableBluetooth;
    
    setState(() {
      connectionStatus = enabled ? 'Bluetooth 사용 가능' : 'Bluetooth 사용 불가능';
    });
  }

  Future<void> hasBluetoothDevice() async {
    bool connected = await obd2.hasConnection;
    
    setState(() {
      connectionStatus = connected ? 'Bluetooth 장치 연결됨' : 'Bluetooth 장치 연결 안 됨';
    });
  }

  Future<void> getBluetoothDevice() async {
    await callPermissions();
    List<BluetoothDevice> devices = await FlutterBluetoothSerial.instance.getBondedDevices();
    setState(() {
      connectionStatus = '블루투스 장치 목록 표시';
      nearbyPairedDevices = devices;
    });
  }

  Future<void> connectDevice(int index) async {
    if (index >= 0 && index < nearbyPairedDevices.length) {
      obd2.getConnection(
        nearbyPairedDevices[index], 
        (connection){
          setState(() {
            connectionStatus = 'Bluetooth 장치에 연결됨';
          });
        },
        (message) {
          setState(() {
            connectionStatus = '연결 오류: $message';
          });
        }
      );
    } else {
      setState(() {
        connectionStatus = '선택한 장치 인덱스가 잘못되었습니다.';
      });
    }
  }

  Future<void> responseConfig() async {
    String json = '''[
      {
          "command": "AT Z",
          "description": "",
          "status": true
      }
    ]''';

    // 데이터 수신을 위한 콜백이 이미 초기화되었는지 확인합니다.
    bool isInitialized = await obd2.isListenToDataInitialed;
    
    // 설정 작업을 시작합니다.
    int configTime = await obd2.configObdWithJSON(json);

    // 설정 작업이 완료되었을 때의 처리를 위해 Future.delayed를 사용합니다.
    await Future.delayed(Duration(milliseconds: configTime), () {
      setState(() {
        connectionStatus = 'config 완료';
      });
    });

    if (!isInitialized) {
      // 데이터 수신을 위한 콜백을 등록합니다.
      obd2.setOnDataReceived((command, response, requestCode) {
        setState(() {
          connectionStatus = "$command => $response";
        });
      });
    }else{
      setState(() {
          connectionStatus = "config 앱 종료 후 다시 실행";
        });
    }
  }

  Future<void> responseDTC() async {
    String dtcJSON = '''[
      {
          "id": 1,
		      "created_at": "2021-12-05T16:33:18.965620Z",
		      "command": "03",
		      "response": "6",
		      "status": true,
      }
    ]''';

    // DTC를 가져오는 작업을 시작합니다.
    int dtcTime = await obd2.getDTCFromJSON(dtcJSON);

    // 작업이 완료되었을 때의 처리를 위해 Future.delayed를 사용합니다.
    await Future.delayed(Duration(milliseconds: dtcTime), () {
      setState(() {
        connectionStatus = 'DTC 가져오기 완료';
      });
    });

  }

  Future<void> responseParams() async {
    String paramJSON = '''[
      {
          "PID": "AT RV",
          "length": 4,
          "title": "Battery Voltage",
          "unit": "V",
          "description": "<str>",
          "status": true
      }
    ]''';
    
    // 파라미터를 가져오는 작업을 시작합니다.
    int paramTime = await obd2.getParamsFromJSON(paramJSON);

    // 작업이 완료되었을 때의 처리를 위해 Future.delayed를 사용합니다.
    await Future.delayed(Duration(milliseconds: paramTime), () {
      setState(() {
        connectionStatus = '파라미터 가져오기 완료';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              connectionStatus,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: canBluetooth,
              child: Text('블루투스 사용 가능 여부 확인'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: hasBluetoothDevice,
              child: Text('블루투스 장치 연결 여부 확인'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: getBluetoothDevice,
              child: Text('블루투스 장치 목록 가져오기'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: responseConfig,
              child: Text('config'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: responseDTC,
              child: Text('dtc'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: responseParams,
              child: Text('param'),
            ),
            const SizedBox(height: 20),
            const Text(
              '근처 페어링된 장치:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: nearbyPairedDevices.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(nearbyPairedDevices[index].name.toString()),
                    onTap: () {
                      connectDevice(index);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
