// lib/app/utils/dummy_data_generator.dart
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/user_model.dart';
import '../data/models/recipe_model.dart';

class DummyDataGenerator {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> generateDummyData() async {
    await _createDummyUsers();
    await _createDummyRecipes();
  }

  static Future<void> _createDummyUsers() async {
    List<Map<String, dynamic>> dummyUsers = [
      {
        'id': 'user1',
        'email': 'chef.maria@example.com',
        'username': 'chef_maria',
        'displayName': 'Chef Maria Rodriguez',
        'bio': 'Professional chef specializing in Mediterranean cuisine',
        'isCreator': true,
        'followers': ['user2', 'user3'],
        'following': ['user2'],
      },
      {
        'id': 'user2',
        'email': 'baker.john@example.com',
        'username': 'baker_john',
        'displayName': 'John Baker',
        'bio': 'Passionate home baker sharing family recipes',
        'isCreator': true,
        'followers': ['user1', 'user3'],
        'following': ['user1'],
      },
      // Add more dummy users...
    ];

    for (var userData in dummyUsers) {
      UserModel user = UserModel(
        id: userData['id'],
        email: userData['email'],
        username: userData['username'],
        displayName: userData['displayName'],
        bio: userData['bio'],
        isCreator: userData['isCreator'],
        followers: List<String>.from(userData['followers']),
        following: List<String>.from(userData['following']),
        createdAt: DateTime.now().subtract(Duration(days: 30)),
      );

      await _firestore.collection('users').doc(user.id).set(user.toFirestore());
    }
  }

  static Future<void> _createDummyRecipes() async {
    List<Map<String, dynamic>> dummyRecipes = [
      {
        'userId': 'user1',
        'title': 'Authentic Spanish Paella',
        'description': 'A traditional Valencian paella recipe passed down through generations',
        'ingredients': ['Rice', 'Saffron', 'Chicken', 'Rabbit', 'Green beans', 'Lima beans', 'Olive oil'],
        'tags': ['Spanish', 'Traditional', 'Main Course'],
        'isPremium': false,
      },
      {
        'userId': 'user2',
        'title': 'Artisan Sourdough Bread',
        'description': 'Learn to make perfect sourdough with this detailed guide',
        'ingredients': ['Sourdough starter', 'Bread flour', 'Water', 'Salt'],
        'tags': ['Bread', 'Artisan', 'Fermentation'],
        'isPremium': true,
      },
      // Add more dummy recipes...
    ];

    for (var recipeData in dummyRecipes) {
      List<RecipeStep> steps = [
        RecipeStep(stepNumber: 1, instruction: 'Prepare all ingredients'),
        RecipeStep(stepNumber: 2, instruction: 'Mix and combine'),
        RecipeStep(stepNumber: 3, instruction: 'Cook according to directions'),
      ];

      RecipeModel recipe = RecipeModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: recipeData['userId'],
        title: recipeData['title'],
        description: recipeData['description'],
        ingredients: List<String>.from(recipeData['ingredients']),
        steps: steps,
        tags: List<String>.from(recipeData['tags']),
        media: [], // Add dummy media URLs if needed
        isPremium: recipeData['isPremium'],
        createdAt: DateTime.now().subtract(Duration(days: Random().nextInt(30))),
        updatedAt: DateTime.now(),
        likes: Random().nextInt(100), 
        userName: '',
      );

      await _firestore.collection('recipes').doc(recipe.id).set(recipe.toFirestore());
    }
  }
}
