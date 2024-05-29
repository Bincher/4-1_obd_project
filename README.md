# my_flutter_app

OBD2(ELM327)을 이용한 차량 진단 서비스 어플리케이션

## Getting Started

안내

- 실행하실때 chat-GPT api-key는 꼭 넣어주세요. 여기선 보안상 뺐습니다.

- 블루투스 없는 버전 : mainNoBluetooth.dart 실행

    - 다만, 일부 기능은 사용이 불가하며 일부 기능은 사소한 버그가 존재할 수 있음

    - 누락된 내용 : 모니터링 일부 데이터

- 블루투스 있는 버전 : main.dart 실행

- 노션 업데이트 예정 : https://bincher.notion.site/APP-1-a94b22d3d0d14595bbbe7689ab74f201?pvs=4

    - 기존 노션 : https://bincher.notion.site/OBD-3ff8c205246d4af09e46f92234ca2822?pvs=4

    - 일단, 스크린샷 화면은 올려놓겠습니다

진행상황 (2024.05.29)

1. main.dart

    - 기본적인 버튼 구조는 완성

        - Bluetooth 버튼 및 연결 여부 text는 연결 상황에 따라 작동되도록 구성

        - 맨 밑의 2개 버튼은 test를 위한 임시 버튼으로, 실제 구현시에는 제거할 예정

    - 블루투스 연결 버튼

        - 버튼을 클릭하면 기기 선택 후 연결

        - 다시 버튼을 클릭하면 연결 종료

        - 이슈! : 다시 버튼을 클릭하여 연결을 종료하는 것에서 obd2_plugin.dart의 disconnect함수에서 문제 발생

            - await connection?.close() ;가 원인

            - D/BluetoothSocket(18393): close() this: android.bluetooth.BluetoothSocket@b9f7ab3, channel: 4, mSocketIS: android.net.LocalSocketImpl$SocketInputStream@3bbf870, mSocketOS: android.net.LocalSocketImpl$SocketOutputStream@35b17e9mSocket: android.net.LocalSocket@6485c6e impl:android.net.LocalSocketImpl@40d0f0f fd:java.io.FileDescriptor@8c02b9c, mSocketState: CONNECTED
            2
            D/BluetoothSocket(18393): close() this: android.bluetooth.BluetoothSocket@b9f7ab3, channel: 4, mSocketIS: android.net.LocalSocketImpl$SocketInputStream@3bbf870, mSocketOS: android.net.LocalSocketImpl$SocketOutputStream@35b17e9mSocket: null, mSocketState: CLOSED 

            - 임시로 disconnect 함수를 약간 수정했지만 (connection = null ; 위치 수정) 여전히 제대로 작동되지않음

            - 다행히, 연결 종료 후 다시 버튼을 누르면 기기를 선택하게 하는데 그때 기기를 선택하면 그땐 제대로 연결이 종료

            - 이후 다시 기기를 선택하면 정상적으로 연결

    - 차량진단 버튼 -> diagnosisPage.dart 와 연결

    - 모니터링 버튼 -> monitoringPage.dart 와 연결

    - 알람 버튼 -> allimPage.dart 와 연결

    - 세팅 버튼 -> settingPage.dart 와 연결

