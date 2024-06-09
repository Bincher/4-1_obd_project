// diagnosisPage.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../models/obdData.dart';

class DiagnosisPage extends StatelessWidget {
  const DiagnosisPage({Key? key, this.diagnosticCodes}) : super(key: key);
  /// 진단 코드 리스트
  final List<SampleDiagnosticCodeData>? diagnosticCodes;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('차량진단'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, // 중앙 정렬
            children: [
              const SizedBox(height: 20.0), // 상단 여백 추가
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
                  : Column(
                      // Column으로 고장 코드 카드 위젯 반환
                      crossAxisAlignment: CrossAxisAlignment.start, // 카드 내용은 왼쪽 정렬
                      children: diagnosticCodes!.map((code) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: _buildDiagnosticCodesCardContent(code, context),
                        );
                      }).toList(),
                    ),
              const SizedBox(height: 20.0), // 하단 여백 추가
            ],
          ),
        ),
      ),
    );
  }



  /// 고장 코드가 없을 때 표시되는 카드 위젯
  Widget _buildNoDiagnosticCodesCard() {
    return const Card(
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
    );
  }

  /// 고장 코드가 있을 때 표시되는 카드 위젯
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
          ],
        ),
      ),
    );
  }

  /// 고장 코드가 없을 때 표시되는 내용 위젯
  Widget _buildNoDiagnosticCodesCardContent() {
    return const Card(
      margin: EdgeInsets.symmetric(horizontal: 20.0),
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Text(
          '고장코드가 없습니다',
          style: TextStyle(fontSize: 18.0),
        ),
      ),
    );
  }

  /// 고장 코드가 있을 때 표시되는 내용 위젯
  Widget _buildDiagnosticCodesCardContent(
      SampleDiagnosticCodeData code, BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(code.code),
        trailing: IconButton(
          icon: const Icon(Icons.info),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => chatGPTOpinionScreen(context, code)),
            );
          },
        ),
      ),
    );
  }
}

/// chatGPT를 이용한 상세화면 
Widget chatGPTOpinionScreen(BuildContext context, SampleDiagnosticCodeData code) {
  final String codeAsString = code.toString();
  return Scaffold(
    appBar: AppBar(
      title: const Text('AI 조언'),
      actions: [
        IconButton( //새로고침 버튼 추가
          icon: const Icon(Icons.refresh),
          onPressed: () {
            // 상태를 업데이트하는 로직을 추가
            (context as Element).reassemble(); // reassemble 경고 발생
          },
        ),
      ],
    ),
    //futureBuilder 를 이용해서 비동기적으로 데이터를 받아옴
    body: FutureBuilder(
      future: fetchChatGPTResponse(codeAsString),
      builder: (BuildContext context, AsyncSnapshot<Map<String, String>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error.toString()}'));
        } else if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text("No data available"));
        } else {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                '고장 코드',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0),
                ),
                Text(
                  '$code',
                  style: const TextStyle(fontSize: 20.0),
                ),
                const SizedBox(height: 20.0), // 공백을 위한 SizedBox
                _buildResponseCard('부가 설명', snapshot.data?['description'] ?? 'No data'),
                _buildResponseCard('원인', snapshot.data?['cause'] ?? 'No data'),
                _buildResponseCard('해결 방안', snapshot.data?['solution'] ?? 'No data'),
              ],
            ),
          );
        }
      },
    ),
  );
}

/// gpt를 통한 결과물을 출력할 카드
Widget _buildResponseCard(String title, String content) {
  return Card(
    child: ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(content), // Null 체크를 추가 -> flutter 권장대로 제거했습니다 (?? : "contents")
    ),
  );
}

/// GPT Request와 Response
Future<Map<String, String>> fetchChatGPTResponse(String code) async {
  const apiKey = 'API-KEY'; // 보안 문제로 제거, 따로 추가해주세요
  const apiUrl = 'https://api.openai.com/v1/chat/completions';

  Map<String, String> results = {
    'description': '정보 없음',
    'cause': '정보 없음',
    'solution': '정보 없음',
  };

  // API에 특정 요청을 보내는 함수
  // prompt에 따라 다른 파트의 내용을 가져옴
  Future<String> fetchPart(String prompt) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: json.encode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {'role': 'system', 'content': 'You are a helpful assistant.'},
          {'role': 'user', 'content': prompt}
        ],
        'max_tokens': 300, // 최대 300 토큰이 리미트
      }),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(utf8.decode(response.bodyBytes));
      final content = responseData['choices'][0]['message']['content'];
      return content.trim();
    } else {
      throw Exception('Failed to load part: Status code ${response.statusCode}');
    }
  }

  // 비동기적 처리
  try {
    final description = fetchPart("자동차 진단코드 $code에 대한 기본적인 설명을 간결하게 한글로 말해줘");
    final cause = fetchPart("자동차 진단코드 $code의 원인을  다른 말은 붙이지말고 3가지만 한글로 말해줘");
    final solution = fetchPart("자동차 진단코드 $code의 다른 설명은 하지말고 해결방안을 300자 이내로 한글로 말해줘");

    results = {
      'description': await description,
      'cause': await cause,
      'solution': await solution,
    };
  } catch (e) {
    print("Error fetching data: $e");
  }

  return results;
}
