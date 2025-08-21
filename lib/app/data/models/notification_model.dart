// lib/app/data/models/notification_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String targetUserId;
  final String? fromUserId;
  final String type;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final bool read;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.targetUserId,
    this.fromUserId,
    required this.type,
    required this.title,
    required this.body,
    this.data = const {},
    required this.read,
    required this.createdAt,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      targetUserId: data['targetUserId'],
      fromUserId: data['fromUserId'],
      type: data['type'],
      title: data['title'],
      body: data['body'],
      // Map<String, dynamic>.from(data['data'] ?? {}), //error
      read: data['read'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  NotificationModel copyWith({bool? read}) {
    return NotificationModel(
      id: id,
      targetUserId: targetUserId,
      fromUserId: fromUserId,
      type: type,
      title: title,
      body: body,
      //  data, //error
      read: read ?? this.read,
      createdAt: createdAt,
    );
  }
}
