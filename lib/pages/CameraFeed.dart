import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Live Camera Feed',
      home: CameraFeed(),
    );
  }
}

class CameraFeed extends StatefulWidget {
  @override
  _CameraFeedState createState() => _CameraFeedState();
}

class _CameraFeedState extends State<CameraFeed> {
  late WebSocketChannel channel;
  Uint8List? _imageData;

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
  }

  void _connectWebSocket() {
    channel = WebSocketChannel.connect(
      Uri.parse('ws://10.0.0.38:8765'), // Replace with your server's IP address if not running on localhost
    );

    channel.stream.listen(
      (message) {
        setState(() {
          _imageData = base64Decode(message);
        });
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
    channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Live Camera Feed'),
      ),
      body: Center(
        child: _imageData != null
            ? Image.memory(_imageData!)
            : CircularProgressIndicator(),
      ),
    );
  }
}
