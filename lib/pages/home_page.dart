import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/chatlist_page.dart';
import 'package:flutter_application_1/pages/login_page.dart';
import 'package:flutter_application_1/pages/notification_services.dart';
import 'package:flutter_application_1/services/TokenService.dart';
import 'package:flutter_application_1/services/shared_pref.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

final navigatorkey = GlobalKey<NavigatorState>();

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Future<String> _tokenFuture;
  Timer? _tokenCheckerTimer;
  final shered = SharedpreferenceHelper();
  WebSocketChannel? channel;
  WebSocketChannel? channel_eye_checking;
  StreamController<dynamic> _controller = StreamController.broadcast();
  NotificationServices notificationServices = NotificationServices();

  @override
  void initState() {
    super.initState();
    _tokenFuture = _initializeToken();
    _checkTokenExpiration();

    // Periodic token check every minute
    _tokenCheckerTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _checkTokenExpiration();
    });

    _connectWebSocket();
    _connectEyeCheckingWebSocket();

    notificationServices.requestNotificationPermission();
    notificationServices.firebaseInit(context);
    notificationServices.setupInteractMessage(context);
    // notificationServices.isTokenRefresh();
    notificationServices.getDeviceToken().then((value) {
      print("device token");
      print(value);
    });
  }

  //connect to socket for streaming baby
  void _connectWebSocket() {
    print("We are in _connectWebSocket");
    channel = WebSocketChannel.connect(Uri.parse('ws://192.168.1.5:8760'));
    // print("Channel created perfectly in video streaming");
    channel!.stream.listen(
      (message) {
        // print(message);
        setState(() {
          //update state if needed
          _controller.add(message);
        });
        // print("set images: $_imageData");
      },
      onError: (error) {
        print('WebSocket error: $error');
      },
      onDone: () {
        print('WebSocket connection closed');
      },
    );
  }

  //connecting with eye checking alert server
  void _connectEyeCheckingWebSocket() {
    print("We are in _connectEyeCheckingWebSocket");
    channel_eye_checking =
        WebSocketChannel.connect(Uri.parse('ws://192.168.1.5:8765'));
    print("Channel created perfectly");
    // print("Channel details: $channel_eye_checking");
    channel_eye_checking!.stream.listen(
      (message) {
        print("Message comes from server: $message");

        //write a code for sending notification on mobile
        notificationServices.requestNotificationPermission();
        notificationServices.firebaseInit(context);
        notificationServices.setupInteractMessage(context);
        notificationServices.getDeviceToken().then((value) {
          print("device token");
          print(value);
        });

        if (message == "True") {
          _sendNotification('Eye status is from closed to open..', '');
        }
        if (message == "False") {
          _sendNotification('Eyes are closed..', '');
        }
      },
      onError: (error) {
        print('WebSocket error in eye checking function: $error');
      },
      onDone: () {
        print('WebSocket connection closed in eye checking');
      },
    );
    print("We are outside channel connection");
  }

  void _sendNotification(String title, String body) {
    RemoteMessage remoteMessage = RemoteMessage(
      notification: RemoteNotification(
        title: title,
        body: body,
      ),
    );

    notificationServices.showNotification(remoteMessage);
  }

  Future<String> _initializeToken() async {
    // String? token = await SharedpreferenceHelper().getUserToken();
    // print("Retrieved Token: $token");
    return await SharedpreferenceHelper().getUserToken();
  }

  @override
  void dispose() {
    _tokenCheckerTimer
        ?.cancel(); // Cancel the timer when the widget is disposed
    channel!.sink.close();
    channel_eye_checking!.sink.close();
    super.dispose();
  }

  void _checkTokenExpiration() async {
    final token = await _tokenFuture;
    print("Checking token expiration for: $token");

    if (JWTService().isTokenExpired(token)) {
      Fluttertoast.showToast(
        msg: "Token expired! Redirecting to login.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.deepPurple,
        textColor: Colors.black,
        fontSize: 16.0,
      );
      shered.saveUserEmail("USEREMAILKEY");
      shered.saveUserId("USERIDKEY");
      shered.saveUserToken("USERTOKENKEY");
      _redirectToLogin();
    }
  }

  void _redirectToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void signUserOut() {
    // shered.saveUserEmail("USEREMAILKEY");
    // shered.saveUserId("USERIDKEY");
    // shered.saveUserToken("USERTOKENKEY");
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
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
      body: Column(
        children: [
          const SizedBox(height: 40.0),
          StreamBuilder(
            stream: _controller.stream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }
              if (snapshot.connectionState == ConnectionState.done) {
                return const Center(
                  child: Text("Connection Closed"),
                );
              }
              return Image.memory(
                Uint8List.fromList(
                  base64Decode(snapshot.data.toString()),
                ),
                gaplessPlayback: true,
                excludeFromSemantics: true,
                // width: 420.0,
                // height: 400.0,
              );
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  //add chat functionality here
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return ChatlistPage();
                  }));
                },
                child: Text("Chat"),
              ),
              ElevatedButton(
                onPressed: () {
                  //add reminder functionally here
                },
                child: Text("Reminder"),
              ),
              ElevatedButton(
                onPressed: () {
                  //add temp. data analysis functionally here
                },
                child: Text("Temperature"),
              ),
            ],
          )
        ],
      ),
    );
  }
}
