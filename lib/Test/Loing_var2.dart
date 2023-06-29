import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
    );
  }
}

class User {
  final String email;
  final String password;

  User({required this.email, required this.password});
}

class LoginPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  List<User> users = [];

  void _login(BuildContext context) {
    String email = _emailController.text;
    String password = _passwordController.text;

    //
    User? loginUser = users.firstWhere(
          (User user) => user.email == email && user.password == password,
      orElse: () => User(email: email, password: password),
    );

    if (loginUser != null) {
      // 로그인 성공
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ),
      );
    } else {
      // 로그인 실패
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('로그인 실패'),
          content: Text('아이디 또는 비밀번호가 올바르지 않습니다.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('확인'),
            ),
          ],
        ),
      );
    }
  }

  void _register(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegisterPage(
          users: users,
        ),
      ),
    ).then((newUser) {
      if (newUser != null) {
        users.add(newUser);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('로그인'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: '아이디',
              ),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: '비밀번호',
              ),
            ),
            SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () => _login(context),
              child: Text('로그인'),
            ),
            SizedBox(height: 8.0),
            TextButton(
              onPressed: () => _register(context),
              child: Text('회원가입'),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final List<User> users;

  RegisterPage({required this.users});

  bool _isEmailDuplicate(String email) {
    // 이미 사용 중인 아이디인지 확인
    return users.any((user) => user.email == email);
  }

  void _completeRegistration(BuildContext context) {
    String email = _emailController.text;
    String password = _passwordController.text;

    if (_isEmailDuplicate(email)) {
      // 아이디 중복 확인
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('회원가입 실패'),
          content: Text('이미 사용 중인 아이디입니다.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('확인'),
            ),
          ],
        ),
      );
    } else {
      // 회원가입 완료
      User newUser = User(email: email, password: password);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('회원가입 완료'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('아이디: $email'),
              Text('비밀번호: $password'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, newUser);
              },
              child: Text('확인'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원가입'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: '아이디',
              ),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: '비밀번호',
              ),
            ),
            SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () => _completeRegistration(context),
              child: Text('회원가입 완료'),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('홈'),
      ),
      body: Center(
        child: Text('로그인 성공!'),
      ),
    );
  }
}
