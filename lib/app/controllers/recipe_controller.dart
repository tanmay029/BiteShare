// lib/app/controllers/recipe_controller.dart
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../data/models/recipe_model.dart';
import '../data/services/firebase_service.dart';
import 'auth_controller.dart';

class RecipeController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseService _firebaseService = Get.find<FirebaseService>();
  final AuthController _authController = Get.find<AuthController>();
  DocumentSnapshot? lastDocument;
  final RxBool hasMoreData = true.obs;

  final RxList<RecipeModel> feedRecipes = <RecipeModel>[].obs;
  final RxList<RecipeModel> userRecipes = <RecipeModel>[].obs;
  final RxList<RecipeModel> bookmarkedRecipes = <RecipeModel>[].obs;
  final RxList<RecipeModel> searchResults = <RecipeModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadFeedRecipes();
  }

  Future<void> loadMoreRecipes() async {
  if (!hasMoreData.value) return;
  
  Query query = _firestore
      .collection('recipes')
      .orderBy('createdAt', descending: true)
      .limit(10);
      
  if (lastDocument != null) {
    query = query.startAfterDocument(lastDocument!);
  }
  
  QuerySnapshot snapshot = await query.get();
  
  if (snapshot.docs.length < 10) {
    hasMoreData.value = false;
  }
  
  if (snapshot.docs.isNotEmpty) {
    lastDocument = snapshot.docs.last;
    feedRecipes.addAll(
      snapshot.docs.map((doc) => RecipeModel.fromFirestore(doc))
    );
  }
}

  Future<void> loadFeedRecipes() async {
    try {
      isLoading.value = true;
      
      // Get recipes from followed users
      List<String> followingIds = _authController.userModel?.following ?? [];
      followingIds.add(_authController.userModel?.id ?? '');

      QuerySnapshot snapshot = await _firestore
          .collection('recipes')
          .where('userId', whereIn: followingIds.isEmpty ? [''] : followingIds)
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();

      feedRecipes.value = snapshot.docs
          .map((doc) => RecipeModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error loading feed: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadExploreRecipes() async {
    try {
      isLoading.value = true;
      
      QuerySnapshot snapshot = await _firestore
          .collection('recipes')
          .where('isPremium', isEqualTo: false)
          .orderBy('likes', descending: true)
          .limit(50)
          .get();

      searchResults.value = snapshot.docs
          .map((doc) => RecipeModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error loading explore recipes: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<String> createRecipe({
    required String title,
    required String description,
    required List<String> ingredients,
    required List<RecipeStep> steps,
    required List<String> tags,
    required List<MediaItem> media,
    bool isPremium = false,
  }) async {
    try {
      String recipeId = const Uuid().v4();
      
      RecipeModel recipe = RecipeModel(
        id: recipeId,
        userId: _authController.userModel!.id,
        title: title,
        description: description,
        ingredients: ingredients,
        steps: steps,
        tags: tags,
        media: media,
        isPremium: isPremium,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(), userName: '',
      );

      await _firestore
          .collection('recipes')
          .doc(recipeId)
          .set(recipe.toFirestore());

      // Send notification to followers
      await _sendRecipeNotificationToFollowers(recipe);

      return recipeId;
    } catch (e) {
      throw Exception('Failed to create recipe: $e');
    }
  }

  Future<void> likeRecipe(String recipeId) async {
    try {
      String userId = _authController.userModel!.id;
      DocumentReference recipeRef = _firestore.collection('recipes').doc(recipeId);
      
      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(recipeRef);
        if (!snapshot.exists) return;
        
        List<String> likedBy = List<String>.from(snapshot.get('likedBy') ?? []);
        int likes = snapshot.get('likes') ?? 0;
        
        if (likedBy.contains(userId)) {
          likedBy.remove(userId);
          likes--;
        } else {
          likedBy.add(userId);
          likes++;
        }
        
        transaction.update(recipeRef, {
          'likedBy': likedBy,
          'likes': likes,
        });
      });
      
      // Refresh feed
      await loadFeedRecipes();
    } catch (e) {
      Get.snackbar('Error', 'Failed to like recipe');
    }
  }

  Future<void> rateRecipe(String recipeId, int rating) async {
    try {
      String userId = _authController.userModel!.id;
      
      // Check if user already rated
      QuerySnapshot existingRating = await _firestore
          .collection('ratings')
          .where('recipeId', isEqualTo: recipeId)
          .where('userId', isEqualTo: userId)
          .get();

      if (existingRating.docs.isNotEmpty) {
        // Update existing rating
        await _firestore
            .collection('ratings')
            .doc(existingRating.docs.first.id)
            .update({'rating': rating});
      } else {
        // Create new rating
        await _firestore.collection('ratings').add({
          'recipeId': recipeId,
          'userId': userId,
          'rating': rating,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // Update recipe average rating
      await _updateRecipeAverageRating(recipeId);
    } catch (e) {
      Get.snackbar('Error', 'Failed to rate recipe');
    }
  }

  Future<void> _updateRecipeAverageRating(String recipeId) async {
    QuerySnapshot ratings = await _firestore
        .collection('ratings')
        .where('recipeId', isEqualTo: recipeId)
        .get();

    if (ratings.docs.isEmpty) return;

    double totalRating = 0;
    for (var doc in ratings.docs) {
      totalRating += doc.get('rating');
    }

    double averageRating = totalRating / ratings.docs.length;

    await _firestore.collection('recipes').doc(recipeId).update({
      'averageRating': averageRating,
      'ratingsCount': ratings.docs.length,
    });
  }

  Future<void> searchRecipes(String query) async {
    try {
      searchQuery.value = query;
      isLoading.value = true;

      if (query.isEmpty) {
        await loadExploreRecipes();
        return;
      }

      // Search by title (Firestore doesn't support full-text search)
      QuerySnapshot snapshot = await _firestore
          .collection('recipes')
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      searchResults.value = snapshot.docs
          .map((doc) => RecipeModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error searching recipes: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _sendRecipeNotificationToFollowers(RecipeModel recipe) async {
    // Implementation for sending push notifications
    // This would use Firebase Cloud Messaging
  }
}
