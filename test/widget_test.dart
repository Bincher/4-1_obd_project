// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:my_flutter_app/pages/home/main.dart';
import 'package:my_flutter_app/pages/monitoringPage.dart';

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

}