
import 'package:flutter/material.dart';
import 'dart:async';
import '../models/obdData.dart';
import 'package:fl_chart/fl_chart.dart'; // fl_chart를 사용하여 차트 표시
import '../utils/csv_helper.dart'; // csv 데이터 관리

class MonitoringPage extends StatefulWidget {
  const MonitoringPage({Key? key}) : super(key: key);

  @override
  MonitoringPageState createState() => MonitoringPageState();
}

class MonitoringPageState extends State<MonitoringPage> {
  String searchKeyword = "";

  // 모니터링 카드별로 데이터를 관리
  final MonitoringCardData engineTempCard = MonitoringCardData(
    title: '엔진 냉각 온도',
    dialogTitle: '엔진 냉각 온도',
    dialogContent: '엔진 냉각 온도 그래프',
    unit: '℃',
    fileName: 'engine_temp',
  );

  final MonitoringCardData batteryVoltageCard = MonitoringCardData(
    title: '배터리 전압',
    dialogTitle: '배터리 전압',
    dialogContent: '배터리 전압 그래프',
    unit: 'V',
    fileName: 'battery_voltage',
  );

  final MonitoringCardData engineRpmCard = MonitoringCardData(
    title: '엔진 RPM',
    dialogTitle: '엔진 RPM',
    dialogContent: '엔진 RPM 그래프',
    unit: 'RPM',
    fileName: 'engine_rpm',
  );

  final MonitoringCardData vehicleSpeedCard = MonitoringCardData(
    title: '속력',
    dialogTitle: '속력',
    dialogContent: '속력 그래프',
    unit: 'km/h',
    fileName: 'vehicle_speed',
  );

  final MonitoringCardData engineLoadCard = MonitoringCardData(
    title: '엔진 과부화',
    dialogTitle: '엔진 과부화',
    dialogContent: '엔진 과부화 그래프',
    unit: '%',
    fileName: 'engine_load',
  );

  final MonitoringCardData manifoldPressureCard = MonitoringCardData(
    title: '흡입매니폴드',
    dialogTitle: '흡입매니폴드',
    dialogContent: '흡입매니폴드 그래프',
    unit: 'kPa',
    fileName: 'manifold_pressure',
  );

  final MonitoringCardData airTemperatureCard = MonitoringCardData(
    title: '차량 내부 온도',
    dialogTitle: '차량 내부 온도',
    dialogContent: '차량 내부 온도 그래프',
    unit: '°C',
    fileName: 'air_temperature',
  );

  final MonitoringCardData mafCard = MonitoringCardData(
    title: '흡입 공기량',
    dialogTitle: '흡입 공기량',
    dialogContent: '흡입 공기량 그래프',
    unit: 'g/s',
    fileName: 'maf',
  );

  final MonitoringCardData catalystTempCard = MonitoringCardData(
    title: '촉매 온도',
    dialogTitle: '촉매 온도',
    dialogContent: '촉매 온도 그래프',
    unit: '°C',
    fileName: 'catalyst_temp',
  );

  // 데이터 구독을 통해 실시간 업데이트를 위해 스트림을 구독
  late StreamSubscription<double> _rpmSubscription;
  late StreamSubscription<double> _tempSubscription;
  late StreamSubscription<double> _voltageSubscription;
  late StreamSubscription<double> _speedSubscription;
  late StreamSubscription<double> _loadSubscription;
  late StreamSubscription<double> _pressureSubscription;
  late StreamSubscription<double> _mafSubscription;
  late StreamSubscription<double> _catalystTempSubscription;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // CSV 데이터 로드
    loadAllCsvData().then((_) {
      setState(() {});
    });

    // 실시간 데이터 업데이트
    _rpmSubscription = ObdData.engineRpmStream.listen((rpm) {
      setState(() {
        engineRpmCard.addDataPoint(rpm);
        engineRpmCard.saveDataToCsv(); // CSV에 저장
      });
    });

    _tempSubscription = ObdData.engineTempStream.listen((temp) {
      setState(() {
        engineTempCard.addDataPoint(temp);
        engineTempCard.saveDataToCsv(); // CSV에 저장
      });
    });

