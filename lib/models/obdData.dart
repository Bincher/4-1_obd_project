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

  // 엔진 냉각수 온도 상태 변수 및 스트림
  static double engineTemp = 0;
  static StreamController<double> _engineTempController = StreamController<double>.broadcast();
  static Stream<double> get engineTempStream => _engineTempController.stream;

  // 엔진 부화 상태 변수 및 스트림
  static double engineLoad = 0;
  static StreamController<double> _engineLoadController = StreamController<double>.broadcast();
  static Stream<double> get engineLoadStream => _engineLoadController.stream;

  // 흡입매니폴드 압력 변수 및 스트림
  static double manifoldPressure = 0;
  static StreamController<double> _manifoldPressureController = StreamController<double>.broadcast();
  static Stream<double> get manifoldPressureStream => _manifoldPressureController.stream;

  // 흡입 공기량 변수 및 스트림
  static double maf = 0;
  static StreamController<double> _mafController = StreamController<double>.broadcast();
  static Stream<double> get  mafStream => _mafController.stream;

  // 촉매 온도 변수 및 스트림
  static double catalystTemp = 0;
  static StreamController<double> _catalystTempController = StreamController<double>.broadcast();
  static Stream<double> get  catalystTempStream => _catalystTempController.stream;

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

  static void updateEngineLoad(double newLoad) {
    engineLoad = newLoad;
    _engineLoadController.add(engineLoad);
  }

  static void updateManifoldPressureTemp(double newPressure) {
    manifoldPressure = newPressure;
    _manifoldPressureController.add(manifoldPressure);
  }

  static void updateMaf(double newMaf) {
    maf = newMaf;
    _mafController.add(maf);
  }

  static void updateCatalystTempPosition(double newCatalystTemp) {
    catalystTemp = newCatalystTemp;
    _catalystTempController.add(catalystTemp);
  }

}

List<String> dtcArray = [];

class SampleDiagnosticCodeData {
  final String code;


  SampleDiagnosticCodeData({
    required this.code,
  });

  @override
  String toString() {
    return '$code';
  }
}

// OBD에 대한 커맨드를 위한 JSON 데이터
String commandJson = '''[
            {
                "command": "AT D",
                "status": true
            },
            {
                "command": "AT Z",
                "status": true
            },
            {
                "command": "AT E0",
                "status": true
            },
            {
                "command": "AT L0",
                "status": true
            },
            {
                "command": "AT S0",
                "status": true
            },
            {
                "command": "AT H0",
                "status": true
            },
            {
                "command": "AT SP 0",
                "status": true
            }
        ]''';

// OBD에서 매개변수에 대한 JSON 데이터
String paramJson = '''
    [
        {
            "PID": "AT RV",
            "length": 4,
            "description": "<int>",
            "unit": "V",
            "status": true
        },
        {
            "PID": "01 04",
            "description": "<int>, 100 / 255 * [0]",
            "status": true
        },
        {
            "PID": "01 05",
            "description": "<int>, [0] - 40",
            "status": true
        },
        {
            "PID": "01 0B",
            "description": "<int>, [0]",
            "status": true
        }
      ]
    ''';

String paramJson2 = '''
    [
        {
            "PID": "01 0C",
            "description": "<double>, (( [0] * 256) + [1] ) / 4",
            "status": true
        },
        {
            "PID": "01 0D",
            "description": "<int>, [0]",
            "status": true
        },
        {
            "PID": "01 10",
            "description": "<int>, (256 * [0] + [1]) / 100",
            "status": true
        },
        {
            "PID": "01 3C",
            "description": "<int>, (256 * [0] + [1]) / 10 - 40",
            "status": true
        }
      ]
    ''';
// OBD에서 DTC에 대한 JSON 데이터
String dtcJson = '''
            [
        {
                "command": "0100",
                "status": true
        }
  ]
          ''';
