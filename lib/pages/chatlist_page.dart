import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/search_page.dart';

class ChatlistPage extends StatefulWidget {
  const ChatlistPage({super.key});

  @override
  State<ChatlistPage> createState() => _ChatlistPageState();
}

class _ChatlistPageState extends State<ChatlistPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Chat App"),
      ),
      body: SafeArea(
        child: Container(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return SearchPage();
          }));
        },
        child: Icon(Icons.search),
      ),
    );
  }
}