    _voltageSubscription = ObdData.batteryVoltageStream.listen((voltage) {
      setState(() {
        batteryVoltageCard.addDataPoint(voltage);
        batteryVoltageCard.saveDataToCsv(); // CSV에 저장
      });
    });

    _speedSubscription = ObdData.vehicleSpeedStream.listen((speed) {
      setState(() {
        vehicleSpeedCard.addDataPoint(speed);
        vehicleSpeedCard.saveDataToCsv(); // CSV에 저장
      });
    });

    _loadSubscription = ObdData.engineLoadStream.listen((load) {
      setState(() {
        engineLoadCard.addDataPoint(load);
        engineLoadCard.saveDataToCsv(); // CSV에 저장
      });
    });

    _pressureSubscription = ObdData.manifoldPressureStream.listen((pressure) {
      setState(() {
        manifoldPressureCard.addDataPoint(pressure);
        manifoldPressureCard.saveDataToCsv(); // CSV에 저장
      });
    });

    _mafSubscription = ObdData.mafStream.listen((maf) {
      setState(() {
        mafCard.addDataPoint(maf);
        mafCard.saveDataToCsv(); // CSV에 저장
      });
    });


    _catalystTempSubscription = ObdData.catalystTempStream.listen((temp) {
      setState(() {
        catalystTempCard.addDataPoint(temp);
        catalystTempCard.saveDataToCsv(); // CSV에 저장
      });
    });

