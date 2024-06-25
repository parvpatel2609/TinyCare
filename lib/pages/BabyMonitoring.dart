import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/login_page.dart';
import 'package:flutter_application_1/services/TokenService.dart';
import 'package:flutter_application_1/services/shared_pref.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class BabyMonitoring extends StatefulWidget {
  const BabyMonitoring({super.key});

  @override
  State<BabyMonitoring> createState() => _BabyMonitoringState();
}

class _BabyMonitoringState extends State<BabyMonitoring> {
  late final Future<String> _tokenFuture;
  Timer? _tokenCheckerTimer;
  final shered = SharedpreferenceHelper();
  late WebSocketChannel channel;
  Uint8List? _imageData;

  @override
  void initState() {
    super.initState();
    _tokenFuture = _initializeToken();
    _checkTokenExpiration();

    // Periodic token check every minute
    _tokenCheckerTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      // print("Hello we are in continuous function");
      _checkTokenExpiration();
      _connectWebSocket();
    });
  }

  //connect to socket for streaming baby
  void _connectWebSocket() {
    // print("We are in _connectWebSocket");
    channel = WebSocketChannel.connect(Uri.parse('ws://10.0.0.38:8765'));
    // print("Channel created perfectly");
    channel.stream.listen(
      (message) {
        // print(message);
        setState(() {
          _imageData = base64Decode(message);
        });
        print("set images: $_imageData");
      },
      onError: (error) {
        print('WebSocket error: $error');
      },
      onDone: () {
        print('WebSocket connection closed');
      },
    );
  }

  @override
  void dispose() {
    _tokenCheckerTimer
        ?.cancel(); // Cancel the timer when the widget is disposed
    channel.sink.close();
    super.dispose();
  }

  Future<String> _initializeToken() async {
    return await SharedpreferenceHelper().getUserToken();
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
      body: Center(
          child: _imageData != null
              ? Image.memory(_imageData!)
              : CircularProgressIndicator()),
    );
  }
}
