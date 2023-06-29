import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}


class MyApp extends StatelessWidget {

  Future<String> useRootBundle() async {
    return await rootBundle.loadString('assets/text/safety.txt');
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: Text('안전'),
          ),
          body: Column(
            children: [
              Image.asset('images/safety.png'),
              FutureBuilder(
                  future: useRootBundle(),
                  builder: (context, snapshot){
                    return Text('진단 : ${snapshot.data}');
                  }
              ),
            ],
          )),
    );
  }
}