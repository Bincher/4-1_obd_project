import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

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
  bool isLoading = false;
  BluetoothDevice? connectedDevice;
  StreamSubscription? onDataReceivedSubscription;

  @override
  void initState() {
    super.initState();
    initObd2();
    onDataReceivedSubscription = obd2.connection?.input?.listen((Uint8List data) {
      // onDataReceived에서 데이터를 처리하는 로직
      // 데이터를 문자열로 변환
      String receivedData = String.fromCharCodes(data);

      // 예상되는 데이터 형식에 따라 적절한 처리를 수행
      if (receivedData.startsWith("RPM:")) {
        // RPM 값을 추출하여 화면에 표시
        String rpmValue = receivedData.split(":")[1];
        // 화면에 표시하거나 다른 작업을 수행할 수 있음
      } else if (receivedData.startsWith("속력:")) {
        // 속력 값을 추출하여 화면에 표시
        String speedValue = receivedData.split(":")[1];
        // 화면에 표시하거나 다른 작업을 수행할 수 있음
      } else if (receivedData.startsWith("냉각수 온도:")) {
        // 냉각수 온도 값을 추출하여 화면에 표시
        String coolantTempValue = receivedData.split(":")[1];
        // 화면에 표시하거나 다른 작업을 수행할 수 있음
      } else {
        // 다른 유형의 데이터에 대한 처리 로직을 여기에 추가
      }
    });
  }

  @override
  void dispose() {
    // 페이지가 dispose될 때 subscription을 취소
    onDataReceivedSubscription?.cancel();
    super.dispose();
  }

  Future<void> initObd2() async {
    // Bluetooth를 초기화합니다.
    await obd2.initBluetooth;

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
            connectedDevice = nearbyPairedDevices[index];
            connectionStatus = '$connectedDevice에 연결됨';
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

  // getDTC 함수 정의
  Future<void> getDTC() async {
    // 에러코드 요청에 사용할 JSON 문자열을 생성합니다.
    String dtcJsonString = '[{"command": "03", "description": "DTC request"}]';
    
    try {
      obd2.onResponse = null;
      setState(() {
        connectionStatus = 'dtc...';
        isLoading = true; // 데이터 요청 중임을 표시합니다.
      });

      // Obd2Plugin의 getDTCFromJSON 메서드를 사용하여 에러코드를 요청합니다.
      int delayTime = await obd2.getDTCFromJSON(dtcJsonString);

      // 요청이 완료되기 전에 대기합니다.
      await Future.delayed(Duration(milliseconds: delayTime));

      // 데이터를 수신할 때까지 대기합니다.
      await obd2.setOnDataReceived((command, response, requestCode) async {
        // 수신된 데이터를 처리합니다.
        if (command == 'DTC') {
          List<String> dtcList = json.decode(response);
          
          setState(() {
            connectionStatus = '${dtcList.map((dtc) => Text(dtc)).toList()}';
            isLoading = false; // 데이터 요청 완료를 표시합니다.
          });
        }
      });

    } catch (e) {
      setState(() {
        isLoading = false; // 데이터 요청 완료를 표시합니다.
        // 에러가 발생한 경우 에러 메시지를 출력합니다.
        connectionStatus = '에러: $e';
      });
    }
  }

  Future<void> getInformation() async {
    try {
      obd2.onResponse = null;
      setState(() {
        connectionStatus = 'param...';
        isLoading = true; // 데이터 요청 중임을 표시합니다.
      });

      // RPM 정보 요청을 위한 JSON 문자열 생성
      String rpmJsonString = '[{"command": "01 0C", "description": "Engine RPM"}]';
      int rpmDelayTime = await obd2.getDTCFromJSON(rpmJsonString);

      // 속력 정보 요청을 위한 JSON 문자열 생성
      String speedJsonString = '[{"command": "01 0D", "description": "Vehicle Speed"}]';
      int speedDelayTime = await obd2.getDTCFromJSON(speedJsonString);

      // 냉각수 온도 정보 요청을 위한 JSON 문자열 생성
      String coolantTempJsonString = '[{"command": "01 05", "description": "Engine Coolant Temperature"}]';
      int coolantTempDelayTime = await obd2.getDTCFromJSON(coolantTempJsonString);

      // 요청이 완료되기 전에 대기합니다.
      await Future.delayed(Duration(milliseconds: rpmDelayTime + speedDelayTime + coolantTempDelayTime));

      // 데이터를 수신할 때까지 대기합니다.
      await obd2.setOnDataReceived((command, response, requestCode) async {
        // 수신된 데이터를 처리합니다.
        if (command == 'PARAMETER') {
          List<dynamic> parameters = json.decode(response);
          String rpm = '';
          String speed = '';
          String coolantTemp = '';

          for (var parameter in parameters) {
            switch (parameter['PID']) {
              case '0C':
                rpm = parameter['response'];
                break;
              case '0D':
                speed = parameter['response'];
                break;
              case '05':
                coolantTemp = parameter['response'];
                break;
            }
          }

          setState(() {
            connectionStatus = 'RPM: $rpm, 속력: $speed, 냉각수 온도: $coolantTemp';
            isLoading = false; // 데이터 요청 완료를 표시합니다.
          });
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false; // 데이터 요청 완료를 표시합니다.
        // 에러가 발생한 경우 에러 메시지를 출력합니다.
        connectionStatus = '에러: $e';
      });
    }
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
              onPressed: getDTC,
              child: Text('dtc'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: getInformation,
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
