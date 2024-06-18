// ignore: file_names
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  Future addUserDetails(Map<String, dynamic> userInfomap, String id) async {
    return await FirebaseFirestore.instance
        .collection("User")
        .doc(id)
        .set(userInfomap);
  }
}
