import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/ChatRoomModel.dart';
import 'package:flutter_application_1/models/UserModel.dart';
import 'package:flutter_application_1/pages/chatroom_page.dart';
import 'package:flutter_application_1/pages/search_page.dart';
import 'package:flutter_application_1/services/FirebaseHelper.dart';
import 'package:flutter_application_1/services/shared_pref.dart';

class ChatlistPage extends StatefulWidget {
  const ChatlistPage({super.key});

  @override
  State<ChatlistPage> createState() => _ChatlistPageState();
}

class _ChatlistPageState extends State<ChatlistPage> {
  final sharedVar = SharedpreferenceHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Chat App"),
      ),
      body: SafeArea(
        child: FutureBuilder<String>(
          future: sharedVar.getUserId(), // Async operation to get user ID
          builder: (context, userIdSnapshot) {
            if (userIdSnapshot.connectionState == ConnectionState.done) {
              if (userIdSnapshot.hasData) {
                return StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("chatrooms")
                      .where("participants.${userIdSnapshot.data}",
                          isEqualTo: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      if (snapshot.hasData) {
                        QuerySnapshot chatRoomSnapshot =
                            snapshot.data as QuerySnapshot;

                        return ListView.builder(
                          itemCount: chatRoomSnapshot.docs.length,
                          itemBuilder: (context, index) {
                            ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(
                                chatRoomSnapshot.docs[index].data()
                                    as Map<String, dynamic>);
                            Map<String, dynamic> participants =
                                chatRoomModel.participants!;

                            List<String> participantKeys =
                                participants.keys.toList();

                            participantKeys.remove(userIdSnapshot.data);

                            return FutureBuilder<UserModel?>(
                              future: FirebaseHelper.getUserModelById(
                                  participantKeys[0]),
                              builder: (context, userData) {
                                if (userData.connectionState ==
                                    ConnectionState.done) {
                                  if (userData.data != null) {
                                    UserModel targetUser =
                                        userData.data as UserModel;
                                    return ListTile(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) {
                                            return ChatroomPage(
                                                targetUser: targetUser,
                                                chatroom: chatRoomModel);
                                          }),
                                        );
                                      },
                                      leading: CircleAvatar(
                                          backgroundColor: Colors.grey[300],
                                          backgroundImage: NetworkImage(
                                              targetUser.profilepic
                                                  .toString())),
                                      title: Text(targetUser.name.toString()),
                                      subtitle: Text(
                                          chatRoomModel.lastMessage.toString()),
                                    );
                                  } else {
                                    return Container();
                                  }
                                } else {
                                  return Container();
                                }
                              },
                            );
                          },
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(snapshot.error.toString()),
                        );
                      } else {
                        return Center(
                          child: Text("No chats"),
                        );
                      }
                    } else {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                );
              } else {
                return Center(
                  child: Text("Error retrieving user ID"),
                );
              }
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => SearchPage()));
        },
        child: Icon(Icons.search),
      ),
    );
  }
}
