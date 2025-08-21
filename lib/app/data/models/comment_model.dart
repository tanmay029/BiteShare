// lib/app/data/models/comment_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String recipeId;
  final String userId;
  final String username;
  final String? userProfileImage;
  final String text;
  final String? parentCommentId;
  final List<String> likedBy;
  final int likes;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.recipeId,
    required this.userId,
    required this.username,
    this.userProfileImage,
    required this.text,
    this.parentCommentId,
    this.likedBy = const [],
    this.likes = 0,
    required this.createdAt,
  });

  factory CommentModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return CommentModel(
      id: doc.id,
      recipeId: data['recipeId'],
      userId: data['userId'],
      username: data['username'],
      userProfileImage: data['userProfileImage'],
      text: data['text'],
      parentCommentId: data['parentCommentId'],
      likedBy: List<String>.from(data['likedBy'] ?? []),
      likes: data['likes'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'recipeId': recipeId,
      'userId': userId,
      'username': username,
      'userProfileImage': userProfileImage,
      'text': text,
      'parentCommentId': parentCommentId,
      'likedBy': likedBy,
      'likes': likes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  CommentModel copyWith({
    List<String>? likedBy,
    int? likes,
  }) {
    return CommentModel(
      id: id,
      recipeId: recipeId,
      userId: userId,
      username: username,
      userProfileImage: userProfileImage,
      text: text,
      parentCommentId: parentCommentId,
      likedBy: likedBy ?? this.likedBy,
      likes: likes ?? this.likes,
      createdAt: createdAt,
    );
  }
}
