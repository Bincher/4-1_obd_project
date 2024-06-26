# my_flutter_app

OBD2(ELM327)을 이용한 차량 진단 서비스 어플리케이션

## Getting Started

안내

- 실행하실때 chat-GPT api-key는 꼭 넣어주세요. 여기선 보안상 뺐습니다.

- 블루투스 없는 버전 : mainNoBluetooth.dart 실행

    - 다만, 일부 기능은 사용이 불가하며 일부 기능은 사소한 버그가 존재할 수 있음

    - 누락된 내용 : 모니터링 일부 데이터

- 블루투스 있는 버전 : main.dart 실행

- 노션 : https://bincher.notion.site/APP-a94b22d3d0d14595bbbe7689ab74f201

진행상황 (2024.06.04)

- 중요사항

    - 이번달 마지막 수정일 것 같습니다

    - 먼저 블루투스 연결 종료시 안내문구를 출력

        - 재연결이 안되니 앱 종료 후 다시 켜라라는 내용

    - 그리고 (알림)세팅값이 저장되도록 수정

        - 다크모드는 제외

    - 이번학기 수고하셨습니다

1. main.dart

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

        - 최신 데이터를 받기 위해 5초간의 대기를 한다.

            - 이거 없어도 되긴하는데 있는게 더 있어보이기도 하고 위의 이유도 있고 합니다.

        - 5초 뒤 현재 DTC를 반영한 diagnostisPage를 출력하도록 한다.

    - 결과물에는 차량진단과 고장코드 출력

    - 고장 코드가 있을 때 표시되는 내용 위젯

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

    - 이거 dependencies에 적용이 안되서 직접 넣었습니다. 문제있으시면 연락주세요

7. obdData.dart

    - 필요한 변수나 데이터들을 저장

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

- 아이콘 이미지

    - 앱 이미지 : <a href="https://www.flaticon.com/kr/free-icons/" title="자발적인 아이콘">자발적인 아이콘 제작자: rukanicon - Flaticon</a>
    
    - <a href="https://www.flaticon.com/kr/free-icons/" title="블루투스 아이콘">블루투스 아이콘 제작자: lakonicon - Flaticon</a>

    - <a href="https://www.flaticon.com/kr/free-icons/-" title="자동차 진단 아이콘">자동차 진단 아이콘 제작자: kliwir art - Flaticon</a>

    - <a href="https://www.flaticon.com/kr/free-icons/-" title="소프트웨어 개발 아이콘">소프트웨어 개발 아이콘 제작자: kliwir art - Flaticon</a>

    - <a href="https://www.flaticon.com/kr/free-icons/" title="설정 아이콘">설정 아이콘 제작자: kliwir art - Flaticon</a>

    - <a href="https://www.flaticon.com/kr/free-icons/" title="알림 아이콘">알림 아이콘 제작자: kliwir art - Flaticon</a>

    - <a href="https://www.flaticon.com/kr/free-icons/ecg-" title="ecg 모니터 아이콘">Ecg 모니터 아이콘 제작자: kliwir art - Flaticon</a>

    - <a href="https://www.flaticon.com/kr/free-icons/" title="경고 아이콘">경고 아이콘 제작자: Creatype - Flaticon</a>

    - <a href="https://www.flaticon.com/kr/free-icons/foursquare-" title="foursquare 체크인 아이콘">Foursquare 체크인 아이콘 제작자: hqrloveq - Flaticon</a>
