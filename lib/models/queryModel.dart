import 'package:cloud_firestore/cloud_firestore.dart';

class QueryModel {
  String id;
  String userId;
  String question;
  Timestamp timestamp;
  List<ReplyModel> replies;

  QueryModel({
    required this.id,
    required this.userId,
    required this.question,
    required this.timestamp,
    this.replies = const [],
  });

  factory QueryModel.fromMap(Map<String, dynamic> map, String id) {
    return QueryModel(
      id: id,
      userId: map['userId'] as String,
      question: map['question'] as String,
      timestamp: map['timestamp'] as Timestamp,
      replies: (map['replies'] as List<dynamic>?)
          ?.map((reply) => ReplyModel.fromMap(reply))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'question': question,
      'timestamp': timestamp,
      'replies': replies.map((reply) => reply.toMap()).toList(),
    };
  }
}

class ReplyModel {
  String dentistId;
  String replyText;
  Timestamp timestamp;

  ReplyModel({
    required this.dentistId,
    required this.replyText,
    required this.timestamp,

  });

  factory ReplyModel.fromMap(Map<String, dynamic> map) {
    return ReplyModel(
      dentistId: map['dentistId'] as String,
      replyText: map['replyText'] as String,
      timestamp: map['timestamp'] as Timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dentistId': dentistId,
      'replyText': replyText,
      'timestamp': timestamp,
    };
  }
}
