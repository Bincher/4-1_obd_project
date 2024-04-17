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
