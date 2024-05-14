// obdData.dart

import 'dart:async';

class ObdData {
  // 엔진 RPM 상태 변수 및 스트림
  static double engineRpm = 0;
  // 스트림 컨트롤러로 데이터를 구독할 수 있도록 broadcast 방식으로 생성
  static StreamController<double> _engineRpmController = StreamController<double>.broadcast();
  // 외부에서 구독할 수 있는 스트림을 제공
  static Stream<double> get engineRpmStream => _engineRpmController.stream;

  // 배터리 전압 상태 변수 및 스트림
  static double batteryVoltage = 0;
  static StreamController<double> _batteryVoltageController = StreamController<double>.broadcast();
  static Stream<double> get batteryVoltageStream => _batteryVoltageController.stream;

  // 속력 상태 변수 및 스트림
  static double vehicleSpeed = 0;
  static StreamController<double> _vehicleSpeedController = StreamController<double>.broadcast();
  static Stream<double> get vehicleSpeedStream => _vehicleSpeedController.stream;

  // 엔진 온도 상태 변수 및 스트림
  static double engineTemp = 0;
  static StreamController<double> _engineTempController = StreamController<double>.broadcast();
  static Stream<double> get engineTempStream => _engineTempController.stream;

  // 데이터 업데이트 메소드: 새로운 값이 들어올 때 스트림 컨트롤러에 추가하여 구독자들에게 알림
  static void updateEngineRpm(double newRpm) {
    engineRpm = newRpm;
    // 스트림에 업데이트된 값 추가
    _engineRpmController.add(engineRpm);
  }

  static void updateBatteryVoltage(double newVoltage) {
    batteryVoltage = newVoltage;
    _batteryVoltageController.add(batteryVoltage);
  }

  static void updateVehicleSpeed(double newSpeed) {
    vehicleSpeed = newSpeed;
    _vehicleSpeedController.add(vehicleSpeed);
  }

  static void updateEngineTemp(double newTemp) {
    engineTemp = newTemp;
    _engineTempController.add(engineTemp);
  }
}


// DTC 변수(예제)
List<String> DTC = []; // X

class SampleDiagnosticCodeData {
  final String code;
  final String desctiption;
  final String devices;

  SampleDiagnosticCodeData({
    required this.code,
    required this.desctiption,
    required this.devices,
  });

  @override
  String toString() {
    return '$code: $desctiption';
  }
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
        },
        {
            "PID": "AT RV",
            "length": 4,
            "title": "Battery Voltage",
            "unit": "V",
            "description": "<int>",
            "status": true
        }
      ]
    ''';

// OBD에서 DTC에 대한 JSON 데이터
String dtcJson = '''
            [
    {
        "command": "03",
        "description": "",
        "status": true
    }
]
          ''';
