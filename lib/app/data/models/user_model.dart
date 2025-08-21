// lib/app/data/models/user_model.dart
import 'package:biteshare/app/data/models/subscription_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String username;
  final String displayName;
  final String? profileImage;
  final String? bio;
  final bool isPrivate;
  final List<String> followers;
  final List<String> following;
  final DateTime createdAt;
  final bool isCreator;
  int recipesCount = 0;
  final SubscriptionPlan? subscriptionPlan;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.displayName,
    this.profileImage,
    this.bio,
    this.isPrivate = false,
    this.followers = const [],
    this.following = const [],
    required this.createdAt,
    this.isCreator = false,
    this.subscriptionPlan,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      username: data['username'] ?? '',
      displayName: data['displayName'] ?? '',
      profileImage: data['profileImage'],
      bio: data['bio'],
      isPrivate: data['isPrivate'] ?? false,
      followers: List<String>.from(data['followers'] ?? []),
      following: List<String>.from(data['following'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isCreator: data['isCreator'] ?? false,
      subscriptionPlan: data['subscriptionPlan'] != null 
          ? SubscriptionPlan.fromMap(data['subscriptionPlan'])
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'username': username,
      'displayName': displayName,
      'profileImage': profileImage,
      'bio': bio,
      'isPrivate': isPrivate,
      'followers': followers,
      'following': following,
      'createdAt': Timestamp.fromDate(createdAt),
      'isCreator': isCreator,
      'subscriptionPlan': subscriptionPlan?.toMap(),
    };
  }
}

