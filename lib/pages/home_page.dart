import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/BabyMonitoring.dart';
import 'package:flutter_application_1/pages/login_page.dart';
import 'package:flutter_application_1/services/TokenService.dart';
import 'package:flutter_application_1/services/shared_pref.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
              //Navitage to Baby Monitoring Page
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => BabyMonitoring()));
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
