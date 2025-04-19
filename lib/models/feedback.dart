import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackModel {
  final String id;
  final String userId;
  final String userName; // New field
  final int rating;
  final String comment;
  final DateTime timestamp;

  FeedbackModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.timestamp,
  });


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'timestamp': timestamp.toUtc(),
    };
  }

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'] ?? 'Unknown',
      rating: json['rating'] ?? '',
      comment: json['comment'] ?? '',
      timestamp: (json['timestamp'] as Timestamp).toDate(),
    );
  }
}
