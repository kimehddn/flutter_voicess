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

enum ServerResponse { TRUE, FALSE, NONE }

class _MyAppState extends State<MyApp> {
  var _filePath;
  bool _isLoading = false;
  ServerResponse _serverResponse = ServerResponse.NONE;

  Future<String> useRootBundle() async {
    return await rootBundle.loadString('assets/text/my_text.txt');
  }

  Future<void> _openFilePicker() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        PlatformFile file = result.files.first;
        setState(() {
          _filePath = file.path!;
          _serverResponse = ServerResponse.NONE;
        });
      }
    } on PlatformException catch (e) {
      print("Unsupported operation: $e");
    } catch (ex) {
      print(ex);
    }
  }

  Future<void> _uploadFile() async {
    if (_filePath != null) {
      String url = 'http://182.229.34.184:9966/api/client/file_byte';
      String fileName = _filePath.split('/').last;

      setState(() {
        _isLoading = true;
      });

      try {
        FormData formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(_filePath, filename: fileName),
        });

        // 파일 전송 시작
        Response response = await Dio().post(url, data: formData);

        // 파일 전송이 완료된 후 처리
        if (response.statusCode == 200) {
          setState(() {
            _isLoading = false;
            _serverResponse = ServerResponse.TRUE;
            _filePath = null;
          });
        } else {
          setState(() {
            _isLoading = false;
            _serverResponse = ServerResponse.FALSE;
          });
        }
      } catch (e) {
        print(e);
        setState(() {
          _isLoading = false;
          _serverResponse = ServerResponse.FALSE;
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
              if (_filePath != null)
                Text('첨부한 파일 경로: $_filePath')
              else
                Container(),
              if (_serverResponse == ServerResponse.TRUE)
                Text('서버에서 받은 값이 참입니다.', style: TextStyle(color: Colors.green)),
              if (_serverResponse == ServerResponse.FALSE)
                Text('서버에서 받은 값이 거짓입니다.', style: TextStyle(color: Colors.red)),
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
