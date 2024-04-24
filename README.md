# my_flutter_app

OBD2(ELM327)을 이용한 차량 진단 서비스 어플리케이션

## Getting Started

안내

- 블루투스 없는 버전 : https://github.com/Bincher/4-1_obd_project/tree/main/lib

- 블루투스 있는 버전 : https://github.com/Bincher/4-1_obd_project/blob/0065cfad3d738445b842c131fffe812489e56249/lib/main.dart

- 노션 업데이트 예정 : https://bincher.notion.site/APP-1-a94b22d3d0d14595bbbe7689ab74f201?pvs=4

    - 기존 노션 : https://bincher.notion.site/OBD-3ff8c205246d4af09e46f92234ca2822?pvs=4

- 진단페이지 구성

    1. 문제 발생시 진단 페이지

    2. 상세 보기

    3. chat-gpt api를 이용한 3가지 정보 받고 출력하기

진행상황 (2024.04.22)

1. main.dart

    - 기본적인 버튼 구조는 완성

        - Bluetooth 버튼 및 연결 여부 text는 임시로 둔 것

        - 현재 text는 setState로 그럴듯하게 실행

    - 이슈(해결됨) : getObdData 함수

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

    - 페이지 접속 전 

        - 에러코드를 요청하고

        - 에러코드를 받아온다

        - 이 과정에서 다이얼로그 화면을 띄운다(gpt가 만들어준건데 진짜 잘만들었다.)

    - 결과물에는 차량진단과 고장코드 출력

        - 이슈! : 아직까지도 차량 진단 결과물이 어떻게 출력되는지 확인을 못함

        - DTC => []

        - 위 내용을 바탕으로 추측해서 만드는 것이 최선

    - 고장 코드가 있을 때 표시되는 내용 위젯에 대한 테스트는 아직 진행 안해봄

3. monitoringPage.dart

    - 검색창과 데이터 출력

    - 데이터는 (일단은) 블루투스 데이터 통신으로 값을 받아옴

        - 버튼 클릭시 차량 데이터가 초기화가 안되었다면 차량으로 부터 데이터를 받아옴

    - 이슈(해결됨) : 일단 모니터링 버튼을 클릭할때 obd데이터를 받도록 하니깐 데이터를 받는 속도가 느려서 두번 왔다갔다해야 정상적으로 실행됨

    - 이슈! : 1분마다 데이터가 변경되는데 문제는 모니터링 페이지에 계속 머물시 데이터가 변경되더라도 화면 출력 값은 그대로

        - 다른 페이지에 갔다와야 반영

        - setState를 사용하면 쉽게 될 줄 알았지만 생각외로 쉽게 안됨

    - 오른쪽 i버튼을 누르면 다이얼로그 생성

    - 다이얼로그에는 텍스트만 존재 (나중에 그래프로 바꿀 예정)

4. allamPage.dart

    - 페이지만 구현

5. settingPage.dart

    - 페이지만 구현

6. obd2_plugin.dart

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
