# my_flutter_app

OBD2(ELM327)을 이용한 차량 진단 서비스 어플리케이션

## Getting Started

진행상황

1. main.dart

    - 기본적인 버튼 구조는 완성

        - Bluetooth 버튼 및 연결 여부 text는 임시로 둔 것 (실제로 어플리케이션 실행시 text는 오버플로우 발생 -> 사소한 문제)

    - Bluetooth 버튼 -> bluetoothPairing.dart 와 연결

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

    - 데이터는 모두 0으로 고정 (나중에 블루투스 통신에 맞도록 수정할 필요가 있음)

    - 오른쪽 i버튼을 누르면 다이얼로그 생성

    - 다이얼로그에는 텍스트만 존재 (나중에 그래프로 바꿀 예정)

4. allamPage.dart

    - 페이지만 구현

5. settingPage.dart

    - 페이지만 구현

6. bluetoothPairing.dart

    - 블루투스 페어링을 하는 페이지

    - 현재는 기존 예제 코드를 그대로 가져온 것

    - 블루투스 버튼을 누르면 기기들이 출력

    - ELM327에 해당되는 기기를 누르고 다시 블루투스 버튼을 누르면 디버그 콘솔에 결과값 출력

    - 다른 dart 코드는 gpt와 내가 만든거지만 이 코드 만큼은 예제코드를 그대로 들고온거여서 작성자도 아직 제대로 이해는 못했음

7. obd2_plugin.dart

    - obd2 플러그인

    - thanks by https://github.com/begaz/OBDII

- 참고
    - Command 목록
        - https://www.sparkfun.com/datasheets/Widgets/ELM327_AT_Commands.pdf
    - obd연결을 위한 Command들
        - https://stackoverflow.com/questions/13764442/initialization-of-obd-adapter
    - ELM 에뮬
        - https://github.com/Ircama/ELM327-emulator?tab=readme-ov-file
    - PID 목록
        - https://en.wikipedia.org/wiki/OBD-II_PIDs