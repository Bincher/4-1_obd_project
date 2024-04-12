import 'package:flutter/material.dart';

class AllimPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('알림'),
      ),
      body: Center(
        child: Text(
          '알림 페이지',
          style: TextStyle(fontSize: 24.0),
        ),
      ),
    );
  }
}
