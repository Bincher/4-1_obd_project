import 'package:flutter/material.dart';

// 진단 페이지 위젯
class DiagnosisPage extends StatelessWidget {
  final List<String>? diagnosticCodes;

  const DiagnosisPage({Key? key, this.diagnosticCodes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('차량진단'),
      ),
      body: Center(
        child: Column(
          children: [
            const Text(
              '차량진단',
              style: TextStyle(fontSize: 24.0),
            ),
            const SizedBox(height: 20.0),
            diagnosticCodes == null || diagnosticCodes!.isEmpty
                ? _buildNoDiagnosticCodesCard()
                : _buildDiagnosticCodesCard(),
            const SizedBox(height: 20.0),
            const Text(
              '고장코드',
              style: TextStyle(fontSize: 24.0),
            ),
            const SizedBox(height: 20.0),
            diagnosticCodes == null || diagnosticCodes!.isEmpty
                ? _buildNoDiagnosticCodesCardContent()
                : _buildDiagnosticCodesCardContent(),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => (troubleshootingScreen(context))),
                  );
                },
                child: Text("더보기"),
              )
          ],
          
        ),
      ),
    );
  }

  // 고장 코드가 없을 때 표시되는 카드 위젯
  Widget _buildNoDiagnosticCodesCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              '이상 없음',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10.0),
            const Text(
              '0개의 고장 코드 발견',
              style: TextStyle(fontSize: 18.0),
            ),
            const Text(
              '모든 장치에 이상 없음',
              style: TextStyle(fontSize: 18.0),
            ),
          ],
        ),
      ),
    );
  }

  // 고장 코드가 있을 때 표시되는 카드 위젯
  Widget _buildDiagnosticCodesCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              '점검 필요',
              style: TextStyle(fontSize: 18.0),
            ),
            const SizedBox(height: 10.0),
            Text(
              '${diagnosticCodes!.length}개의 고장 코드 발견',
              style: const TextStyle(fontSize: 18.0),
            ),
            const Text(
              '해당 장치에 문제 발생',
              style: TextStyle(fontSize: 18.0),
            ),
            Text(
              diagnosticCodes!.join(', '),
              style: const TextStyle(fontSize: 18.0),
            ),
          ],
        ),
      ),
    );
  }

  // 고장 코드가 없을 때 표시되는 내용 위젯
  Widget _buildNoDiagnosticCodesCardContent() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          '고장코드가 없습니다',
          style: TextStyle(fontSize: 18.0),
        ),
      ),
    );
  }

  // 고장 코드가 있을 때 표시되는 내용 위젯
  Widget _buildDiagnosticCodesCardContent() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: diagnosticCodes!
              .map(
                (code) => Text(
                  code,
                  style: const TextStyle(fontSize: 18.0),
                ),
              )
              .toList(),
        ),
      ),
    );
  }


}




  @override
  Widget troubleshootingScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('상세보기'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                '고장 코드',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                  // 추가적인 스타일 설정 가능
                ),
              ),
            ),
            SizedBox(height: 8.0), // 타이틀과 내용 간격 조정
            Center(
              child: Text(
                'P0001',
                style: TextStyle(
                  
                  fontSize: 16.0,
                ),
              ),
            ),
            SizedBox(height: 8.0),
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: Text('부가 설명', style: TextStyle(fontWeight: FontWeight.bold)), // 타이틀 굵게 표시
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // 내용 간격 조정
                    subtitle: Text(
                      '연료량 조절 회로나 특히 연료량 조절 밸브의 기능에 직접적인 영향을 미치는 문제를 지시합니다. 연료량 조절 밸브는 연료 공급을 조절하여 엔진으로의 연료 흐름을 관리합니다.',
                    ),
                  ),
                ],
              ),
            ),
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: Text('원인', style: TextStyle(fontWeight: FontWeight.bold)), // 타이틀 굵게 표시
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // 내용 간격 조정
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('- 연료량 조절 밸브 고장 (예시 데이터)'),
                        Text('- 연료량 조절 회로의 전기적 문제 (예시 데이터)'),
                        Text('- ECU(엔진 제어 장치) 문제 (예시 데이터)'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: Text('해결 방안', style: TextStyle(fontWeight: FontWeight.bold)), // 타이틀 굵게 표시
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // 내용 간격 조정
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('연료량 조절 밸브와 관련된 모든 전기 연결과 와이어링을 점검합니다. (예시 데이터)'),
                        Text('손상, 착용, 느슨한 연결 또는 부식된 커넥터가 없는지 확인합니다 (예시 데이터)'),
                        Text('연료 압력 조절기와 연료량 조절 밸브 주변의 연료 (예시 데이터)'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

