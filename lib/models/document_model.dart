// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class DocumentModel {
  final String id;
  final String uid;
  final String title;
  final List content;
  final DateTime createdAt;

  DocumentModel( 
      {required this.uid,
      required this.title,
      required this.content,
      required this.createdAt, required this.id});


  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'uid': uid,
      'title': title,
      'content': content,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory DocumentModel.fromMap(Map<String, dynamic> map) {
    return DocumentModel(
     id: (map['_id'] ?? '') as String,
      uid:(map['uid'] ?? '') as String,
      title:(map['title'] ?? '') as String,
     content: List.from((map['content'] ?? const <dynamic>[]) as List),
     createdAt:  DateTime.fromMillisecondsSinceEpoch((map['createdAt']??0) ),
    );
  }

  String toJson() => json.encode(toMap());

  factory DocumentModel.fromJson(String source) => DocumentModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
