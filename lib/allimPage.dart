import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:my_flutter_app/obd2_plugin.dart';

class AllimPage extends StatefulWidget {
  const AllimPage({Key? key}) : super(key: key);
  static AllimPageState of(BuildContext context) => context.findAncestorStateOfType()!;

  @override
  State<AllimPage> createState() => AllimPageState();
}


class AllimPageState extends State<AllimPage> {
  final String _platformVersion = 'Unknown';

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
          child: Text('Running on: $_platformVersion\n'),
        ),
        floatingActionButton: const Float(),
        floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
        floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterFloat,
      ),
    );
  }
}

class Float extends StatelessWidget {
  const Float({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      child: const Icon(Icons.bluetooth),
      onPressed: () async {
        if(!(await AllimPage.of(context).obd2.isBluetoothEnable)){
          await AllimPage.of(context).obd2.enableBluetooth ;
        }
        if (!(await AllimPage.of(context).obd2.hasConnection)){
          await showBluetoothList(context, AllimPage.of(context).obd2);
        } else {
          if (!(await AllimPage.of(context).obd2.isListenToDataInitialed)){
            AllimPage.of(context).obd2.setOnDataReceived((command, response, requestCode){
              print("$command => $response");
            });
          }
          await Future.delayed(Duration(milliseconds: await AllimPage.of(context).obd2.configObdWithJSON('''[
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
        ]''')), (){});
          await Future.delayed(Duration(milliseconds: await AllimPage.of(context).obd2.getParamsFromJSON('''
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
        }
      ]
    ''')), (){});
          await Future.delayed(Duration(milliseconds: await AllimPage.of(context).obd2.getParamsFromJSON('''
    [
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
    ''')), (){});
          await Future.delayed(Duration(milliseconds: await AllimPage.of(context).obd2.getDTCFromJSON('''
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
          ''')), (){
            print("dtc is finished");
          });
        }
      },
    );
  }
}


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