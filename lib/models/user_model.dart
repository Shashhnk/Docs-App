// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class UserModel {
  final String email;
  final String name;
  final String token;
  final String profilePic;
  final String uid;

  UserModel(
      {required this.email,
      required this.name,
      required this.token,
      required this.profilePic,
      required this.uid});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'email': email,
      'name': name,
      'token': token,
      'profilePic': profilePic,
      'uid': uid,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      email: (map['email'] ??"") as String,
      name: (map['name'] ??"") as String,
      token: (map['token'] ??"") as String,
      profilePic: (map['profilePic'] ??"")as String,
      uid: (map['_id'] ??"") as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  UserModel copyWith({
    String? email,
    String? name,
    String? token,
    String? profilePic,
    String? uid,
  }) {
    return UserModel(
      email: email ?? this.email,
      name: name ?? this.name,
      token: token ?? this.token,
      profilePic: profilePic ?? this.profilePic,
      uid: uid ?? this.uid,
    );
  }
}
