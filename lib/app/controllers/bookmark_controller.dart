// lib/app/controllers/bookmark_controller.dart
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/recipe_model.dart';
import 'auth_controller.dart';

class BookmarkController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = Get.find<AuthController>();

  final RxList<RecipeModel> bookmarkedRecipes = <RecipeModel>[].obs;
  final RxList<String> bookmarkedRecipeIds = <String>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadBookmarks();
  }

  Future<void> loadBookmarks() async {
    try {
      isLoading.value = true;
      String userId = _authController.userModel!.id;
      
      // Get bookmarked recipe IDs
      QuerySnapshot bookmarkSnapshot = await _firestore
          .collection('bookmarks')
          .where('userId', isEqualTo: userId)
          .get();

      List<String> recipeIds = bookmarkSnapshot.docs
          .map((doc) => doc.get('recipeId') as String)
          .toList();

      bookmarkedRecipeIds.value = recipeIds;

      if (recipeIds.isNotEmpty) {
        // Get actual recipe documents
        QuerySnapshot recipeSnapshot = await _firestore
            .collection('recipes')
            .where(FieldPath.documentId, whereIn: recipeIds)
            .get();

        bookmarkedRecipes.value = recipeSnapshot.docs
            .map((doc) => RecipeModel.fromFirestore(doc))
            .toList();
      } else {
        bookmarkedRecipes.clear();
      }
    } catch (e) {
      print('Error loading bookmarks: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleBookmark(String recipeId) async {
    try {
      String userId = _authController.userModel!.id;
      
      QuerySnapshot existingBookmark = await _firestore
          .collection('bookmarks')
          .where('userId', isEqualTo: userId)
          .where('recipeId', isEqualTo: recipeId)
          .get();

      if (existingBookmark.docs.isNotEmpty) {
        // Remove bookmark
        await _firestore
            .collection('bookmarks')
            .doc(existingBookmark.docs.first.id)
            .delete();
        
        bookmarkedRecipeIds.remove(recipeId);
        bookmarkedRecipes.removeWhere((recipe) => recipe.id == recipeId);
        
        Get.snackbar('Removed', 'Recipe removed from bookmarks');
      } else {
        // Add bookmark
        await _firestore.collection('bookmarks').add({
          'userId': userId,
          'recipeId': recipeId,
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        bookmarkedRecipeIds.add(recipeId);
        
        // Get recipe details and add to bookmarked list
        DocumentSnapshot recipeDoc = await _firestore
            .collection('recipes')
            .doc(recipeId)
            .get();
        
        if (recipeDoc.exists) {
          RecipeModel recipe = RecipeModel.fromFirestore(recipeDoc);
          bookmarkedRecipes.add(recipe);
        }
        
        Get.snackbar('Saved', 'Recipe saved to bookmarks');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to toggle bookmark');
    }
  }

  bool isBookmarked(String recipeId) {
    return bookmarkedRecipeIds.contains(recipeId);
  }
}
