# my_flutter_app

OBD2(ELM327)을 이용한 차량 진단 서비스 어플리케이션

## Getting Started

안내

- 월요일은 시험준비때문에 많이는 손 못댈듯 합니다

진행상황 (2024.04.21)

1. main.dart

    - 기본적인 버튼 구조는 완성

        - Bluetooth 버튼 및 연결 여부 text는 임시로 둔 것 (실제로 어플리케이션 실행시 text는 오버플로우 발생 -> 사소한 문제)

        - 현재 text는 setState로 그럴듯하게 실행

    - 이슈! : getObdData 함수

        - 5분마다 한번꼴로 실행시킬 필요성

        - 지금 당장은 Timer을 사용할 계획이지만, 능력 부족으로 구현은 제대로 못함

            - 코드에 있는 Timer은 제대로 실행 X

    - bluetoothPage.dart 와 통합

        - 버튼을 클릭하면 기기 선택 후 연결

            - 이때 getObdData도 할려고 했으나 아마 초기화문제로 실행은 안되는듯함

        - 다시 버튼을 클릭하면 연결 종료

        - 이슈! : 다시 버튼을 클릭하여 연결을 종료하는 것에서 obd2_plugin.dart의 disconnect함수에서 문제 발생

            - await connection?.close() ;가 원인

            - D/BluetoothSocket(18393): close() this: android.bluetooth.BluetoothSocket@b9f7ab3, channel: 4, mSocketIS: android.net.LocalSocketImpl$SocketInputStream@3bbf870, mSocketOS: android.net.LocalSocketImpl$SocketOutputStream@35b17e9mSocket: android.net.LocalSocket@6485c6e impl:android.net.LocalSocketImpl@40d0f0f fd:java.io.FileDescriptor@8c02b9c, mSocketState: CONNECTED
            2
            D/BluetoothSocket(18393): close() this: android.bluetooth.BluetoothSocket@b9f7ab3, channel: 4, mSocketIS: android.net.LocalSocketImpl$SocketInputStream@3bbf870, mSocketOS: android.net.LocalSocketImpl$SocketOutputStream@35b17e9mSocket: null, mSocketState: CLOSED 

            - 임시로 disconnect 함수를 약간 수정했지만 (connection = null ; 위치 수정) 여전히 제대로 작동되지않음

            - 다행히, 연결 종료 후 다시 버튼을 누르면 기기를 선택하게 하는데 그때 기기를 선택하면 그땐 제대로 연결이 종료

            - 이후 다시 기기를 선택하면 정상적으로 연결

    - Bluetooth 버튼 -> bluetoothPage.dart 와 연결 => 삭제

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
        에러 발생 => 문제 해결

    - 이슈! : 일단 모니터링 버튼을 클릭할때 obd데이터를 받도록 하니깐 데이터를 받는 속도가 느려서 두번 왔다갔다해야 정상적으로 실행됨

        - 그나마 다행인건 모니터링 페이지를 왔다갔다 할때마다 데이터가 매번 다름

        - await등을 활용해볼 필요성

    - 오른쪽 i버튼을 누르면 다이얼로그 생성

    - 다이얼로그에는 텍스트만 존재 (나중에 그래프로 바꿀 예정)

4. allamPage.dart

    - 페이지만 구현

5. settingPage.dart

    - 페이지만 구현

6. bluetoothPairing.dart

    - 삭제(다음 수정땐 이 파트도 삭제)

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
