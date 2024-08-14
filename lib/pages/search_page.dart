import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/models/ChatRoomModel.dart';
import 'package:flutter_application_1/models/UserModel.dart';
import 'package:flutter_application_1/pages/chatroom_page.dart';
import 'package:flutter_application_1/services/shared_pref.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final searchController = TextEditingController();
  final sharedVariable = SharedpreferenceHelper();

  Future<ChatRoomModel?> getChatroomModel(UserModel targetUser) async {
    String userId = await sharedVariable.getUserId();
    ChatRoomModel? chatRoom;

    QuerySnapshot? snapshot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .where("participants.$userId", isEqualTo: true)
        .where("participants.${targetUser.uid}", isEqualTo: true)
        .get();

    if (snapshot.docs.length > 0) {
      //fetch the existing one
      // print("Chatroom already created!!!");

      var docData = snapshot.docs[0].data();
      ChatRoomModel existingChatroom = ChatRoomModel.fromMap((docData as Map<String, dynamic>)); 
      chatRoom = existingChatroom;
    } 
    else {
      //create new one
      // print("Chatroom not created!");
      ChatRoomModel newchatroom = ChatRoomModel(
          chatroomid: uuid.v1(),
          lastMessage: "",
          participants: {
            userId.toString(): true,
            targetUser.uid.toString(): true
          });
      await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(newchatroom.chatroomid)
          .set(newchatroom.toMap());

      chatRoom = newchatroom;
      // print("New chatroom is created!!");
    }
    return chatRoom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Search"),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              TextField(
                controller: searchController,
                decoration: InputDecoration(labelText: "Email Address"),
              ),
              SizedBox(
                height: 20,
              ),
              CupertinoButton(
                onPressed: () {
                  setState(() {});
                },
                child: Text("Search"),
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(
                height: 20,
              ),
              FutureBuilder<String>(
                future: sharedVariable.getUserEmail(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  } else if (snapshot.hasData) {
                    String userEmail = snapshot.data!;

                    return StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection("users")
                          .where("email",
                              isEqualTo: searchController.text.trim())
                          .where("email", isNotEqualTo: userEmail)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.active) {
                          if (snapshot.hasData) {
                            QuerySnapshot? dataSnapshot =
                                snapshot.data as QuerySnapshot;

                            if (dataSnapshot.docs.length > 0) {
                              Map<String, dynamic> userMap =
                                  dataSnapshot.docs[0].data()
                                      as Map<String, dynamic>;

                              UserModel searchedUser =
                                  UserModel.fromMap(userMap);

                              return ListTile(
                                onTap: () async {
                                  ChatRoomModel? chatroomModel =
                                      await getChatroomModel(searchedUser);
                                  if(chatroomModel != null){
                                    Navigator.pop(context);
                                    Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                        return ChatroomPage(targetUser: searchedUser, chatroom: chatroomModel);
                                    }));
                                  }
                                },
                                leading: CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(searchedUser.profilepic ?? ""),
                                  backgroundColor: Colors.grey[500],
                                ),
                                title: Text(searchedUser.name ?? ""),
                                subtitle: Text(searchedUser.email ?? ""),
                                trailing: Icon(Icons.keyboard_arrow_right),
                              );
                            } else {
                              return Text("No result found!!!");
                            }
                          } else if (snapshot.hasError) {
                            return Text("An error occurred!!!");
                          } else {
                            return Text("No result found!!!");
                          }
                        } else {
                          return CircularProgressIndicator();
                        }
                      },
                    );
                  } else {
                    return Text("No result found!!!");
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         title: Text("Search"),
//       ),
//       body: SafeArea(
//         child: Container(
//           padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//           child: Column(
//             children: [
//               TextField(
//                 controller: searchController,
//                 decoration: InputDecoration(labelText: "Email Address"),
//               ),
//               SizedBox(
//                 height: 20,
//               ),
//               MaterialButton(
//                 onPressed: () {
//                   setState(() {});
//                 },
//                 child: Text("Search"),
//                 color: Theme.of(context).colorScheme.secondary,
//               ),
//               SizedBox(
//                 height: 20,
//               ),
//               StreamBuilder(
//                   stream: FirebaseFirestore.instance
//                       .collection("users")
//                       .where("email", isEqualTo: searchController.text.trim())
//                       .where("email", isNotEqualTo:  sharedVariable.getUserEmail())
//                       .snapshots(),
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.active) {
//                       if (snapshot.hasData) {
//                         QuerySnapshot? dataSnapshot =
//                             snapshot.data as QuerySnapshot;

//                         if (dataSnapshot.docs.length > 0) {
//                           Map<String, dynamic> userMap = dataSnapshot.docs[0]
//                               .data() as Map<String, dynamic>;

//                           UserModel searchedUser = UserModel.fromMap(userMap);

//                           return ListTile(
//                             onTap: () async {
//                               // ignore: unused_local_variable
//                               ChatRoomModel? chatroomModel =
//                                   await getChatroomModel(searchedUser);
//                               // Navigator.pop(context);
//                               // Navigator.push(context,
//                               //   MaterialPageRoute(builder: (context) {
//                               //     return ChatroomPage(targetUser: searchedUser, chatroom: ,);
//                               // }));
//                             },
//                             leading: CircleAvatar(
//                               backgroundImage:
//                                   NetworkImage(searchedUser.profilepic!),
//                               backgroundColor: Colors.grey[500],
//                             ),
//                             title: Text(searchedUser.name!),
//                             subtitle: Text(searchedUser.email!),
//                             trailing: Icon(Icons.keyboard_arrow_right),
//                           );
//                         } else {
//                           return Text("No result found!!!");
//                         }
//                       } else if (snapshot.hasError) {
//                         return Text("An error occured!!!");
//                       } else {
//                         return Text("No result found!!!");
//                       }
//                     } else {
//                       return CircularProgressIndicator();
//                     }
//                   }),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
}
