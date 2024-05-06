//csv_helper.dart

import 'dart:io';
import 'package:path_provider/path_provider.dart';

class CsvHelper {
  // CSV 파일을 생성할 디렉토리를 얻어옴
  static Future<String> _getCsvDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // CSV 파일 생성
  static Future<void> saveCsvFile(String fileName, List<List<dynamic>> data) async {
    final path = '${await _getCsvDirectory()}/$fileName.csv';
    final file = File(path);

    final csvData = data.map((row) => row.join(',')).join('\n');
    await file.writeAsString(csvData);
  }

  // CSV 파일 로드
  static Future<List<Map<String, dynamic>>> loadDataFromCsv(String fileName) async {
  final path = '${await _getCsvDirectory()}/$fileName.csv';
  final file = File(path);

  // 파일이 존재하지 않으면 빈 리스트 반환
  if (!await file.exists()) {
    return [];
  }

  // 파일 내용을 읽어서 라인별로 분할
  final lines = await file.readAsLines();
  final List<Map<String, dynamic>> data = [];

  // 라인별로 CSV 데이터 파싱
  for (var line in lines) {
    final values = line.split(',');
    if (values.length == 2) {
      data.add({
        'timestamp': DateTime.parse(values[0]), // 첫 번째 값은 날짜/시간 정보
        'value': double.tryParse(values[1]) ?? 0, // 두 번째 값은 측정 데이터
      });
    }
  }
  print('Loaded data: $data');
  return data;
}

  // CSV 파일 삭제
  static Future<void> deleteCsvFile(String fileName) async {
    final path = '${await _getCsvDirectory()}/$fileName.csv';
    final file = File(path);
    
    if (await file.exists()) {
      await file.delete();
    }
  }
}
