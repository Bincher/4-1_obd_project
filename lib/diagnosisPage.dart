import 'package:flutter/material.dart';

class DiagnosisPage extends StatelessWidget {
  final List<String>? diagnosticCodes;

  DiagnosisPage({this.diagnosticCodes});

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
                ? const Card(
                    margin: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Text(
                            '이상 없음',
                            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
                            
                          ),
                          SizedBox(height: 10.0),
                          Text(
                            '0개의 고장 코드 발견',
                            style: TextStyle(fontSize: 18.0),
                          ),
                          Text(
                            '모든 장치에 이상 없음',
                            style: TextStyle(fontSize: 18.0),
                          ),
                        ],
                      ),
                    ),
                  )
                : Card(
                    margin: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Text(
                            '점검 필요',
                            style: TextStyle(fontSize: 18.0),
                          ),
                          SizedBox(height: 10.0),
                          Text(
                            '${diagnosticCodes!.length}개의 고장 코드 발견',
                            style: TextStyle(fontSize: 18.0),
                          ),
                          Text(
                            '해당 장치에 문제 발생',
                            style: TextStyle(fontSize: 18.0),
                          ),
                          Text(
                            diagnosticCodes!.join(', '),
                            style: TextStyle(fontSize: 18.0),
                          ),
                        ],
                      ),
                    ),
                  ),
            SizedBox(height: 20.0),
            Text(
              '고장코드',
              style: TextStyle(fontSize: 24.0),
            ),
            SizedBox(height: 20.0),
            diagnosticCodes == null || diagnosticCodes!.isEmpty
                ? Card(
                    margin: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text(
                        '고장코드가 없습니다',
                        style: TextStyle(fontSize: 18.0),
                      ),
                    ),
                  )
                : Card(
                    margin: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Column(
                        children: diagnosticCodes!
                            .map((code) => Text(
                                  code,
                                  style: TextStyle(fontSize: 18.0),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
