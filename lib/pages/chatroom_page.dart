import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/ChatRoomModel.dart';
import 'package:flutter_application_1/models/UserModel.dart';

class ChatroomPage extends StatefulWidget {

  final UserModel targetUser;
  final ChatRoomModel chatroom;

  const ChatroomPage({super.key, required this.targetUser, required this.chatroom});

  @override
  State<ChatroomPage> createState() => _ChatroomPageState();
}

class _ChatroomPageState extends State<ChatroomPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              //this is where the chats will go
              Expanded(
                child: Container(),
              ),

              Container(
                color: Colors.grey[200],
                padding: EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 5
                ),
                child: Row(
                  children: [
                    Flexible(
                      child: TextField(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Enter message"),
                      ),
                    ),
                    IconButton(onPressed: () {}, 
                    icon: Icon(Icons.send, color: Theme.of(context).colorScheme.secondary,),)
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
