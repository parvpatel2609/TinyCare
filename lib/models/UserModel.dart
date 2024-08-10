class UserModel{
  String? uid;
  String? email;
  String? part_email;
  String? part_name;
  String? profilepic;
  String? security;
  String? name;

  UserModel({this.uid, this.email, this.name, this.part_email, this.part_name, this.profilepic, this.security});

  UserModel.fromMap(Map<String, dynamic> map){
    uid = map["uid"];
    email = map["email"];
    part_email = map["part_email"];
    part_name = map["part_name"];
    profilepic = map["profilepic"];
    security = map["security"];
    name = map["map"];
  }

  Map<String, dynamic> toMap(){
    return {
      "uid": uid,
      "email": email,
      "part_email": part_email,
      "part_name": part_name,
      "profilepic": profilepic,
      "security": security,
      "name": name
    };
  }
}