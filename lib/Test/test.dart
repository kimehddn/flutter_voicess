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
  var _filePath;

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
        _uploadFile();
      }
    } on PlatformException catch (e) {
      print("Unsupported operation: $e");
    } catch (ex) {
      print(ex);
    }
  }

  Future<void> _uploadFile() async {
    if (_filePath != null) {
      String url = 'YOUR_UPLOAD_URL';
      String fileName = _filePath.split('/').last;

      try {
        FormData formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(_filePath, filename: fileName),
        });

        Response response = await Dio().post(url, data: formData);

      } catch (e) {
        print(e);
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
        body: Column(
          children: [
            RichText(
                text: TextSpan(
                    text: '제로',
                    style: TextStyle(fontSize: 30, color: Colors.black),
                    children: [
                      TextSpan(
                          text: '베이스',
                          style: TextStyle(fontSize: 20, color: Colors.red)),
                    ])),
            Image.asset('images/icon/chek.png'),
            FutureBuilder(
              future: useRootBundle(),
              builder: (context, snapshot) {
                return Text('Version: ${snapshot.data}');
              },
            ),
            ElevatedButton(
              child: Text('파일 첨부'),
              onPressed: () {
                _openFilePicker();
              },
            ),
            _filePath != null
                ? Text('첨부한 파일 경로: $_filePath')
                : Container(),

          ],
        ),
      ),
    );
  }
}