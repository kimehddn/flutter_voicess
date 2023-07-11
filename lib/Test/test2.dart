import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  File? _file;
  bool _isLoading = false;
  late Dio _dio;

  @override
  void initState() {
    super.initState();
    _dio = Dio();
  }

  Future<String> useRootBundle() async {
    return await rootBundle.loadString('assets/text/my_text.txt');
  }

  Future<void> _openFilePicker() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        PlatformFile file = result.files.first;
        setState(() {
          _file = File(file.path!);
        });
      }
    } on PlatformException catch (e) {
      print("Unsupported operation: $e");
    } catch (ex) {
      print(ex);
    }
  }

  Future<void> _uploadFile() async {
    if (_file != null && _file!.existsSync()) {
      String url = 'http://182.229.34.184:9966/api/client/file_byte';
      String fileName = _file!.path.split('/').last;

      setState(() {
        _isLoading = true;
      });

      try {
        FormData formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(_file!.path, filename: fileName),
        });

        // 파일 전송 시작
        Response response = await _dio.post(url, data: formData);

        // 파일 전송이 완료된 후 처리
        setState(() {
          _isLoading = false;
          _file = null; // 파일 초기화
        });

        // 서버 응답 처리
        if (response.statusCode == 200) {
          // 서버 응답이 성공인 경우
          print('서버 응답 성공');
          // TODO: 서버 응답에 대한 추가 처리 수행
        } else {
          // 서버 응답이 실패인 경우
          print('서버 응답 실패');
          // TODO: 실패 처리에 대한 로직 구현
        }
      } catch (e) {
        print(e);
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('보이스피싱 검사'),
        ),
        body: _isLoading
            ? LoadingScreen()
            : SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RichText(
                text: TextSpan(
                  text: '제로',
                  style: TextStyle(fontSize: 30, color: Colors.black),
                  children: [
                    TextSpan(
                      text: '베이스',
                      style: TextStyle(fontSize: 20, color: Colors.red),
                    ),
                  ],
                ),
              ),
              Image.asset('images/icon/chek.png'),
              FutureBuilder(
                future: useRootBundle(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text('Version: ${snapshot.data}');
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              ),
              ElevatedButton(
                child: Text('파일 첨부'),
                onPressed: () {
                  _openFilePicker();
                },
              ),
              ElevatedButton(
                child: Text('파일 전송'),
                onPressed: () {
                  _uploadFile();
                },
              ),
              if (_file != null)
                Text('첨부한 파일 경로: ${_file!.path}')
              else
                Container(),
            ],
          ),
        ),
      ),
    );
  }
}

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.red.shade500,
            Colors.purple,
            Colors.blue.shade500,
          ],
        ),
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      ),
    );
  }
}
