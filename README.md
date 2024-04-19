# my_flutter_app

OBD2(ELM327)을 이용한 차량 진단 서비스 어플리케이션

## Getting Started

안내

- 토요일에는 코드 못볼듯합니다...

진행상황 (2024.04.19)

1. main.dart

    - 기본적인 버튼 구조는 완성

        - Bluetooth 버튼 및 연결 여부 text는 임시로 둔 것 (실제로 어플리케이션 실행시 text는 오버플로우 발생 -> 사소한 문제)

        - 현재 text는 제대로 작동 안되는 것으로 확인

    - Bluetooth 버튼 -> bluetoothPage.dart 와 연결

    - 차량진단 버튼 -> diagnosisPage.dart 와 연결

    - 모니터링 버튼 -> monitoringPage.dart 와 연결

    - 알람 버튼 -> allimPage.dart 와 연결

    - 세팅 버튼 -> settingPage.dart 와 연결

2. diagnosisPage.dart

    - 3초간의 다이얼로그 출력 (나중에 블루투스 통신에 맞도록 수정할 필요가 있음)

    - 결과물에는 차량진단과 고장코드 출력

    - 고장 코드가 있을 때 표시되는 내용 위젯에 대한 테스트는 아직 진행 안해봄

3. monitoringPage.dart

    - 검색창과 데이터 출력

    - 데이터는 (일단은) 블루투스 데이터 통신으로 값을 받아옴

        - 다만 데이터가 매번 바뀌는지 확인이 안됨

        - 이유는 다른 페이지에 갔다가 돌아오면 "데이터 받기" 버튼 클릭시 
        [ERROR:flutter/runtime/dart_vm_initializer.cc(41)] Unhandled Exception: Exception: onDataReceived is preset and you can not reprogram it
        에러 발생

    - 오른쪽 i버튼을 누르면 다이얼로그 생성

    - 다이얼로그에는 텍스트만 존재 (나중에 그래프로 바꿀 예정)

4. allamPage.dart

    - 페이지만 구현

5. settingPage.dart

    - 페이지만 구현

6. bluetoothPairing.dart

    - 블루투스 페어링을 하는 페이지

    - 3개의 버튼과 1개의 텍스트로 구성

    - 블루투스 연결 버튼을 누르면 디바이스를 선택 후 연결

    - 디바이스 연결 끊기 버튼을 누르면 연결 끊음

    - 데이터 받기 하면 데이터를 받아옴

        - 문제는 결과값이 다음처럼 나옴

        PARAMETER => [{"PID":"AT RV","length":4,"title":"Battery Voltage","unit":"V","description":"<str>","status":true,"response":"OKAT ZELM327 1.5AT E0OKOKOKOKOK13.9"},{"PID":"01 0C","length":2,"title":"Engine RPM","unit":"RPM","description":"<double>, (( [0] * 256) + [1] ) / 4","status":true,"response":"3442.75"},{"PID":"01 0D","length":1,"title":"Speed","unit":"Kh","description":"<int>, [0]","status":true,"response":"0.0"},{"PID":"01 05","length":1,"title":"Engine Temp","unit":"°C","description":"<int>, [0] - 40","status":true,"response":"46.0"}]

        - 이러면 문제가? 배터리 전압을 못구함 => 해결해야할 문제

    - 또다른 문제 : 다른 페이지를 갔다가오면 각 버튼들의 동작이 제대로 작동 안할때가 있음
    
        - 디바이스 연결을 끊고 다시 연결하려고 했을때

        - print("반복하다보면 !(await obd2.isBluetoothEnable)가 안먹히는 문제가 발생?"); 는 출력되는데

        - print("여기는 출력이 안됨"); 이건 출력이 안되는 상황...

        - 아마도 await obd2.isBluetoothEnable 에서 문제가 발생한듯 싶음...

7. obd2_plugin.dart

    - obd2 플러그인

    - https://github.com/begaz/OBDII

- 참고
    - Command 목록
        - https://www.sparkfun.com/datasheets/Widgets/ELM327_AT_Commands.pdf
    - obd연결을 위한 Command들
        - https://stackoverflow.com/questions/13764442/initialization-of-obd-adapter
    - ELM 에뮬
        - https://github.com/Ircama/ELM327-emulator?tab=readme-ov-file
    - PID 목록
        - https://en.wikipedia.org/wiki/OBD-II_PIDs
