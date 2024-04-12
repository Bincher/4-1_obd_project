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

  @override
  void initState() {
    super.initState();
    // 플러그인 초기화
    obd2.initBluetooth;
  }

  Future<void> callPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
    ].request();
    
    if (statuses.values.every((element) => element.isGranted)) {
      setState(() 
      {
        connectionStatus = '권한얻기 성공';
      });
    }

  }

  Future<void> canBluetooth() async {
    bool enabled = await obd2.enableBluetooth;
    
    if(enabled){
      setState(() 
      {
        connectionStatus = 'enableBluetooth';
      });
    }
    else{
      setState(() 
      {
        connectionStatus = 'notEnableBluetooth';
      });
    }
  }

  Future<void> hasBluetoothDevice() async {
    bool connected = await obd2.hasConnection;
    
    if(connected){
      setState(() 
      {
        connectionStatus = 'hasConnection';
      });
    }
    else{
      setState(() 
      {
        connectionStatus = 'notConnection';
      });
    }
  }

  Future<void> connectDevice(int index) async {
    if (index >= 0 && index < nearbyPairedDevices.length) {
      obd2.getConnection(
        nearbyPairedDevices[index], 
        (connection){
          setState(() {
            connectionStatus = 'Connected to bluetooth device.';
          });
        },
        (message) {
          setState(() {
            connectionStatus = 'Error in connecting: $message';
          });
        }
      );
    } else {
      setState(() {
        connectionStatus = 'Invalid device index selected.';
      });
    }
  }

  Future<void> getBluetoothDevice() async {
    await callPermissions();
    List<BluetoothDevice> devices = await FlutterBluetoothSerial.instance.getBondedDevices();
    setState(() {
      connectionStatus = 'Show bluetooth device.';
      nearbyPairedDevices = devices;
    });
  }

  Future<void> requestPid() async {
  String json = '''[
    {
        "command": "AT Z",
        "description": "",
        "status": true
    }
  ]''';

  int delayMilliseconds = await obd2.configObdWithJSON(json);

  // 지연 시간만큼 기다립니다.
  await Future.delayed(Duration(milliseconds: delayMilliseconds));

  // 데이터를 받을 준비가 되었다면 데이터 수신을 위한 콜백을 등록합니다.
  obd2.setOnDataReceived((command, response, requestCode) {
      setState(() {
        connectionStatus = "$command => $response";
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
              child: Text('can Bluetooth?'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: hasBluetoothDevice,
              child: Text('has Bluetooth Device?'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: getBluetoothDevice,
              child: Text('get Bluetooth Device?'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: requestPid,
              child: Text('request Pid!'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Nearby Paired Devices:',
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
