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
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  var _filePath;
  bool _isLoading = false;
  String _phoneNumber = '';
  String serverResponse = '';
  String serverpPrcent = '';

  Future<String> useRootBundle() async {
    return await rootBundle.loadString('assets/text/my_text.txt');
  }

  Future<void> _openFilePicker() async {
    try {
      setState(() {
        _isLoading = true;
      });

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
    } finally {
      setState(() {
        _isLoading = false;
      });
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
      String url = 'http://182.229.34.184:5502/api/VoiClaReq';
      String fileName = _filePath.split('/').last;

      setState(() {
        _isLoading = true;
        serverResponse = '';
      });

      try {
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

          var responseString = await response.stream.bytesToString();

          if (responseString == '1') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => WarningScreen(() async => responseString)),
            );
          } else if (responseString == '0') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SafetyScreen(() => Future.value(responseString))),
            );
          }
        } else {
          setState(() {
            serverResponse = '파일 전송 실패';
          });
        }
      } catch (e) {
        print(e);
      } finally {
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
                style: TextStyle(fontSize: 60, color: Colors.black),
                children: [
                  TextSpan(
                    text: '베이스',
                    style: TextStyle(fontSize: 40, color: Colors.red),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),
            Image.asset(
              'images/icon/check.png',
              width: 200,
              height: 200,
            ),
            SizedBox(height: 40),
            FutureBuilder(
              future: useRootBundle(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {
                    return Text(
                      '버전: ${snapshot.data}',
                      style: TextStyle(fontSize: 20),
                    );
                  } else {
                    return Text(
                      '버전을 불러올 수 없습니다.',
                      style: TextStyle(fontSize: 20),
                    );
                  }
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text(
                '전화번호 입력',
                style: TextStyle(fontSize: 20),
              ),
              onPressed: _showPhoneNumberInput,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text(
                '파일 첨부',
                style: TextStyle(fontSize: 20),
              ),
              onPressed: _openFilePicker,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text(
                '파일 전송',
                style: TextStyle(fontSize: 20),
              ),
              onPressed: _uploadFile,
            ),
            SizedBox(height: 20),
            if (_filePath != null)
              Text(
                '첨부한 파일 경로: $_filePath',
                style: TextStyle(fontSize: 16),
              ),
            if (_phoneNumber.isNotEmpty)
              Text(
                '입력한 전화번호: $_phoneNumber',
                style: TextStyle(fontSize: 16),
              ),
            SizedBox(height: 20),
            Text(
              '서버 응답: $serverResponse',
              style: TextStyle(fontSize: 20),
            ),
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
