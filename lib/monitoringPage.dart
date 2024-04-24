// Flutter에서 모니터링 페이지를 구성하는 코드입니다.

import 'package:flutter/material.dart';
import 'package:my_flutter_app/obdData.dart';

// tatefulWidget를 사용하여 모니터링 페이지를 구현합니다.
class MonitoringPage extends StatefulWidget {
  const MonitoringPage({Key? key}) : super(key: key);

  // 부모 위젯의 MonitoringPageState 인스턴스를 찾아서 반환합니다.
  static MonitoringPageState of(BuildContext context) => context.findAncestorStateOfType<MonitoringPageState>()!;
  
  @override
  MonitoringPageState createState() => MonitoringPageState();
}

// 모니터링 페이지의 상태를 관리하는 State 클래스입니다.
class MonitoringPageState extends State<MonitoringPage> {

  String searchKeyword = "";
  // 모니터링 카드 데이터 목록

  // 초기화 시 모니터링 카드 데이터 초기화
    List<MonitoringCardData> monitoringCards = [
      MonitoringCardData(title: '엔진 온도\n${engineTemp}도', dialogTitle: '엔진 온도', dialogContent: '그래프'),
      MonitoringCardData(title: '배터리 전압\n${batteryVoltage} V', dialogTitle: '배터리 전압', dialogContent: '그래프'),
      MonitoringCardData(title: '엔진 RPM\n${engineRpm} RPM', dialogTitle: '엔진 RPM', dialogContent: '그래프'),
      MonitoringCardData(title: '속력\n${vehicleSpeed} km/h', dialogTitle: '속력', dialogContent: '그래프'),
    ];
    
  
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(card.dialogTitle),
                        content: Text(card.dialogContent),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('닫기'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// 모니터링 카드 위젯
class MonitoringCard extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;

  const MonitoringCard({
    Key? key,
    required this.title,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: ListTile(
        title: Text(title),
        trailing: IconButton(
          icon: const Icon(Icons.info),
          onPressed: onPressed,
        ),
      ),
    );
  }
}

// 모니터링 카드 데이터 클래스
class MonitoringCardData {
  final String title;
  final String dialogTitle;
  final String dialogContent;

  MonitoringCardData({
    required this.title,
    required this.dialogTitle,
    required this.dialogContent,
  });
}
