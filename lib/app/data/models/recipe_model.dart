// lib/app/data/models/recipe_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class RecipeModel {
  final String id;
  final String userId;
  final String userName;
  final String title;
  final String description;
  final List<String> ingredients;
  final List<RecipeStep> steps;
  final List<String> tags;
  final List<MediaItem> media;
  final int likes;
  final int commentsCount;
  final List<String> likedBy;
  final double averageRating;
  final int ratingsCount;
  final bool isPremium;
  final DateTime createdAt;
  final DateTime updatedAt;

  var userProfileImage;

  RecipeModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.title,
    required this.description,
    required this.ingredients,
    required this.steps,
    this.tags = const [],
    this.media = const [],
    this.likes = 0,
    this.commentsCount = 0,
    this.likedBy = const [],
    this.averageRating = 0.0,
    this.ratingsCount = 0,
    this.isPremium = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RecipeModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return RecipeModel(
      id: doc.id,
      userId: data['userId'],
      userName: data['username'],
      title: data['title'],
      description: data['description'],
      ingredients: List<String>.from(data['ingredients']),
      steps: (data['steps'] as List)
          .map((step) => RecipeStep.fromMap(step))
          .toList(),
      tags: List<String>.from(data['tags'] ?? []),
      media: (data['media'] as List)
          .map((item) => MediaItem.fromMap(item))
          .toList(),
      likes: data['likes'] ?? 0,
      commentsCount: data['comments'] ?? 0,
      likedBy: List<String>.from(data['likedBy'] ?? []),
      averageRating: (data['averageRating'] ?? 0.0).toDouble(),
      ratingsCount: data['ratingsCount'] ?? 0,
      isPremium: data['isPremium'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'title': title,
      'description': description,
      'ingredients': ingredients,
      'steps': steps.map((step) => step.toMap()).toList(),
      'tags': tags,
      'media': media.map((item) => item.toMap()).toList(),
      'likes': likes,
      'commentsCount': commentsCount,
      'likedBy': likedBy,
      'averageRating': averageRating,
      'ratingsCount': ratingsCount,
      'isPremium': isPremium,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

class RecipeStep {
  final int stepNumber;
  final String instruction;
  final String? image;

  RecipeStep({
    required this.stepNumber,
    required this.instruction,
    this.image,
  });

  factory RecipeStep.fromMap(Map<String, dynamic> map) {
    return RecipeStep(
      stepNumber: map['stepNumber'],
      instruction: map['instruction'],
      image: map['image'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'stepNumber': stepNumber,
      'instruction': instruction,
      'image': image,
    };
  }
}

class MediaItem {
  final String url;
  final MediaType type;
  final String? thumbnail;

  MediaItem({
    required this.url,
    required this.type,
    this.thumbnail,
  });

  factory MediaItem.fromMap(Map<String, dynamic> map) {
    return MediaItem(
      url: map['url'],
      type: MediaType.values[map['type']],
      thumbnail: map['thumbnail'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'type': type.index,
      'thumbnail': thumbnail,
    };
  }
}

enum MediaType { image, video }
