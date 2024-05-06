// 희홍: 2024-05-06 19:30 업데이트
// monitoringPage.dart
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';
import 'obdData_graphic.dart';
import 'package:intl/intl.dart';

Random random = Random();
final _minuteFormat = DateFormat('ms');
Duration timerLimit = const Duration(seconds: 5);

class MonitoringPage extends StatefulWidget {
  const MonitoringPage({Key? key}) : super(key: key);

  // 부모 위젯의 MonitoringPageState 인스턴스를 찾아서 반환
  static MonitoringPageState of(BuildContext context) =>
      context.findAncestorStateOfType<MonitoringPageState>()!;

  @override
  MonitoringPageState createState() => MonitoringPageState();
}

class MonitoringPageState extends State<MonitoringPage> {
  String searchKeyword = "";
  late Timer _timer;

  @override
  void initState() {
    super.initState();

    // 초기 랜덤한 값 설정
    if (engineRpm == 0 && batteryVoltage == 0) {
      engineRpm = random.nextDouble() * 100;
      batteryVoltage = random.nextDouble() * 100;
      engineTemp = random.nextDouble() * 100;
      vehicleSpeed = random.nextDouble() * 100;
    }

    // 5초마다 값 변경
    _timer = Timer.periodic(timerLimit, (timer) async {
      setState(() {
        engineRpm = random.nextDouble() * 100;
        batteryVoltage = random.nextDouble() * 100;
        engineTemp = random.nextDouble() * 100;
        vehicleSpeed = random.nextDouble() * 100;
        print("change Data");
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Dispose 메서드에서 타이머 취소
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 모니터링 카드 데이터 목록
    List<MonitoringCardData> monitoringCards = [
      MonitoringCardData(
          title: '엔진 온도\n$engineTemp도',
          dialogTitle: '엔진 온도',
          dialogContent: '그래프',
          getValue: () => engineTemp),
      MonitoringCardData(
          title: '배터리 전압\n$batteryVoltage V',
          dialogTitle: '배터리 전압',
          dialogContent: '그래프',
          getValue: () => batteryVoltage),
      MonitoringCardData(
          title: '엔진 RPM\n$engineRpm RPM',
          dialogTitle: '엔진 RPM',
          dialogContent: '그래프',
          getValue: () => engineRpm),
      MonitoringCardData(
          title: '속력\n$vehicleSpeed km/h',
          dialogTitle: '속력',
          dialogContent: '그래프',
          getValue: () => vehicleSpeed),
    ];
    // 검색어에 따라 필터된 모니터링 카드 데이터 목록 생성
    List<MonitoringCardData> filteredCards = monitoringCards.where((card) {
      return card.title.toLowerCase().contains(searchKeyword.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('모니터링 페이지'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchKeyword = value;
                });
              },
              decoration: InputDecoration(
                hintText: '검색어를 입력하세요',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: filteredCards.map((card) {
                return MonitoringCard(
                  title: card.title,
                  cardData: card,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

/// 모니터링 카드 위젯
class MonitoringCard extends StatelessWidget {
  final String title;
  final MonitoringCardData cardData;

  const MonitoringCard({
    Key? key,
    required this.title,
    required this.cardData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: ListTile(
        title: Text(title),
        trailing: IconButton(
          icon: const Icon(Icons.info),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => MonitoringDataDialog(cardData: cardData),
            );
          },
        ),
      ),
    );
  }
}

class MonitoringDataDialog extends StatefulWidget {
  final MonitoringCardData cardData;

  const MonitoringDataDialog({Key? key, required this.cardData})
      : super(key: key);

  @override
  MonitoringDataDialogState createState() => MonitoringDataDialogState();
}

class MonitoringDataDialogState extends State<MonitoringDataDialog> {
  late double dataValue;
  late Timer _timer;
  List<MonitoringDataBySecond> dataValueList = [];
  DateTime chartTime = DateTime(0, 0, 0, 0, 0, 0, 0, 0);

  @override
  void initState() {
    super.initState();
    _updateDataValueList(chartTime);
    _timer = Timer.periodic(timerLimit, (timer) {
      setState(() {
        chartTime = chartTime.add(timerLimit);
        _updateDataValueList(chartTime);
      });
    });
  }

  void _updateDataValueList(DateTime chartTime) {
    dataValue = double.parse(widget.cardData.getValue().toString());
    if (dataValueList.length == 5) {
      dataValueList.removeAt(0);
    }
    dataValueList.add(MonitoringDataBySecond(chartTime, dataValue));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.cardData.dialogTitle),
      content: Chart(
        data: dataValueList,
        variables: {
          'time': Variable(
            accessor: (MonitoringDataBySecond datum) => datum.time,
            scale: TimeScale(
              formatter: (time) => _minuteFormat.format(time),
            ),
          ),
          'data': Variable(
            accessor: (MonitoringDataBySecond datum) => datum.data,
          ),
        },
        marks: [
          LineMark(
            shape: ShapeEncode(value: BasicLineShape(smooth: true)),
            selected: {
              'touchMove': {1}
            },
          )
        ],
        coord: RectCoord(
          color: const Color(0xffdddddd),
          horizontalRange: [0, 1],
        ),
        axes: [
          Defaults.horizontalAxis,
          Defaults.verticalAxis,
        ],
        selections: {
          'touchMove': PointSelection(
            on: {
              GestureType.scaleUpdate,
              GestureType.tapDown,
              GestureType.longPressMoveUpdate
            },
            dim: Dim.x,
          )
        },
        tooltip: TooltipGuide(
          followPointer: [false, true],
          align: Alignment.topLeft,
          offset: const Offset(-20.0, -20.0),
        ),
        crosshair: CrosshairGuide(followPointer: [false, true]),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('닫기'),
        ),
      ],
    );
  }
}

/// 모니터링 카드 데이터 클래스
class MonitoringCardData {
  final String title;
  final String dialogTitle;
  final String dialogContent;
  final Function() getValue;

  MonitoringCardData({
    required this.title,
    required this.dialogTitle,
    required this.dialogContent,
    required this.getValue,
  });
}

class MonitoringDataBySecond {
  final DateTime time;
  final double data;

  MonitoringDataBySecond(this.time, this.data);
}
