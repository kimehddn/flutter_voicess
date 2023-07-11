import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'safety.dart';
import 'warning.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Test3Page(),
    );
  }
}

class Test3Page extends StatefulWidget {
  @override
  _Test3PageState createState() => _Test3PageState();
}

class _Test3PageState extends State<Test3Page> {
  var _filePath;
  bool _isLoading = false;
  String _phoneNumber = '';
  String serverResponse = '';

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
        });
      }
    } on PlatformException catch (e) {
      print("지원되지 않는 작업입니다: $e");
    } catch (ex) {
      print(ex);
    }
  }

  void _showPhoneNumberInput() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController _phoneController = TextEditingController();

        return AlertDialog(
          title: Text('전화번호 입력'),
          content: TextField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: '전화번호',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _phoneNumber = _phoneController.text;
                });
                Navigator.pop(context);
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _uploadFile() async {
    if (_filePath != null && _phoneNumber.isNotEmpty) {
      String url = 'http://182.229.34.184:9989/api/client/file';
      String fileName = _filePath.split('/').last;

      setState(() {
        _isLoading = true;
      });

      try {
        while (_isLoading) {
          var request = http.MultipartRequest('POST', Uri.parse(url));
          request.fields['phoneNumber'] = _phoneNumber;
          request.files.add(
            await http.MultipartFile.fromPath('file', _filePath),
          );

          var response = await request.send();

          if (response.statusCode == 200) {
            setState(() {
              serverResponse = '파일 전송 성공';
            });
          } else {
            setState(() {
              serverResponse = '파일 전송 실패';
            });
          }

          // 서버 응답 문자열 가져오기
          var responseString = await response.stream.bytesToString();

          // 서버 응답 확인
          if (responseString == '1') {
            // "위험" 화면으로 전환
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => WarningScreen(() async => responseString)),
            );
            break; // 반복문 종료
          } else if (responseString == '0') {
            // "안전" 화면으로 전환
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SafetyScreen(() => Future.value(responseString))),
            );
            break; // 반복문 종료
          }
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
    return Scaffold(
      appBar: AppBar(
        title: Text('파일 업로드'),
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
            Image.asset('images/icon/check.png'),
            FutureBuilder(
              future: useRootBundle(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text('버전: ${snapshot.data}');
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
            ElevatedButton(
              child: Text('전화번호 입력'),
              onPressed: _showPhoneNumberInput,
            ),
            ElevatedButton(
              child: Text('파일 첨부'),
              onPressed: _openFilePicker,
            ),
            ElevatedButton(
              child: Text('파일 전송'),
              onPressed: _uploadFile,
            ),
            if (_filePath != null)
              Text('첨부한 파일 경로: $_filePath'),
            if (_phoneNumber.isNotEmpty)
              Text('입력한 전화번호: $_phoneNumber'),
            SizedBox(height: 20),
            Text('서버 응답: $serverResponse'),
          ],
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
