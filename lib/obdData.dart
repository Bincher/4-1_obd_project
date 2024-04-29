// obdData.dart

// 엔진 RPM 상태 변수
double engineRpm = 0;
// 배터리 전압 상태 변수
double batteryVoltage = 0;
// 속력 상태 변수
double vehicleSpeed = 0;
// 엔진 온도 상태 변수
double engineTemp = 0;
// DTC 변수(예제)
List<String> DTC = ['P0001', 'P0200']; // X

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
    return code;
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