2. diagnosisPage.dart

    - 페이지 접속 전 

        - 에러코드를 요청하고

        - 에러코드를 받아온다

        - 이 과정에서 다이얼로그 화면을 띄운다

    - 결과물에는 차량진단과 고장코드 출력

        - 이슈! : 아직까지도 차량 진단 결과물이 어떻게 출력되는지 확인을 못함

            - DTC => []

            - 구글링을 통해 ['P0001','P0002] 형식인건 확인 됨

                - 직접 확인되기전까진 해당 형식을 바탕으로 개발

    - 고장 코드가 있을 때 표시되는 내용 위젯

        - 차량진단 버튼을 누르면 에뮬레이터상 개발을 위해 진단 결과 P0001과 P0200이 나오는 것을 가정

        - 차량 진단 결과와 고장 코드에 대한 정보를 출력

        - 고장 코드는 I버튼을 통해 자세한 정보를 출력 가능

            - 이때 자세한 정보는 Chat-gpt를 이용하여 출력

    - 사소한 이슈 : (context as Element).reassemble(); 에서 경고가 발생

        - 경고 : The member 'reassemble' can only be used within instance members of subclasses of 'package:flutter/src/widgets/framework.dart'.dart(invalid_use_of_protected_member)

        - 설명 : reassemble() 메서드는 Element 클래스의 protected member 이며, 따라서 Element의 하위 클래스의 인스턴스 멤버 내에서만 사용할 수 있습니다. 현재 코드에서 context 변수를 이용하여 reassemble() 메서드를 호출하고 있는데, context는 StatefulWidget 또는 StatelessWidget의 build 메서드 내에서만 사용되는 것이 좋습니다.

        - 실행에 문제가 되는건 아니기때문에 최후 순위로 둘 예정

3. monitoringPage.dart

    - 검색창과 데이터 출력

        - 데이터는 (일단은) 블루투스 데이터 통신으로 값을 받아옴

        - provider를 이용한 데이터 연동

        - 검색창을 사용하여 원하는 데이터를 검색 가능

    - 오른쪽 i버튼을 누르면 다이얼로그 생성

        - 다이얼로그에는 해당 데이터의 정보가 존재

    - 오른쪽 그래프 버튼을 누르면 그래프 페이지가 실행
    
        - 그래프페이지는 각 시간별 데이터 값들을 그래프를 통해 출력

        - 원하는 시간의 데이터를 확인 가능

        - 그래프 시간 범위 변경 가능

        - 각 데이터별 정상범위 및 이상 유무를 확인 가능

4. allamPage.dart

    - 알림 세팅 페이지를 구현

        - 현재 알람 기능을 임시로 구현

        - 지금은 1분이지만 실제로는 10분으로 설정 예정
    
    - 이슈!(해결 완료) : DTC를 받는거랑 MonitoringData를 받는게 겹치면 충돌 발생

    - 진단 알림 받기
        
        - default : OFF

        - ON으로 변경시 밑의 2개 기능이 추가

    - TTS 목소리 제공

        - default : ON

        - ON으로 하면 TTS목소리가 알림과 함께 제공

        - 기능 임시로 구현

    - 조용한 알림

        - default : OFF

        - ON으로 하면 차량 진단 결과로 DTC가 없는걸로 나오면 알림을 보내주지 않음

5. settingPage.dart

    - 세팅 페이지를 구현

    - 다크모드, 버전, 도움말, 이용자 약관, 오픈소스 라이센스, 개발자에게 연락

    - 다크코드, 도움말, 개발자에게 연락 구현 완료

        - 다크모드는 일부만 구현

6. obd2_plugin.dart

    - obd2 플러그인

    - https://github.com/begaz/OBDII

7. obdData.dart

    - 필요한 변수나 데이터들을 저장

    - obdData_graphic.dart는 mainNoBluetooth 버전 한정 사용

    - 라이브러리 선택 완료 후 삭제 예정

- 참고
    - Command 목록
        - https://www.sparkfun.com/datasheets/Widgets/ELM327_AT_Commands.pdf
    - obd연결을 위한 Command들
        - https://stackoverflow.com/questions/13764442/initialization-of-obd-adapter
    - ELM 에뮬
        - https://github.com/Ircama/ELM327-emulator?tab=readme-ov-file
    - PID 목록
        - https://en.wikipedia.org/wiki/OBD-II_PIDs
    - bluetooth-serial 라이브러리 문제 해결 방법
        - https://stackoverflow.com/questions/75906535/flutter-bluetooth-permission-missing-in-manifest
    - 앱 이미지 : <a href="https://www.flaticon.com/kr/free-icons/" title="자발적인 아이콘">자발적인 아이콘 제작자: rukanicon - Flaticon</a>

    - 오픈소스 라이선스에 넣을 것

- 아이콘 이미지
    
    - <a href="https://www.flaticon.com/kr/free-icons/" title="블루투스 아이콘">블루투스 아이콘 제작자: lakonicon - Flaticon</a>

    - <a href="https://www.flaticon.com/kr/free-icons/-" title="자동차 진단 아이콘">자동차 진단 아이콘 제작자: kliwir art - Flaticon</a>

    - <a href="https://www.flaticon.com/kr/free-icons/-" title="소프트웨어 개발 아이콘">소프트웨어 개발 아이콘 제작자: kliwir art - Flaticon</a>

    - <a href="https://www.flaticon.com/kr/free-icons/" title="설정 아이콘">설정 아이콘 제작자: kliwir art - Flaticon</a>

    - <a href="https://www.flaticon.com/kr/free-icons/" title="알림 아이콘">알림 아이콘 제작자: kliwir art - Flaticon</a>

    - <a href="https://www.flaticon.com/kr/free-icons/ecg-" title="ecg 모니터 아이콘">Ecg 모니터 아이콘 제작자: kliwir art - Flaticon</a>

    - <a href="https://www.flaticon.com/kr/free-icons/" title="경고 아이콘">경고 아이콘 제작자: Creatype - Flaticon</a>

    <a href="https://www.flaticon.com/kr/free-icons/foursquare-" title="foursquare 체크인 아이콘">Foursquare 체크인 아이콘 제작자: hqrloveq - Flaticon</a>