    // 5초마다 차트 업데이트
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      setState(() {});
    });
  }

  // 모든 모니터링 카드의 CSV 데이터를 로드
  Future<void> loadAllCsvData() async {
    await engineTempCard.loadDataFromCsv();
    await batteryVoltageCard.loadDataFromCsv();
    await engineRpmCard.loadDataFromCsv();
    await vehicleSpeedCard.loadDataFromCsv();
    await engineLoadCard.loadDataFromCsv();
    await manifoldPressureCard.loadDataFromCsv();
    await mafCard.loadDataFromCsv();
    await catalystTempCard.loadDataFromCsv();
  }

  @override
  void dispose() {
    // 스트림 구독 해제
    _rpmSubscription.cancel();
    _tempSubscription.cancel();
    _voltageSubscription.cancel();
    _speedSubscription.cancel();
    _loadSubscription.cancel();
    _pressureSubscription.cancel();
    _mafSubscription.cancel();
    _catalystTempSubscription.cancel();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 검색어를 기반으로 모니터링 카드를 필터링
    List<MonitoringCardData> monitoringCards = [
      engineTempCard,
      batteryVoltageCard,
      engineRpmCard,
      vehicleSpeedCard,
      engineLoadCard,
      manifoldPressureCard,
      mafCard,
      catalystTempCard
    ];

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
                setState(() => searchKeyword = value);
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
          // 모니터링 카드 목록
          Expanded(
            child: ListView(
              children: filteredCards.map((card) {
                return MonitoringCard(
                  title: '${card.title}\n${card.data.isNotEmpty ? card.data.last['value'].toStringAsFixed(2) : 'N/A'} ${card.unit}',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MonitoringCardGraphPage(card: card),
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

class MonitoringCardGraphPage extends StatefulWidget {
  final MonitoringCardData card;

  const MonitoringCardGraphPage({Key? key, required this.card}) : super(key: key);

  @override
  _MonitoringCardGraphPageState createState() => _MonitoringCardGraphPageState();
}

class _MonitoringCardGraphPageState extends State<MonitoringCardGraphPage> {
  int chartOffset = 0;
  Timer? _refreshTimer;
  Timer? _userPauseTimer;
  bool autoScrollEnabled = true;
  int chartInterval = 12;

  Map<String, dynamic>? selectedData;

  @override
  void initState() {
    super.initState();
    chartOffset = widget.card.data.length > chartInterval ? widget.card.data.length - chartInterval : 0;

    // 5초마다 차트 갱신
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (autoScrollEnabled) {
        setState(() {
          chartOffset = widget.card.data.length > chartInterval ? widget.card.data.length - chartInterval : 0;
        });
      } else {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _userPauseTimer?.cancel();
    super.dispose();
  }

  // 차트를 왼쪽으로 이동
  void moveLeft() {
    setState(() {
      autoScrollEnabled = false;

      // 간격에 맞게 데이터 이동
      if (chartInterval == 12) {
        chartOffset -= 12;
      } else if (chartInterval == 120) {
        chartOffset -= 120;
      } else if (chartInterval == 360) {
        chartOffset -= 360;
      } else {
        chartOffset -= 4;
      }

      if (chartOffset < 0) chartOffset = 0;
    });

    // 사용자가 일시정지한 후 다시 자동 스크롤 활성화
    _userPauseTimer?.cancel();
    _userPauseTimer = Timer(const Duration(seconds: 10), () {
      setState(() {
        autoScrollEnabled = true;
      });
    });
  }

  // 차트를 오른쪽으로 이동
  void moveRight() {
    setState(() {
      if (chartInterval == 12) {
        chartOffset += 12;
      } else if (chartInterval == 120) {
        chartOffset += 120;
      } else if (chartInterval == 360) {
        chartOffset += 360;
      } else {
        chartOffset += 4;
      }

      if (chartOffset + chartInterval > widget.card.data.length) chartOffset = widget.card.data.length - chartInterval;
      if (chartOffset < 0) chartOffset = 0;
    });
  }

  // 차트의 간격(인터벌)을 업데이트
  void updateChartInterval(int interval) {
    setState(() {
      chartInterval = interval;
      autoScrollEnabled = true;
      chartOffset = widget.card.data.length > chartInterval ? widget.card.data.length - chartInterval : 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAtEnd = chartOffset + chartInterval >= widget.card.data.length;
    int numLabels;
    double intervalBetweenLabels;

    // 차트 간격에 따라 레이블 간격 설정
    if (chartInterval == 120) {
      numLabels = 10;
      intervalBetweenLabels = 12;
    } else if (chartInterval == 360) {
      numLabels = 10;
      intervalBetweenLabels = 36;
    } else {
      numLabels = 4;
      intervalBetweenLabels = (chartInterval / numLabels).ceilToDouble();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.card.dialogTitle),
      ),
      body: Column(
        children: [
          // 현재 카드의 마지막 데이터를 표시
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              color: Colors.white,
              elevation: 2.0,
              margin: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  '현재 값: ${widget.card.data.isNotEmpty ? widget.card.data.last['value'].toStringAsFixed(2) : 'N/A'} ${widget.card.unit}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
            ),
          ),
          // fl_chart를 사용하여 라인 차트 생성
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            width: MediaQuery.of(context).size.width * 0.9,
            child: LineChart(
              LineChartData(
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  drawVerticalLine: false,
                  horizontalInterval: widget.card.title == '엔진 RPM' ? 300.0 : 10.0,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.withOpacity(0.5),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: intervalBetweenLabels,
                      getTitlesWidget: (value, _) {
                        final index = value.toInt();
                        final adjustedIndex = index + chartOffset;
                        if (adjustedIndex >= 0 && adjustedIndex < widget.card.data.length) {
                          final timestamp = widget.card.data[adjustedIndex]['timestamp'] as DateTime;
                          if (chartInterval == 12) {
                            return Text(
                              '${timestamp.hour}:${timestamp.minute}:${timestamp.second}',
                              style: const TextStyle(fontSize: 10, color: Colors.black),
                            );
                          } else {
                            return Text(
                              '${timestamp.hour}:${timestamp.minute}',
                              style: const TextStyle(fontSize: 10, color: Colors.black),
                            );
                          }
                        } else {
                          return const Text('');
                        }
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                // 라인 차트 데이터
                lineBarsData: [
                  LineChartBarData(
                    spots: widget.card.getChartData(chartInterval, chartOffset),
                    isCurved: true,
                    barWidth: 3,
                    color: Theme.of(context).primaryColor,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                        radius: 3,
                        color: Theme.of(context).primaryColor,
                        strokeColor: Theme.of(context).primaryColor.withOpacity(0.6),
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [Theme.of(context).primaryColor.withOpacity(0.3), Colors.transparent],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                // 차트 상의 데이터를 선택할 때 반응하는 인터랙션
                lineTouchData: LineTouchData(
                  handleBuiltInTouches: true,
                  touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
                    if (touchResponse != null && touchResponse.lineBarSpots != null && touchResponse.lineBarSpots!.isNotEmpty) {
                      final touchedSpot = touchResponse.lineBarSpots![0];
                      final adjustedIndex = touchedSpot.x.toInt() + chartOffset;
                      if (adjustedIndex >= 0 && adjustedIndex < widget.card.data.length) {
                        setState(() {
                          selectedData = widget.card.data[adjustedIndex]; // 선택된 데이터 저장
                        });
                      }
                    }
                  },
                ),
              ),
            ),
          ),
          // 차트 이동을 위한 화살표 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: moveLeft,
                color: chartOffset > 0 ? Colors.black : Colors.grey,
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: isAtEnd ? null : moveRight,
                color: isAtEnd ? Colors.grey : Colors.black,
              ),
            ],
          ),
          // 차트 간격 변경 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () => updateChartInterval(12),
                child: const Text('1m'),
              ),
              ElevatedButton(
                onPressed: () => updateChartInterval(120),
                child: const Text('10m'),
              ),
              ElevatedButton(
                onPressed: () => updateChartInterval(360),
                child: const Text('30m'),
              ),
            ],
          ),
          // 선택된 데이터에 대한 정보 표시
          if (selectedData != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 3,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '시간: ${DateTime.parse(selectedData!['timestamp'].toString()).hour}:${DateTime.parse(selectedData!['timestamp'].toString()).minute}:${DateTime.parse(selectedData!['timestamp'].toString()).second}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const Divider(),
                  Text(
                    '데이터: ${selectedData!['value']} ${widget.card.unit}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// 모니터링 카드를 위한 데이터 관리 클래스
class MonitoringCardData {
  final String title;
  final String dialogTitle;
  final String dialogContent;
  final String unit;
  final String fileName;
  final List<Map<String, dynamic>> data = [];

  MonitoringCardData({
    required this.title,
    required this.dialogTitle,
    required this.dialogContent,
    required this.unit,
    required this.fileName,
  });

  // 새로운 데이터 포인트를 추가
  void addDataPoint(double value) {
    data.add({
      'timestamp': DateTime.now(),
      'value': value,
    });
  }

  // 데이터를 CSV 파일에 저장
  Future<void> saveDataToCsv() async {
    final List<List<dynamic>> formattedData = data.map((entry) {
      return [entry['timestamp'].toString(), entry['value'].toString()];
    }).toList();

    await CsvHelper.saveCsvFile(fileName, formattedData);
  }

  // CSV 파일에서 데이터를 로드
  Future<void> loadDataFromCsv() async {
    data.clear();
    data.addAll(await CsvHelper.loadDataFromCsv(fileName));
  }

  // CSV 파일 데이터를 삭제
  Future<void> deleteCsvData() async {
    await CsvHelper.deleteCsvFile(fileName);
  }

  // 차트를 위한 데이터를 FlSpot 객체로 반환
  List<FlSpot> getChartData(int maxPoints, [int offset = 0]) {
    final limitedData = data.skip(offset).take(maxPoints).toList();
    return limitedData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value['value'])).toList();
  }
}

// 각 모니터링 카드를 위한 위젯
class MonitoringCard extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;

  const MonitoringCard({
    Key? key,
    required this.title,
    this.onPressed,
  }) : super(key: key);

  showInformation(String title, context) {
    String mainTitle = title.split('\n')[0];
    switch(mainTitle){
      case "엔진 냉각 온도":
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AlertDialog(
              title: Text("엔진 냉각 온도"),
              content: Text(
                "엔진 냉각 온도는 엔진이 작동하는 동안 열을 조절하는 데 중요한 요소입니다.\n\n"
                "자동차의 엔진은 작동 중에 많은 열을 생성하며, 이를 효과적으로 관리하지 않으면 엔진이 과열되어 손상될 수 있습니다. 따라서 냉각 시스템이 필요합니다.\n\n"
                "적정 범위: 일반적으로 엔진 냉각 온도는 85°C에서 105°C 사이여야 합니다.\n\n"
                "이 범위 내에서 엔진이 가장 효율적으로 작동하며, 연료 소모와 배출 가스를 최소화할 수 있습니다.\n\n"
                "문제시 대처 방안:\n\n"
                "엔진 냉각 온도가 105°C를 넘어가면 과열이 발생할 수 있으며, 이 경우에는 차량을 주행 중지하고 냉각 시스템을 확인해야 합니다. 반면에 엔진 냉각 온도가 85°C 미만으로 내려가면 엔진이 효율적으로 작동하지 않을 수 있으며, 이 경우에는 엔진이 충분히 가열될 때까지 주행을 피하는 것이 좋습니다.",
              ),
            );
          },
        );
      case "배터리 전압":
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AlertDialog(
              title: Text("배터리 전압"),
              content: Text(
                "배터리 전압은 자동차의 전기를 공급하는 중요한 요소입니다.\n\n"
                "자동차의 배터리 전압은 대체로 12V로 유지됩니다. 이는 차량의 전기 시스템을 작동시키는 데 필요한 전압입니다. 배터리 전압은 주행 중에 발전기에 의해 충전되며, 차량이 꺼져 있을 때 배터리에서 전기가 소비됩니다. 배터리가 과도하게 방전되거나 충전되지 않으면 차량의 전기 시스템이 올바르게 작동하지 않을 수 있습니다.\n\n"
                "적정 범위: 배터리 전압은 보통 12.4V에서 14.7V 사이여야 합니다.\n\n"
                "이 범위 내에서 배터리가 충분히 충전되어 있음을 나타냅니다. 이 범위를 벗어나면 배터리 상태를 확인해야 합니다.\n\n"
                "문제시 대처 방안:\n\n"
                "배터리 전압이 낮을 경우, 배터리를 충전하거나 교체해야 할 수 있습니다. 또한, 차량이 시동이 걸려 있을 때 13.7V에서 14.7V 사이의 전압을 유지해야 합니다. 이 범위를 벗어나면 발전기에 문제가 있을 수 있으며, 이 경우 정비소를 방문하여 확인하시는 것이 좋습니다.",
              ),
            );
          },
        );
      case "엔진 RPM":
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AlertDialog(
              title: Text("엔진 RPM"),
              content: Text(
                "엔진 RPM은 분당 회전수를 나타내며, 엔진의 작동 속도를 나타냅니다.\n\n"
                "엔진 RPM이 너무 낮거나 높으면 엔진의 효율과 성능에 영향을 줄 수 있습니다. 너무 낮은 RPM은 엔진이 부족하게 회전하여 출발과 가속이 어려울 수 있습니다. 반면에 너무 높은 RPM은 연료 소비를 증가시키고 엔진을 불필요하게 과부하시킬 수 있습니다.\n\n"
                "적정 범위: 자동차의 엔진 RPM은 주행 조건에 따라 다르지만, 일반적으로 안정적인 주행에서는 1000 RPM에서 3000 RPM 사이를 유지해야 합니다.\n\n"
                "문제시 대처 방안:\n\n"
                "엔진 RPM이 너무 낮거나 높을 때는 주행 중 정비소를 방문하여 엔진 상태를 확인하고 조정해야 합니다. 엔진 RPM은 주행 중에도 변동할 수 있으므로, 정기적인 점검이 중요합니다.",
              ),
            );
          },
        );
      case "속력":
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AlertDialog(
              title: Text("속력"),
              content: Text(
                "속력은 자동차가 시간당 이동하는 거리를 나타내며, 자동차의 이동 속도를 의미합니다.\n\n"
                "속력은 운전 중에 중요한 요소로, 도로 교통법규를 준수하고 안전한 주행을 위해 속력을 적절히 조절해야 합니다.\n\n"
                "속력은 주행 조건과 운전자의 습관에 따라 달라지며, 안전운전을 위해 다른 차량 및 도로 상황을 고려하여 적정한 속력을 유지해야 합니다.",
              ),
            );
          },
        );
      case "엔진 과부화":
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AlertDialog(
              title: Text("엔진 과부화"),
              content: Text(
                "엔진 과부화는 엔진이 너무 많은 하중을 받아 성능이 저하되는 현상을 의미합니다.\n\n"
                "자동차의 엔진은 일정 범위 내에서 효율적으로 작동할 수 있도록 설계되어 있습니다. 그러나 과도한 하중이 가해지면 엔진이 과열되고 과도한 열 및 압력에 노출될 수 있으며, 이는 엔진의 성능 저하와 결함으로 이어질 수 있습니다.\n\n"
                "엔진 과부화는 주행 중 가속, 높은 속도 유지, 힘든 지형 등의 상황에서 발생할 수 있으며, 이를 방지하기 위해서는 엔진 부하를 최소화하고 적절한 기술을 사용하여 엔진을 보호해야 합니다.",
              ),
            );
          },
        );
      case "흡입매니폴드":
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AlertDialog(
              title: Text("흡입매니폴드"),
              content: Text(
                "흡입매니폴드는 엔진에서 공기를 흡입하여 연료와 혼합하여 연소하는 부분입니다.\n\n"
                "엔진의 성능과 연비에 직접적인 영향을 미치는 중요한 부품 중 하나입니다. 흡입매니폴드는 공기 흐름을 조절하여 엔진이 최적의 성능을 발휘할 수 있도록 돕습니다.\n\n"
                "적정 범위: 흡입매니폴드의 상태는 주로 시각적으로 확인할 수 있으며, 각 부품의 누출 또는 파손이 없어야 합니다.\n\n"
                "문제시 대처 방안: 흡입매니폴드에 문제가 발생하면 연료 효율성이 저하되거나 엔진 성능이 감소할 수 있습니다. 이 경우 정비소를 방문하여 흡입매니폴드를 점검하고 수리해야 합니다.",
              ),
            );
          },
        );
      case "흡입 공기량":
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AlertDialog(
              title: Text("흡입 공기량"),
              content: Text(
                "흡입 공기량은 엔진에 흡입되는 공기의 양을 나타냅니다.\n\n"
                "엔진은 연소를 위해 적절한 공기와 연료의 혼합을 필요로 합니다. 따라서 흡입 공기량이 부족하거나 과다할 경우에는 연소 과정이 올바르게 이루어지지 않아 엔진 성능에 영향을 미칠 수 있습니다.\n\n"
                "적정 범위: 흡입 공기량은 엔진의 크기 및 운전 조건에 따라 다르며, 일반적으로 엔진 사양에 명시된 공기량 범위 내에 유지되어야 합니다.\n\n"
                "문제시 대처 방안: 흡입 공기량이 부족하거나 과다할 경우, 공기 흡입 시스템의 문제 또는 공기 흡입 필터의 오염 등이 원인일 수 있습니다. 이 경우에는 정비소를 방문하여 공기 흡입 시스템을 점검하고 필요한 조치를 취해야 합니다.",
              ),
            );
          },
        );
      case "촉매 온도":
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AlertDialog(
              title: Text("촉매 온도"),
              content: Text(
                "촉매 온도는 차량의 배기 시스템에 있는 촉매 컨버터 내부의 온도를 나타냅니다.\n\n"
                "촉매 컨버터는 엔진에서 발생하는 유해 가스를 처리하여 환경에 더 친화적인 것으로 변환하는 역할을 합니다. 이를 위해서는 적절한 온도가 유지되어야 합니다.\n\n"
                "적정 범위: 촉매 컨버터는 보통 400°C에서 600°C 사이의 온도에서 가장 효율적으로 작동합니다.\n\n"
                "문제시 대처 방안: 촉매 온도가 너무 낮거나 높으면 촉매 컨버터의 성능이 저하될 수 있습니다. 이 경우에는 엔진 냉각 시스템, 연료 시스템, 또는 촉매 컨버터 자체의 문제를 점검해야 합니다.",
              ),
            );
          },
        );
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: ListTile(
        title: Text(title),
        trailing: Row(
          mainAxisSize: MainAxisSize.min, // Row의 크기를 최소로 설정하여 아이콘들이 왼쪽으로 정렬되도록 함
          children: [
            IconButton(
              icon: const Icon(Icons.info), // graph 아이콘
              onPressed: () => showInformation(title, context), // graph 아이콘 클릭 시 호출될 함수
            ),
            IconButton(
              icon: const Icon(Icons.bar_chart),
              onPressed: onPressed,
            ),
          ],
        ),
      ),
    );
  } 
}

