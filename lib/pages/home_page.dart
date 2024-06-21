import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/login_page.dart';
import 'package:flutter_application_1/services/TokenService.dart';
import 'package:flutter_application_1/services/shared_pref.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Future<String> _tokenFuture;
  Timer? _tokenCheckerTimer;
  final shered = SharedpreferenceHelper();

  @override
  void initState() {
    super.initState();
    _tokenFuture = _initializeToken();
    _checkTokenExpiration();

    // Periodic token check every minute
    _tokenCheckerTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      // print("Hello we are in continuous function");
      _checkTokenExpiration();
    });
  }

  Future<String> _initializeToken() async {
    return await SharedpreferenceHelper().getUserToken();
  }

  @override
  void dispose() {
    _tokenCheckerTimer
        ?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  void _checkTokenExpiration() async {
    final token = await _tokenFuture;

    if (JWTService().isTokenExpired(token)) {
      Fluttertoast.showToast(
        msg: "Token expired! Redirecting to login.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.deepPurple,
        textColor: Colors.black,
        fontSize: 16.0,
      );
      _redirectToLogin();
    }
  }

  void _redirectToLogin() {
    print("Hello please try again after some time");
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void signUserOut() {}

  Future<void> callPythonEndpoint() async {
    const url = 'http://172.21.224.1:8030/do_something';
    try {
      final response = await http.post(Uri.parse(url));
      if (response.statusCode == 200) {
        print('Image processing successful.');
      } else {
        print('Error: ${response.statusCode}');
      }
    } 
    catch (error) {
      print('Error calling service callPythonScript: $error');
    }

    // final scriptPath =
    //     '${Platform.resolvedExecutable.replaceAll('flutter', 'script.py')}';
    // print("Script path: $scriptPath");
    // try {
    //   var result = Process.run(scriptPath);
    //   print(result);
    // } catch (e) {
    //   print("Error in calling python script: $e");
    // }
  }


  Future<void> runPython() async {
    try {
      var result = await http.get(Uri.parse('http://172.21.224.1:8030/video_feed'));
      print(result); 
    } 
    catch (e) {
      print('Error calling service runPython: $e');
    }
  }
 



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TinyCare'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            onPressed: signUserOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(10),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        children: [
          _buildTile(
            context,
            'Baby Monitoring',
            Icons.child_care,
            Colors.blue,
            () {
              // Handle baby monitoring tap
              print("Baby Monitoring tapped");
              // callPythonEndpoint();
              runPython();
            },
          ),
          _buildTile(
            context,
            'Temperature',
            Icons.thermostat,
            Colors.red,
            () {
              // Handle temperature tap
              print("Temperature tapped");
            },
          ),
          _buildTile(
            context,
            'Chat with Parents',
            Icons.chat,
            Colors.green,
            () {
              print("Chat with Parents tapped");
            },
          ),
          _buildTile(
            context,
            'Medicine Reminder',
            Icons.medication,
            Colors.orange,
            () {
              print("Medicine Reminder tapped");
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTile(BuildContext context, String title, IconData icon,
      Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 50,
              color: Colors.white,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
