// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:my_flutter_app/pages/home/main.dart';
import 'package:my_flutter_app/pages/monitoringPage.dart';
import 'package:my_flutter_app/models/obdData.dart';

void main() {

  group("Main", () {
    testWidgets('Check initial state', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());

      // Bluetooth 연결 상태 초기값 확인
      expect(isConnected, false);

      // 홈 화면이 정상적으로 렌더링되었는지 확인
      expect(find.text('차량 정비 Application'), findsOneWidget);
    });

    testWidgets('Check diagnosis button click with Bluetooth connected', (WidgetTester tester) async {
      // Bluetooth 연결 상태를 true로 설정합니다.
      isConnected = true;

      // 앱을 빌드합니다.
      await tester.pumpWidget(MyApp());

      // 진단코드 버튼을 탭합니다.
      await tester.tap(find.text('차량진단'));

      // 비동기 작업이 완료될 때까지 잠시 기다립니다.
      await tester.pump();

      // 진단 페이지로 이동했는지 확인합니다.
      expect(find.text('진단 중'), findsOneWidget);
    });

    testWidgets('Check diagnosis button click with Bluetooth disconnected', (WidgetTester tester) async {
      // Bluetooth 연결 상태를 false로 설정합니다.
      isConnected = false;

      // 앱을 빌드합니다.
      await tester.pumpWidget(MyApp());

      // 진단코드 버튼을 탭합니다.
      await tester.tap(find.text('차량진단'));

      // 비동기 작업이 완료될 때까지 잠시 기다립니다.
      await tester.pump();

      // 경고 다이얼로그가 표시되었는지 확인합니다.
      expect(find.text('블루투스 에러!'), findsOneWidget);
    });


    testWidgets('Check monitoring button click with Bluetooth disconnected', (WidgetTester tester) async {
      // Bluetooth 연결 상태를 false로 설정합니다.
      isConnected = false;

      // 앱을 빌드합니다.
      await tester.pumpWidget(MyApp());

      // 모니터링 버튼을 탭합니다.
      await tester.tap(find.text('모니터링'));

      // 비동기 작업이 완료될 때까지 잠시 기다립니다.
      await tester.pump();

      // 경고 다이얼로그가 표시되었는지 확인합니다.
      expect(find.text('블루투스 에러!'), findsOneWidget);
    });

    testWidgets('Check Monitoring page display', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());

      // Bluetooth 연결 상태 확인
      isConnected = true;

      // 모니터링 버튼 클릭
      await tester.tap(find.text('모니터링'));
      await tester.pumpAndSettle();

      // 모니터링 페이지가 표시되는지 확인
      expect(find.byType(MonitoringPage), findsOneWidget);
    });


  });

    group('OBD Data Tests', () {
      // 각 테스트가 실행되기 전에 호출되는 초기 설정 함수
      setUp(() {
        // 각 테스트 시작 전에 모든 데이터를 0으로 초기화
        ObdData.updateEngineRpm(0);
        ObdData.updateBatteryVoltage(0);
        ObdData.updateVehicleSpeed(0);
        ObdData.updateEngineTemp(0);
      });

      // 초기 값이 0인지 확인하는 테스트
      test('Initial values should be zero', () {
        expect(ObdData.engineRpm, 0);
        expect(ObdData.batteryVoltage, 0);
        expect(ObdData.vehicleSpeed, 0);
        expect(ObdData.engineTemp, 0);
      });

      // 엔진 RPM을 업데이트하고 적절히 반영되었는지 테스트
      test('Updating engine RPM to 3000', () {
        ObdData.updateEngineRpm(3000);
        expect(ObdData.engineRpm, 3000);
      });

      // 배터리 전압을 업데이트하고 적절히 반영되었는지 테스트
      test('Updating battery voltage to 12.5', () {
        ObdData.updateBatteryVoltage(12.5);
        expect(ObdData.batteryVoltage, 12.5);
      });

      // 차량 속도를 업데이트하고 적절히 반영되었는지 테스트
      test('Updating vehicle speed to 60 km/h', () {
        ObdData.updateVehicleSpeed(60);
        expect(ObdData.vehicleSpeed, 60);
      });

      // 엔진 온도를 업데이트하고 적절히 반영되었는지 테스트
      test('Updating engine temperature to 90°C', () {
        ObdData.updateEngineTemp(90);
        expect(ObdData.engineTemp, 90);
      });

      // 스트림이 업데이트된 RPM 값을 제대로 발행하는지 테스트
      test('Engine RPM stream emits updated value', () async {
        var rpmStream = ObdData.engineRpmStream;
        ObdData.updateEngineRpm(3500);
        // 스트림에서 3500 값을 발행할 것으로 예상
        await expectLater(rpmStream, emitsInOrder([3500]));
      });

      // 스트림이 업데이트된 배터리 전압 값을 제대로 발행하는지 테스트
      test('Battery Voltage stream emits updated value', () async {
        var voltageStream = ObdData.batteryVoltageStream;
        ObdData.updateBatteryVoltage(13.2);
        // 스트림에서 13.2 값을 발행할 것으로 예상
        await expectLater(voltageStream, emitsInOrder([13.2]));
      });

      // 스트림이 업데이트된 차량 속도 값을 제대로 발행하는지 테스트
      test('Vehicle Speed stream emits updated value', () async {
        var speedStream = ObdData.vehicleSpeedStream;
        ObdData.updateVehicleSpeed(70);
        // 스트림에서 70을 발행할 것으로 예상
        await expectLater(speedStream, emitsInOrder([70]));
      });

      // 스트림이 업데이트된 엔진 온도 값을 제대로 발행하는지 테스트
      test('Engine Temp stream emits updated value', () async {
        var tempStream = ObdData.engineTempStream;
        ObdData.updateEngineTemp(95);
        // 스트림에서 95를 발행할 것으로 예상
        await expectLater(tempStream, emitsInOrder([95]));
      });
    });


}